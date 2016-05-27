# Cookbook development using Vagrant

To test provisioning of the apr server:

- Install [Vagrant](https://www.vagrantup.com/downloads.html) and [Virtual Box](https://www.virtualbox.org/wiki/Downloads) and s3cmd: `sudo pip install s3cmd`

- Put your user AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in your ~/.bash_profile. And source it (`source ~/.bash_profile`).  It should look something like:

```
export AWS_ACCESS_KEY_ID=ASDHA2365236ASDDAS
export AWS_SECRET_ACCESS_KEY=232tgsdfsSDG/sdge3wsd/FGF59
```

- Provision the apr Vagrant box with `vagrant up`

- Make changes to cookbooks and test with `vagrant provision`

# Upgrading cookbooks on OpsWorks

- Make changes to the artsy_apr cookbook

- Run `package-cookbooks.sh` to vendor cookbooks to S3

- Run `update custom cookbooks` and then `execute recipes`: `artsy_apr::default` commands on OpsWorks
