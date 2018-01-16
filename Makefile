PREFIX=/usr/local
NASM=nasm
MAKEFLAGS+=-s
TOOLPREFIX=
AR=$(TOOLPREFIX)ar
AS=$(TOOLPREFIX)as
LD=$(TOOLPREFIX)ld
CC=$(TOOLPREFIX)gcc
CXX=$(TOOLPREFIX)g++
default: gensol
build.libgensol/src/gensol.cpp.o: $(shell echo -n `echo >&2 "Preparing dependence of ./src/src/gensol.cpp" && $(CXX) -MM ./src/src/gensol.cpp -std=c++11 -I./src/include 2>> gensol.log || echo >&2 "Error! see gensol.log for more details"` | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://' )
	mkdir -p `dirname $@`
	echo "Compile $<"
	$(CXX) -o $@ $< -c -std=c++11 -I./src/include -g -Ofast -Wall -Wextra
libgensol: .output/libgensol/libgensol.a
.PHONY: libgensol
.output/libgensol/libgensol.a: build.libgensol/src/gensol.cpp.o
	mkdir -p `dirname $@`
	echo "Link $@"
	$(AR) rc $@ build.libgensol/src/gensol.cpp.o
install.libgensol: libgensol
	mkdir -p $(PREFIX)/include
	echo "Install ./src/include/gensol.h"
	install -m 0644 ./src/include/gensol.h $(PREFIX)/include/`basename ./src/include/gensol.h`
	mkdir -p $(PREFIX)/lib
	echo "Install .output/libgensol/libgensol.a"
	install -m 0644 .output/libgensol/libgensol.a $(PREFIX)/lib/`basename .output/libgensol/libgensol.a`
.PHONY: install.libgensol
build.gensol/src/main.cpp.o: $(shell echo -n `echo >&2 "Preparing dependence of ./src/main.cpp" && $(CXX) -MM ./src/main.cpp -std=c++11 -I./include 2>> gensol.log || echo >&2 "Error! see gensol.log for more details"` | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://' )
	mkdir -p `dirname $@`
	echo "Compile $<"
	$(CXX) -o $@ $< -c -std=c++11 -I./include -g -Ofast -Wall -Wextra
gensol: .output/gensol/gensol
.PHONY: gensol
.output/gensol/gensol: libgensol build.gensol/src/main.cpp.o
	mkdir -p `dirname $@`
	echo "Link $@"
	$(CXX) -o $@ build.gensol/src/main.cpp.o -L.output/libgensol -lgensol -g -Ofast
install.gensol: gensol
	mkdir -p $(PREFIX)/bin
	echo "Install .output/gensol/gensol"
	install -m 0755 .output/gensol/gensol $(PREFIX)/bin/`basename .output/gensol/gensol`
.PHONY: install.gensol
clean:
	echo "Remove objects"
	-rm -f build.libgensol/src/gensol.cpp.o build.gensol/src/main.cpp.o
	echo "Remove outputs"
	-rm -f .output/libgensol/libgensol.a .output/gensol/gensol
.PHONY: clean
install: install.libgensol install.gensol
.PHONY: install
viewcompiler:
	echo "c compiler: $(CC)"
	echo "c++ compiler: $(CXX)"
	echo "at&t assembly compiler: $(AS)"
	echo "intel assembly compiler: $(NASM)"
	echo "archive linker: $(AR)"
	echo "linker: $(LD)"
.PHONY: viewcompiler
