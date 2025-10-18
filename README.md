# LeLoi Linux 

Bootc bootstrap image for my laptop LeLoi.  
LeLoi is a ThinkPad P14s Gen 6 laptop that comes with an AMD Ryzen™ AI 9 HX PRO 370 processor.  
https://psref.lenovo.com/Product/ThinkPad/ThinkPad_P14s_Gen_6_AMD  
LeLoi features a 14" WUXGA (1920 × 1200) IPS 60Hz display.  

How to create boot image:  
```
$ sudo podman build -t leloi-linux-base .
```

How to create bootable iso to install to bare metal machine: 
```
$ sudo podman run --rm -it --privileged --pull=newer \
  --security-opt label=type:unconfined_t \
  -v ./output:/output \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  -v ./config.toml:/config.toml:ro \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  --rootfs btrfs \
  --chown 1000:1000 \
  ghcr.io/seungjin/leloi-linux-base
```  

 

  
TODO:
  - 
