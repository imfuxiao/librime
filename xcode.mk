RIME_ROOT = $(CURDIR)

dist_dir = $(RIME_ROOT)/dist

ifdef BOOST_ROOT
CMAKE_BOOST_OPTIONS = -DBoost_NO_BOOST_CMAKE=TRUE \
	-DBOOST_ROOT="$(BOOST_ROOT)"
endif

# https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_SYSROOT.html
export SDKROOT ?= $(shell xcrun --sdk macosx --show-sdk-path)

# OS64: to build for iOS (arm64 only)
# OS64COMBINED: to build for iOS & iOS Simulator (FAT lib) (arm64, x86_64)
# SIMULATOR64: to build for iOS simulator 64 bit (x86_64)
# SIMULATORARM64: to build for iOS simulator 64 bit (arm64)
# MAC: to build for macOS (x86_64)
export PLATFORM ?= SIMULATOR64
export DEVELOPMENT_TEAM ?= M4N6995A28
# target min version
export MINVERSION ?= 14
export RIME_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rime
export RIME_API_CCONSOLE_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rimeApiConsole
export RIME_PATCH_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rimePatch
export RIME_CONSOLE_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rimeConsole
export RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rimeDictManager
export RIME_DEPLOYER_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rimeDeployer
export RIME_TEST_BUNDLE_IDENTIFIER ?= dev.fuxiao.apps.rime.librime.rimeTest
# DEVELOPMENT_TEAM: 环境变量, 设置xcode ddevelopment team 参数. eg: export DEVELOPMENT_TEAM=123456
# RIME_BUNDLE_IDENTIFIER: 环境变量, 设置 rime.xcodeproj 的 bundle identifier 值
# RIME_API_CCONSOLE_BUNDLE_IDENTIFIER: 环境变量, 设置 rime_api_console.xcodeproj 的 bundle identifier 值
# RIME_PATCH_BUNDLE_IDENTIFIER: 环境变量, 设置 rime_patch.xcodeproj 的 bundle identifier 值
# RIME_CONSOLE_BUNDLE_IDENTIFIER: 环境变量, 设置 rime_console.xcodeproj 的 bundle identifier 值
# RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER: 环境变量, 设置 rime_dict_manager.xcodeproj 的 bundle identifier 值
# RIME_DEPLOYER_BUNDLE_IDENTIFIER: 环境变量, 设置 rime_deployer.xcodeproj 的 bundle identifier 值
# RIME_TEST_BUNDLE_IDENTIFIER: 环境变量, 设置 rime_test.xcodeproj 的 bundle identifier 值
XCODE_IOS_CROSS_COMPILE_CMAKE_FLAGS = -DCMAKE_TOOLCHAIN_FILE=$(CURDIR)/cmake/toolchain/ios.cmake \
	-DPLATFORM=$(PLATFORM) \
	-DDEPLOYMENT_TARGET=$(MINVERSION) \
	-DENABLE_BITCODE=NO \
	-DDEVELOPMENT_TEAM=$(DEVELOPMENT_TEAM) \
	-DRIME_BUNDLE_IDENTIFIER=$(RIME_BUNDLE_IDENTIFIER) \
	-DRIME_API_CCONSOLE_BUNDLE_IDENTIFIER=$(RIME_API_CCONSOLE_BUNDLE_IDENTIFIER) \
	-DRIME_PATCH_BUNDLE_IDENTIFIER=$(RIME_PATCH_BUNDLE_IDENTIFIER) \
	-DRIME_CONSOLE_BUNDLE_IDENTIFIER=$(RIME_CONSOLE_BUNDLE_IDENTIFIER) \
	-DRIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER=$(RIME_DICT_MANAGER_CCONSOLE_BUNDLE_IDENTIFIER) \
	-DRIME_DEPLOYER_BUNDLE_IDENTIFIER=$(RIME_DEPLOYER_BUNDLE_IDENTIFIER) \
	-DRIME_TEST_BUNDLE_IDENTIFIER=$(RIME_TEST_BUNDLE_IDENTIFIER)

IOS_CROSS_COMPILE_CMAKE_FLAGS = -DCMAKE_SYSTEM_NAME=iOS \
	-DCMAKE_OSX_ARCHITECTURES="arm64" \
	-DCMAKE_OSX_SYSROOT=iphoneos \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$(MINVERSION) \
	-DCMAKE_MACOSX_BUNDLE=NO

SIMULATOR_CROSS_COMPILE_CMAKE_FLAGS = -DCMAKE_SYSTEM_NAME=iOS \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_SYSROOT=iphonesimulator \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$(MINVERSION) \
	-DCMAKE_MACOSX_BUNDLE=NO

# 	-DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \

RIME_COMPILER_OPTIONS = CC=clang CXX=clang++ \
CXXFLAGS="-stdlib=libc++" LDFLAGS="-stdlib=libc++"

ifdef RIME_IOS_CROSS_COMPILING
	RIME_COMPILER_OPTIONS = CC=clang CXX=clang++ \
	CFLAGS="-fembed-bitcode" \
	CXXFLAGS="-stdlib=libc++ -fembed-bitcode" \
	LDFLAGS="-stdlib=libc++ -fembed-bitcode"

	RIME_CMAKE_XCODE_FLAGS=$(XCODE_IOS_CROSS_COMPILE_CMAKE_FLAGS)

	unexport CMAKE_OSX_ARCHITECTURES
	unexport MACOSX_DEPLOYMENT_TARGET
	unexport SDKROOT
else


# https://cmake.org/cmake/help/latest/envvar/MACOSX_DEPLOYMENT_TARGET.html
export MACOSX_DEPLOYMENT_TARGET ?= 10.13

ifdef BUILD_UNIVERSAL
# https://cmake.org/cmake/help/latest/envvar/CMAKE_OSX_ARCHITECTURES.html
export CMAKE_OSX_ARCHITECTURES = arm64;x86_64
endif

endif

# boost::locale library from homebrew links to homebrewed icu4c libraries
icu_prefix = $(shell brew --prefix)/opt/icu4c

debug debug-with-icu test-debug: build ?= debug
build ?= build

.PHONY: all release debug clean dist distclean test test-debug deps thirdparty ios\
release-with-icu debug-with-icu dist-with-icu

all: release

release:
	cmake . -B$(build) -GXcode \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_SEPARATE_LIBS=OFF \
	-DBUILD_STATIC=ON \
	-DENABLE_LOGGING=ON \
	-DALSO_LOG_TO_STDERR=ON \
	-DBUILD_TEST=OFF \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-DCMAKE_INSTALL_PREFIX="$(dist_dir)" \
	-DBUILD_MERGED_PLUGINS=ON \
	-DENABLE_EXTERNAL_PLUGINS=ON \
	$(CMAKE_BOOST_OPTIONS) \
	$(RIME_CMAKE_XCODE_FLAGS)
	cmake --build $(build) --config Release

release-with-icu:
	cmake . -B$(build) -GXcode \
	-DBUILD_STATIC=ON \
	-DBUILD_WITH_ICU=ON \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-DCMAKE_INSTALL_PREFIX="$(dist_dir)" \
	-DCMAKE_PREFIX_PATH="$(icu_prefix)" \
	$(CMAKE_BOOST_OPTIONS) \
	$(RIME_CMAKE_XCODE_FLAGS)
	cmake --build $(build) --config Release

debug:
	cmake . -B$(build) -GXcode \
	-DBUILD_STATIC=ON \
	-DBUILD_SEPARATE_LIBS=ON \
	$(CMAKE_BOOST_OPTIONS) \
	$(RIME_CMAKE_XCODE_FLAGS)
	cmake --build $(build) --config Debug

debug-with-icu:
	cmake . -B$(build) -GXcode \
	-DBUILD_STATIC=ON \
	-DBUILD_SEPARATE_LIBS=ON \
	-DBUILD_WITH_ICU=ON \
	-DCMAKE_PREFIX_PATH="$(icu_prefix)" \
	$(CMAKE_BOOST_OPTIONS) \
	$(RIME_CMAKE_XCODE_FLAGS)
	cmake --build $(build) --config Debug

clean:
	rm -rf build > /dev/null 2>&1 || true
	rm -rf debug > /dev/null 2>&1 || true
	rm build.log > /dev/null 2>&1 || true
	rm -rf lib/* > /dev/null 2>&1 || true
	rm -rf bin/* > /dev/null 2>&1 || true
	$(MAKE) -f deps.mk clean-src

merged-plugins:
	cmake . -B$(build) \
	-DCMAKE_INSTALL_PREFIX=$(prefix) \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_MERGED_PLUGINS=ON \
	-DENABLE_EXTERNAL_PLUGINS=OFF \
	$(CMAKE_BOOST_OPTIONS) \
	$(RIME_CMAKE_XCODE_FLAGS)
	cmake --build $(build)

dist: release
	cmake --build $(build) --config Release --target install

dist-with-icu: release-with-icu
	cmake --build $(build) --config Release --target install

distclean: clean
	rm -rf "$(dist_dir)" > /dev/null 2>&1 || true

test: release
	(cd $(build)/test; DYLD_LIBRARY_PATH=../lib/Release Release/rime_test)

test-debug: debug
	(cd $(build)/test; Debug/rime_test)

# `thirdparty` is deprecated in favor of `deps`
deps thirdparty:
	$(RIME_COMPILER_OPTIONS)  $(MAKE) -f deps.mk

deps/boost thirdparty/boost:
	./install-boost.sh

deps/%:
	$(RIME_COMPILER_OPTIONS)  $(MAKE) -f deps.mk $(@:deps/%=%)

thirdparty/%:
	$(RIME_COMPILER_OPTIONS)  $(MAKE) -f deps.mk $(@:thirdparty/%=%)

ios:
	RIME_IOS_CROSS_COMPILING=true RIME_CMAKE_FLAGS='$(IOS_CROSS_COMPILE_CMAKE_FLAGS)' make -f xcode.mk

ios/%:
	RIME_IOS_CROSS_COMPILING=true RIME_CMAKE_FLAGS='$(IOS_CROSS_COMPILE_CMAKE_FLAGS)' make -f xcode.mk $(@:ios/%=%)

simulator:
	RIME_IOS_CROSS_COMPILING=true RIME_CMAKE_FLAGS='$(SIMULATOR_CROSS_COMPILE_CMAKE_FLAGS)' make -f xcode.mk

simulator/%:
	RIME_IOS_CROSS_COMPILING=true RIME_CMAKE_FLAGS='$(SIMULATOR_CROSS_COMPILE_CMAKE_FLAGS)' make -f xcode.mk $(@:simulator/%=%)
