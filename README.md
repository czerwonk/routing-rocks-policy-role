# routing-rocks-policy-role
Bird 2.x routing policy used in routing-rocks (AS202739), Freifunk Essen (AS206356), etc.

## Inventory
In this example I will give a brief example how a policy inventory could look like. This is an short example which was derived from the actual routing policy of the ASes running this policy.

Given the following situation:
* we are AS202739 (routing-rocks)
* we want to peer with AS206356 Freifunk Essen on DE-CIX DUS and FRA
* DE-CIX FRA is a remote peering

## AS-Sets
The policy expects definitions for the AS_SET values used in the inventory in the `as-sets` directory. In my setup these prefix lists are auto generated via cronjob. This tooling for this task will be open sourced in the future. For now you have to make sure that theses files exists. In the example I used a AS_SET for a peering between routing-rocks and Freifunk Essen. This file looks like:
```
define AS_FFE = [
    194.48.228.0/22{22,24},
    2a0c:efc0::/29{29,48}
];
```
