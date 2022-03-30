# routing-rocks routing policy (ansible role)
Bird 2.x routing policy used in routing-rocks (AS202739), Freifunk Essen (AS206356), etc.

## Requirements
* local ansible installation
* bird routing daemon 2.x installed on the target machine
* routinator installed on the target machine (if RPKI validation should be used)

## Inventory
In this example I will give a brief example how a policy inventory could look like. This is an short example which was derived from the actual routing policy of the ASes running this policy.

Given the following situation:
* we are AS202739 (routing-rocks) located in DUS
* we want to peer with AS206356 Freifunk Essen on DE-CIX DUS and FRA using prefix limits
* DE-CIX FRA is a remote peering
* we will only configure 1 router
* we have an downstream with the imaginary ASN 12345 announcing AS_EXAMPLE
* we have an upstream with the imaginary ASN 54321
* we will ensure that traffic to our upstreams customers will stay local by using a special rule
* we do RPKI-validation and the validator is running on localhost (port 3323)
* the setup is IPv6-only (IPv4 is configurred in the same way)

### Global Configuration (group_vars)
Here we define the global settings valid for all routers of a specific group

**routing.yml**
```
asn: 202739

# RPKI validation is enabled and invalids will be rejected
rpki_validation: yes
rpki_validator:
  host: 127.0.0.1
  port: 3323
  
# local pref used for transit routes learned from 
last_resort_local_pref: 1

# communities used to tag routes
communities:
  origin: (202739, 0, 1000)
  peer_import: (202739, 0, 2000)
  upstream_import: (202739, 0, 3000)
  downstream_import: (202739, 0, 4000)
  filtered_bogon: (202739, 666, 1)
  filtered_own_prefix: (202739, 666, 2)
  filtered_own_communities: (202739, 666, 3)
  filtered_rpki_invalid: (202739, 666, 4)
  filtered_aspath_invalid: (202739, 666, 5)
  filtered_tier1: (202739, 666, 6)
  filtered_aspath_length: (202739, 666, 7)

# our prefixes announce
prefixes:
  ipv6:
    - 2001:678:1e0::/48

# global filters which can be used as alternative to the auto generated ones
filters:
  ibgp_in:
    prefixes:
      - 2001:678:1e0::/48{56,64}
  default_only:
    accept_default: yes
      
# peer types are like templates defining common attributes for a group of peers
peer_types:
  internal:
  upstream:
    local_pref: 100
    as_prepend: 2
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
    rtbh_community: (54321,666)
    rules: # our upstream uses the community (54321,200) to tag his customer routes, we use this to set the local pref
      - when:
          community: (54321,200)
        then:
          set_local_pref: 50000

  206356: # ff-essen
    filters:
      import: peer_as206356_in
      export: ebgp_as206356_out
    type: metro_peer
    max_prefix:
      ipv6: 5

  12345: # downstream
    downstream: yes
    filters:
      import: peer_as12345_in
      export: default_only
    as_set:
      ipv4: AS_EXAMPLE_IPv4
      ipv6: AS_EXAMPLE_IPv6
    type: metro_peer
```

### Metro configuration (group_vars)
This is the common configuration for all routers in one metro 

**metro.yml**
```
communities_metro:
  origin: (202739, 0, 1100)
  peer_import: (202739, 0, 2100)
  upstream_import: (202739, 0, 3100)
  downstream_import: (202739, 0, 4100)
```

### Router configuration (host_vars)
Here we define the actual sessions for the peers defined in the global config

**router.yml**
```
router_id: 100.64.0.1
source_ipv6: 2001:678:1e0:999::1
```

**static.yml**
```
# we have to define the static default route to be able to announce it downstream 
static_default_routes:
  ipv4: no
  ipv6: yes
```

**ospf.yml**
```
ospf:
  interfaces:
    - name: eth0
    - name: eth1
    - name: gre1
      ttl_security: yes

  stub_interfaces:
    - lo 

  prefixes:
    ipv6:
      - 2001:678:1e0::/48 
```

**bgp.yml**
```
peerings:
  - asn: 54321
    sessions:
      - name: upstream_01
        ip: 100.64.1.0

  - asn: 12345
    sessions:
      - name: downstream_01
        ip: 2001:678:1e0:888::2
        
  - asn: 206356
    sessions:
      - name: ff_essen_dus
        ip: 2001:7f8:9e:0:3:2614:0:1
      - name: ff_essen_fra
        ip: 2001:7f8::3:2614:0:1
        type: remote_peer # since DE-CIX FRA is remote peering for this router, we want to override the peering type here 
```

## Rules
Rules are very easy and basic way to do a little bit of TE. For now it is not possible to combine conditions. This is planned for future releases.

### Conditions
* source_as
* prefix
* community
* large_community

### Actions
* set_local_pref
* add_community
* add_large_community

## AS-Sets
The policy expects definitions for the AS_SET values used in the inventory in the `as-sets` directory. In my setup these prefix lists are auto generated via cronjob. This tooling for this task will be open sourced in the future. For now you have to make sure that theses files exists. In the example I used a AS_SET for a peering between routing-rocks and Freifunk Essen. This file looks like:
```
define AS_FFE_IPv4 = [
    194.48.228.0/22{22,24}
];

define AS_FFE_IPv6 = [
  2a0c:efc0::/29{29,48}
];
```

## License
(c) Daniel Czerwonk, 2019. Licensed under [MIT](LICENSE) license.

## Bird routing daemon
see http://bird.network.cz/
