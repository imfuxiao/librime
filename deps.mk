# a minimal build of third party libraries for static linking

rime_root = $(CURDIR)
src_dir = $(rime_root)/deps

ifndef NOPARALLEL
export MAKEFLAGS+=" -j$$(( $$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 8) + 1)) "
endif

build ?= build
prefix ?= $(rime_root)

rime_deps = glog googletest leveldb marisa-trie opencc yaml-cpp

.PHONY: all clean clean-dist clean-src $(rime_deps)

all: $(rime_deps)

clean: clean-src clean-dist

clean-dist:
	git rev-parse --is-inside-work-tree > /dev/null && \
	find $(prefix)/bin $(prefix)/include $(prefix)/lib $(prefix)/share \
	-depth -maxdepth 1 \
	-exec bash -c 'git ls-files --error-unmatch "$$0" > /dev/null 2>&1 || rm -rv "$$0"' {} \; || true
	rmdir $(prefix) 2> /dev/null || true

# note: this won't clean output files under bin/, include/, lib/ and share/.
clean-src:
	for dep in $(rime_deps); do \
		rm -r $(src_dir)/$${dep}/$(build) || true; \
	done

glog:
	cd $(src_dir)/glog; \
	cmake . -B$(build) \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DBUILD_TESTING:BOOL=OFF \
	-DWITH_GFLAGS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

googletest:
	cd $(src_dir)/googletest; \
	cmake . -B$(build) \
	-DBUILD_GMOCK:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

leveldb:
	cd $(src_dir)/leveldb; \
	cmake . -B$(build) \
	-DLEVELDB_BUILD_BENCHMARKS:BOOL=OFF \
	-DLEVELDB_BUILD_TESTS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

marisa-trie:
	cd $(src_dir)/marisa-trie; \
	cmake . -B$(build) \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install

opencc:
ifndef RIME_IOS_CROSS_COMPILING
	cd $(src_dir)/opencc; \
	cmake . -B$(build) \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
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
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
	&& cmake --build build --target install \
	&& rm $(prefix)/lib/libopencc.a || true \
	&& echo "Cross compiling..." \
	&& export PATH=$(prefix)/bin:$$PATH && echo $$PATH \
	&& cmake . -B$(build)/opencc_arm64 \
	-DBUILD_SHARED_LIBS:BOOL=OFF \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
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
	-DCMAKE_INSTALL_PREFIX:PATH="$(prefix)" \
	$(RIME_CMAKE_FLAGS) \
	&& cmake --build $(build) --target install
