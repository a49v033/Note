# nrpkg zip解包后出现3个文件

```
一个系统镜像(重命名为systemnew2flash.bin)，
一个uboot(重命名为ubootnew2flash.bin)，
一个描述文件。

备份 bdinfo:  dd if /dev/mtd4 of /tmp/bdinfobk.bin

刷入 uboot: mtd -q write /tmp/ubootnew2flash.bin FIP
校验 uboot: mtd -q verify /tmp/ubootnew2flash.bin FIP
刷入 system: mtd -q write /tmp/systemnew2flash.bin ubi
校验 system: mtd -q verify /tmp/systemnew2flash.bin ubi
```