# Mikan OS by naok-000

## Setup

```console
$ git clone --recursive https://github.com/naok-000/myMikanos.git
$ cd myMikanos
```

```console
$ cd edk2
$ which clang # /ust/bin/clang を確認する．ここだけ，nixでインストールしたclangを使ってはならない
$ make make -C BaseTools/Source/C
```

## Build

```console
$ cd edk2
$ ln -s ../MikanLoaderPkg ./
$ source edksetup.sh
$ build
```

## Run

```console
$ scrips/run_qemu.sh edk2/Build/MikanLoaderX64/DEBUG_CLANGDWARF/X64/LLoader.efi
```
