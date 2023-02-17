# nsxt-terraform-three-tier-app

## My work with Terraform automation is currently on hold as there were a few things I couldn't do with terraform, so I'm focusing on ansible at the moment and will return to this later ##
This repo contains a demostration of combining NSX-T Terraform provider and vSphere Terraform provider in order to create fully secured three tier application.
It creates NSX-T T1 router, web, app, and db logical switches. The web LS uses a routable subnet and the other two private subnets. We can access them using NAT configures by Terraform.
It also creates different security components like Groups based on VM tags, FW Section with multiple FW rules.


```commandline
snap install terraform --classic
```
