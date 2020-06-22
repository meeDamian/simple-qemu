# Magic strings

My `enable.sh` script uses `qemu-binfmt-conf.sh` from official `qemu` repo, but [some parts] of it confused me.  So here's my attempt at clarifying what are the _magic_s within.

[some parts]: https://github.com/qemu/qemu/blob/06c4cc3660b366278bdc7bc8b6677032d7b1118c/scripts/qemu-binfmt-conf.sh#L9-L137

## Magics

All info from https://en.wikipedia.org/wiki/Executable_and_Linkable_Format#File_header

> **NOTE:** `\x7fELF => \x7f\x45\x4c\x46`

> **NOTE_1:** Gap means value from the base-line to be used.

> **NOTE_2:** Starting with `offset>=10` all fields follow Big/Little Endian specified in `offset=5`. 

```text
#  0-3     4    5     6  7   8                9                 10        12    # byte offset
#  / \  64bit BE/LE  /   |   |     /          |           \    TYPE=2    ARCH
# ⌄⌄⌄⌄⌄  ⌄⌄⌄  ⌄⌄⌄  ⌄⌄⌄  ⌄⌄⌄ ⌄⌄⌄   ⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄   ⌄⌄⌄⌄⌄⌄   ⌄⌄⌄⌄⌄⌄
\x7fELF \x01 \x01 \x01 \x00\x00 \x00\x00\x00\x00\x00\x00\x00 \x00\x00 \x00\x00  # base; not valid

             \x02                                                \x02     \x08  # mips, mipsn32
                                                             \x02     \x08      # mips LE, mipsn32 LE
        \x02 \x02                                                \x02     \x08  # mips64
        \x02                                                 \x02     \x08      # mips64 LE

                                                             \x02     \xf3      # riscv32
        \x02                                                 \x02     \xf3      # riscv64

                                                             \x02     \x28      # arm
             \x02                                                \x02     \x28  # arm BE

                                                             \x02     \x2a      # sh4
             \x02                                                \x02     \x2a  # sh4 BE

                                                             \x02     \x5e      # xtensa
             \x02                                                \x02     \x5e  # xtensa BE

             \x02                                                \x02     \x14  # ppc
        \x02 \x02                                                \x02     \x15  # ppc64
        \x02                                                 \x02     \x15      # ppc64 LE

        \x02                                                 \x02     \xb7      # aarch64
        \x02 \x02                                                \x02     \xb7  # aarch64 BE

             \x02                                            \x02     \xba\xab  # microblaze
                                                             \x02     \xab\xba  # microblaze LE

             \x02                                                \x02     \x02  # sparc
             \x02                                                \x02     \x12  # sparc32plus
        \x02 \x02                                                \x02     \x2b  # sparc64

                                                             \x02     \x03      # i386
                                                             \x02     \x06      # i486
        \x02                                                 \x02     \x3e      # x86_64
        \x02                                                 \x02     \x26\x90  # alpha
        \x02 \x02                                                \x02     \x16  # s390x
             \x02                                                \x02     \x04  # m68k
             \x02                                                \x02     \x0f  # hppa
             \x02                                                \x02     \x5c  # or1k
```

## Masks

```text
  len of ELF magic    64bit  BE/LE                                       TYPE    ARCH
  ⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄    ⌄⌄⌄  ⌄⌄⌄                                       ⌄⌄⌄⌄⌄⌄⌄  ⌄⌄⌄⌄⌄⌄⌄
\xff\xff\xff\xff\xff | \xff \xff \x00\xff\xff\xff\xff\xff\xff\xff\xff \xff\xff \xff\xff
                     |                                                    \xfe           # aarch64be armeb hppa mips mips64 mipsn32 or1k ppc ppc64 s390x sh4eb sparc sparc32plus sparc64 xtensaeb
                     |                                                \xfe               # aarch64 arm microblaze microblazeel mips64el mipsel mipsn32el riscv32 riscv64 sh4 xtensa
                     | \xfe \xfe                                      \xfe               # alpha i386 i486 x86_64
                     |                                                \xfe         \x00  # ppc64le
                     |      \xfe                                          \xfe           # m68k
```
