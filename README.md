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
