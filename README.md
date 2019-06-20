# routing-rocks-policy-role
Bird 2.x routing policy used in routing-rocks (AS202739), Freifunk Essen (AS206356), etc.

## AS-Sets
The policy expects definitions for the AS_SET values used in the inventory in the `as-sets` directory. In my setup these prefix lists are auto generated via cronjob. This tooling for this task will be open sourced in the future. For now you have to make sure that theses files exists. In the example I used a AS_SET for a peering between routing-rocks and Freifunk Essen. This file looks like:
```
define AS_FFE_ACCESS = [
    185.232.102.0/24{24,32},
    194.48.228.0/24{25,32},
    2001:67c:6d0::/48{48,64},
    2a0c:1700:ffe::/48{48,64}
];
```
