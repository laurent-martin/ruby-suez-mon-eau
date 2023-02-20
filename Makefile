GEMNAME=$(shell sed -n -e "s/.*GEM_NAME='\(.*\)'/\1/p" lib/suez_mon_eau.rb)
GEMVERS=$(shell sed -n -e "s/.*VERSION='\(.*\)'/\1/p" lib/suez_mon_eau.rb)
DIR_TOP=./
DIR_TMP=$(DIR_TOP)tmp/
PATH_GEMFILE=$(DIR_TOP)$(GEMNAME)-$(GEMVERS).gem
all:: signed_gem
##################################
# Test
$(DIR_TMP).exists:
	mkdir -p $(DIR_TMP)
	@touch $@
tests:
	. ./.config/vars.sh && bundle exec ./bin/suez_mon_eau -u "$$user" -p "$$pass"
clean::
	rm -f Gemfile.lock
	rm -fr $(DIR_TMP)
##################################
# Gem build
$(DIR_TMP).gems_checked: $(DIR_TMP).exists $(DIR_TOP)Gemfile
	cd $(DIR_TOP). && bundle install
	rm -f $$HOME/.rvm/gems/*/bin/as{cli,ession}
	touch $@
$(PATH_GEMFILE): $(DIR_TMP).gems_checked
	gem build $(GEMNAME)
# check that the signing key is present
gem_check_signing_key:
	@echo 'Checking env var: SIGNING_KEY'
	@if test -z "$$SIGNING_KEY";then echo 'Error: Missing env var SIGNING_KEY' 1>&2;exit 1;fi
# force rebuild of gem and sign it, then check signature
signed_gem: gemclean gem_check_signing_key $(PATH_GEMFILE)
	@tar tf $(PATH_GEMFILE)|grep '\.gz\.sig$$'
	@echo "Ok: gem is signed"
# build gem without signature for development and test
unsigned_gem: $(PATH_GEMFILE)
clean:: gemclean
gemclean:
	rm -f $(PATH_GEMFILE)

##################################
# Gem publish
release: all
	gem push $(PATH_GEMFILE)
version:
	@echo $(GEMNAME) $(GEMVERS)
