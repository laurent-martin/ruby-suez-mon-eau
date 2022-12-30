# frozen_string_literal: true

require 'rest-client'
require 'json'

# Volumes in m³
class SuezMonEau
  VERSION='0.1'
  GEM_NAME='suez_mon_eau'
  SRC_URL='https://github.com/laurent-martin/ruby-suez-mon-eau'
  DOC_URL='https://github.com/laurent-martin/ruby-suez-mon-eau/#readme'
  GEM_URL='https://rubygems.org/gems/suez_mon_eau'
  BASE_URIS = {
    'Suez'       => 'https://www.toutsurmoneau.fr/mon-compte-en-ligne',
    'Eau Olivet' => 'https://www.eau-olivet.fr/mon-compte-en-ligne'
  }.freeze
  API_ENDPOINT_LOGIN = 'je-me-connecte'
  # daily (Jours) : /Y/m/counterid : Array(JJMMYYY, daily volume, cumulative volume). Volumes: .xxx
  API_ENDPOINT_DAILY = 'statJData'
  # monthly (Mois) : /counterid : Array(mmm. yy, monthly volume, cumulative voume, Mmmmm YYYY)
  API_ENDPOINT_MONTHLY = 'statMData'
  API_ENDPOINT_CONTRAT = 'donnees-contrats'
  PAGE_CONSO = 'historique-de-consommation-tr'
  SESSION_ID = 'eZSESSID'
  MONTHS = %w[Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre].freeze
  private_constant :BASE_URIS,:API_ENDPOINT_LOGIN,:API_ENDPOINT_DAILY,:API_ENDPOINT_MONTHLY,:API_ENDPOINT_CONTRAT,:PAGE_CONSO,:SESSION_ID,:MONTHS

  # @param provider optional, one of supported providers or base url
  def initialize(username:, password:, id: nil, provider: 'Suez')
    @base_uri = BASE_URIS[provider] || provider
    raise 'Not a valid provider' if @base_uri.nil?
    @username = username
    @password = password
    @id = id
    @id=nil if @id.is_a?(String) && @id.empty?
    @cookies = nil
    return unless @id.nil?
    update_access_cookie
    conso_page=RestClient.get("#{@base_uri}/#{PAGE_CONSO}",cookies: @cookies)
    # get counter id from page
    raise 'Could not retrieve counter id' unless (token_match = conso_page.body.match(%r{/month/([0-9]+)}))
    @id=token_match[1]
  end

  def update_access_cookie
    initial_response = RestClient.get("#{@base_uri}/#{API_ENDPOINT_LOGIN}")
    raise 'Could not get token' unless (token_match = initial_response.body.match(%r{_csrf_token" value="(.*)"/>}))
    data = {
      '_csrf_token'                => token_match[1],
      '_username'                  => @username,
      '_password'                  => @password,
      'signin[username]'           => @username,
      'signin[password]'           => nil,
      'tsme_user_login[_username]' => @username,
      'tsme_user_login[_password]' => @password
    }
    # There is a redirect (302) on POST
    response = RestClient.post("#{@base_uri}/#{API_ENDPOINT_LOGIN}", data,
      { cookies: initial_response.cookies }) do |resp, _req, _res|
      case resp.code
      when 301, 302, 307
        begin
          resp.follow_redirection
        rescue RestClient::Found
          raise 'Check username and password'
        end
      else resp.return!
      end
    end
    raise StandardError, 'Login error: Please check your username/password.' unless response.cookies.key?(SESSION_ID)
    @cookies = { SESSION_ID => response.cookies[SESSION_ID] }
  end

  def call_api(method:, endpoint:)
    retried = false
    loop do
      update_access_cookie if @cookies.nil?
      resp = RestClient::Request.execute(method: method, url: "#{@base_uri}/#{endpoint}", cookies: @cookies)
      return JSON.parse(resp.body) if resp.headers[:content_type].include?('application/json')
      raise 'Failed refreshing cookie' if retried
      retried = true
      @cookies = nil
    end
  end

  def contracts
    call_api(method: :get, endpoint: API_ENDPOINT_CONTRAT)
  end

  # @param thedate [Date] use year and month, built with Date.new(year,month,1)
  # @return Hash [day_in_month]={day:, total:}
  def daily_for_month(thedate)
    r = call_api(method: :get, endpoint: "#{API_ENDPOINT_DAILY}/#{thedate.year}/#{thedate.month}/#{@id}")
    # since the month is known, keep only day
    r.each_with_object({}) do |i, m|
      m[i[0].split('-').last.to_i] = { day: i[1], total: i[2] } unless i[2].eql?(0)
    end
  end

  # @returns [Hash]
  def monthly_recent
    resp = call_api(method: :get, endpoint: "#{API_ENDPOINT_MONTHLY}/#{@id}")
    h = {}
    result = {
      history:                h,
      total_volume:           nil,
      highest_monthly_volume: resp.pop,
      last_year_volume:       resp.pop,
      this_year_volume:       resp.pop
    }
    # fill history by hear and month
    resp.each do |i|
      # skip futures
      next if i[2].eql?(0)
      # date is Month Year
      d = i[3].split(' ')
      year = d.last.to_i
      month = 1 + MONTHS.find_index(d.first)
      h[year] ||= {}
      h[year][month] = { month: i[1], total: result[:total_volume] = i[2] }
    end
    result
  end

  def total_volume
    monthly_recent[:total_volume]
  end
end
