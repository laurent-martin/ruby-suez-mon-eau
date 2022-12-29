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
