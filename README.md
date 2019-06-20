# routing-rocks-policy-role
Bird 2.x routing policy used in routing-rocks (AS202739), Freifunk Essen (AS206356), etc.

## Inventory
In this example I will give a brief example how a policy inventory could look like. This is an short example which was derived from the actual routing policy of the ASes running this policy.

Given the following situation:
* we are AS202739 (routing-rocks) located in DUS
* we want to peer with AS206356 Freifunk Essen on DE-CIX DUS and FRA
* DE-CIX FRA is a remote peering
* we will only configure 1 router
* we have an downstream with the imaginary ASN 12345 announcing AS_EXAMPLE
* we have an upstream with the imaginary ASN 54321
* we do RPKI-validation and the validator is running on localhost (port 3323)

### Global Configuration (group_vars)
Here we define the global settings valid for all routers of a specific group

#### routing.yml
```
asn: 202739

# RPKI validation is enabled and invalid will be rejected
rpki_validation: yes
rpki_validator:
  host: 127.0.0.1
  port: 3323
  
# local pref used for transit routes learned from 
last_resort_local_pref: 1

# communities used to tag routes
communities:
  origin: (202739, 0, 1)
  peer_import: (202739, 0, 2)
  upstream_import: (202739, 0, 3)
  downstream_import: (202739, 0, 4)
  filtered_bogon: (202739, 666, 1)
  filtered_own_prefix: (202739, 666, 2)
  filtered_own_communities: (202739, 666, 3)
  filtered_rpki_invalid: (202739, 666, 4)
  filtered_aspath_invalid: (202739, 666, 5)

# our prefixes announce
prefixes:
  ipv6:
    - 2001:678:1e0::/48

# global filters which can be used as alternative to the auto generated ones
filters:
  - name: ibgp_in
    prefixes:
      - 2001:678:1e0::/48{56,64}
      
# peer types are like templates defining common attributes for a group of peers
peer_types:
  internal:
  upstream:
    local_pref: 100
  metro_peer:
    local_pref: 10000
  remote_peer:
    local_pref: 1000

peers:
  202739: # routing-rocks
    type: internal

  54321: # upstream
    upstream: yes
    filters:
      import: upstream_as54321_in
      export: ebgp_as54321_out
    type: upstream

  206356: # ff-essen
    filters:
      import: peer_as206356_in
      export: ebgp_as206356_out
    as_set: AS_FFE
    type: metro_peer

  12345: # downstream
    downstream: yes
    filters:
      import: peer_as12345_in
      export: ebgp_as12345_out
    type: metro_peer

```

## AS-Sets
The policy expects definitions for the AS_SET values used in the inventory in the `as-sets` directory. In my setup these prefix lists are auto generated via cronjob. This tooling for this task will be open sourced in the future. For now you have to make sure that theses files exists. In the example I used a AS_SET for a peering between routing-rocks and Freifunk Essen. This file looks like:
```
define AS_FFE = [
    194.48.228.0/22{22,24},
    2a0c:efc0::/29{29,48}
];
```
