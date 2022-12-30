# Ruby gem for www.toutsurmoneau.fr

This gem provides a simple API to retrieve water consumption from french provider Suez.

All is required is an account on https://www.toutsurmoneau.fr
## Counter id

The gem will figureout the counter id to use, but if you prefer to specify it, it can be retrieved like this:

Go to <https://www.toutsurmoneau.fr/mon-compte-en-ligne/historique-de-consommation-tr>

View page source and search: `/month/` : the counter id is located just after that path:

```javascript
var $url = '/mon-compte-en-ligne/exporter-consommation/month/7444012345';
```

## Example

An example of use is provided in script: [bin/suez_mon_eau](bin/suez_mon_eau)

## Gem Signature

SuezMonEau is cryptographically signed.
To be sure the gem you install hasn’t been tampered with:

Add the public key (if you haven’t already) as a trusted certificate:

```bash
gem cert --add <(curl -Ls https://github.com/laurent-martin/ruby-suez-mon-eau/blob/main/certs/laurent.cert.pem)

gem install metric_fu -P MediumSecurity
```

The MediumSecurity trust profile will verify signed gems, but allow the installation of unsigned dependencies.

This is necessary because not all of SuezMonEau’s dependencies are signed, so we cannot use HighSecurity.

Refer to: <https://guides.rubygems.org/security/>

## Build

To build the signed gem:

```bash
SIGNING_KEY=/path/to/signing_key.pem make
```

To build without signature:

```bash
make unsigned_gem
```
