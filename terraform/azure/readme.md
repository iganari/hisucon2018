# Azure Terraform

## :warning: WIP

+ System Requirements
    + Azure CLI

    ```
    $ which az                                                                            
    /usr/bin/az

    $ az --version                                                                        
    azure-cli
    ```

    + Terraform

    ```
    $ which terraform
    /usr/local/bin/terraform

    $ terraform --version                                                                
    Terraform v0.11.11
    ```

+ Copy var file of Terraform from Sample var file.

```
cp -a variables.tf.sample variables.tf
```

+ Edit var file
    + You need to fill this list perfectly.
        + `YOUR-NAME`
        + `YOUR-RESOURCE-GROUP-NAME`
        + `YOUR-VNET-NAME`
        + `YOUR-SUBNET-NAME`
        + `YOUR-PUBLIC-IP-NAME`
        + `YOUR-DNSLABEL-NAME`
        + `YOUR-NETWORK-SECURITY-NAME`
        + `YOUR-NETWORK-INTERFACE-NAME`
        + `DISK-NAME`
        + `YOUR-VIRTUAL-MACHINE-NAME`
        + `YOUR-HOSTNAME`
        + `YOUR-USERNAME`
    + And Input Your Public-key 
        + "os_userpublickey"

```
vim variables.tf
```

