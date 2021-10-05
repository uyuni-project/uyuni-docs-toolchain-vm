# uyuni-translation-image
Uyuni/SUMA toolchain built using KIWI Next Gen. Creates various image formats containing Antora, Asciidoctor, Asciidoctor-pdf and doc repo.

Build it on Leap 15.2 with this command:

```
sudo kiwi-ng --profile vmdk system build --description UyuniDocImage --target-dir image
```

login is `uyuni/linux` and `root/linux`


Creating release package:

Call this immediately after build.
There is size limit 2GB on github, so if the image grows larger,
it must be split to multipart zip file.

```
zip -s 2000M image.zip image/UyuniDocImage*.vm*
```


= Using the improved toolchain

I have created an issue to track adding the below steps to our prebuilt image. ATM however, you will need to do the second step manually.

== Booting
. Boot translation vm in either VMWare or KVM
. Login with user: uyuni pass: linux
. open terminal

== Install the new required python libraries and zip

. Accept certificate with `a`
. Install python jinja2 templates: `sudo zypper in python3-Jinja2`
. Install python yaml: `sudo zypper in python3-PyYAML`
. Install zip: `sudo zypper in zip`
. Install gedit: `sudo zypper in gedit`

== Updating local content on master

. change to the doc repo directory: `cd uyuni-docs/`
. Fetch latest branches and content: `git fetch --all`
. Pull and fast forward to latest content: `git pull -ff`
. checkout publication branch for example: `git checkout manager-4.2-MU-4.2.2`
. Run `git pull` to get the latest content

== Configuring your build

. The parameters.yml file is used to configure either Uyuni or suma outputs. All common variables are stored in this file.
. Open the parameters.yml file in gedit. 
