# Rime with iOS

iOS版本编译参考两个项目

* boostForiOS: https://github.com/apotocki/boost-iosx.git

根据此项目编译iOS版本Boost

基于boostForiOS. 将编译后的Frameworks下文件复制到当前目录下.`deps/boost`

目录结构如下

```
| deps/boost
           | boost : 此目录对应 `boost/frameworks/Headers/boost`
           | stage
                 | lib : 此目录下存放依赖的library文件, 对应install-boost.sh文件内容boost_libs="${boost_libs=filesystem,regex,system}"
                         即: 拷贝 boost/frameworks 下 filesystem,regex,system,atomic 对应的xcframework文件夹下ios-arm64下的*.a文件至此目录
```


* https://github.com/Cantoboard/librime.git

根据此项目修改了makefile文件, 适配iOS版本编译


* ios.toolchain.cmake: https://github.com/leetal/ios-cmake

根据此项目获取了ios.toolchain.cmake文件

## Preparation

Install Xcode with command line tools.

Install other build tools:

``` sh
brew install cmake git
```

## Get the code

``` sh
git clone --recursive https://github.com/rime/librime.git
```
or [download from GitHub](https://github.com/rime/librime), then get code for
third-party dependencies separately.

## Install Boost C++ for iOS libraries

Boost is a third-party library which librime code heavily depend on.
These dependencies include a few compiled (non-header-only) Boost libraries.

**Method 1:** 通过 [boostForiOS](https://github.com/apotocki/boost-iosx.git) 项目编译 iOS版本的 Boost 库

编译完成后, 组织目录文件, 并复制到`deps/boost`下

完毕后设置 boost 环境变量
``` sh
export BOOST_ROOT="$(pwd)/deps/boost"
```

## Build third-party libraries

Required third-party libraries other than Boost are included as git submodules:

``` sh
# cd librime

# if you didn't checked out the submodules with git clone --recursive, now do:
# git submodule update --init

make xcode/ios/deps
```

This builds libraries located at `librime/deps/*`, and installs the build
artifacts to `librime/include`, `librime/lib` and `librime/bin`.

You can also build an individual library, eg. `opencc`, with:

``` sh
make xcode/ios/deps/opencc
```

## Build librime

``` sh
make xcode/ios
```
This creates `build/lib/Release/librime*.dylib` and command line tools
`build/bin/Release/rime_*`.