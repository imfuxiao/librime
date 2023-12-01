# a minimal build of third party libraries for static linking

rime_root = $(CURDIR)
src_dir = $(rime_root)/deps

ifndef NOPARALLEL
export MAKEFLAGS+=" -j$(( $(nproc) + 1)) "
endif

build ?= build

rime_deps = glog gtest leveldb marisa opencc yaml-cpp

.PHONY: all clean-src $(rime_deps)

all: $(rime_deps)

# note: this won't clean output files under include/, lib/ and bin/.
clean-src:
	rm -r $(src_dir)/glog/build || true
	rm -r $(src_dir)/googletest/build || true
	rm -r $(src_dir)/leveldb/build || true
	rm -r $(src_dir)/marisa-trie/build || true
	rm -r $(src_dir)/opencc/build || true
	rm -r $(src_dir)/yaml-cpp/build || true

glog:
	cd $(src_dir)/glog; \
	cmake . -B$(build) \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DBUILD_TESTING:BOOL=OFF \
	-DWITH_GFLAGS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

gtest:
	cd $(src_dir)/googletest; \
	cmake . -B$(build) \
	-DBUILD_GMOCK:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

leveldb:
	cd $(src_dir)/leveldb; \
	cmake . -B$(build) \
	-DLEVELDB_BUILD_BENCHMARKS:BOOL=OFF \
	-DLEVELDB_BUILD_TESTS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

marisa:
	cd $(src_dir)/marisa-trie; \
	cmake . -B$(build) \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

opencc:
ifndef RIME_IOS_CROSS_COMPILING
	cd $(src_dir)/opencc; \
	cmake . -B$(build) \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install
else
	# 对于iOS交叉编译，opencc是一个特例。
	# opencc产生libopencc.a 和 可执行opencc_dict，构建时用来它生成字典。
	# 这意味着我们必须编译两次opencc。
	# 首先针对主机可执行文件 opencc-dict 生成字典。
	# 然后交叉编译生成libopencc.a
	cd $(src_dir)/opencc; \
	cmake . -B$(build) \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	&& cmake --build build --target install \
	&& rm $(rime_root)/lib/libopencc.a || true \
	&& echo "Cross compiling..." \
	&& export PATH=$(rime_root)/bin:$$PATH && echo $$PATH \
	&& cmake . -B$(build)/opencc_arm64 \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build)/opencc_arm64 --target install
endif

yaml-cpp:
	cd $(src_dir)/yaml-cpp; \
	cmake . -B$(build) \
	-DYAML_CPP_BUILD_CONTRIB:BOOL=OFF \
	-DYAML_CPP_BUILD_TESTS:BOOL=OFF \
	-DYAML_CPP_BUILD_TOOLS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(rime_root)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install
