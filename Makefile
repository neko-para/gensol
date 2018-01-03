PREFIX=/usr/local
default: gensol
build.libgensol/src/gensol.cpp.o: $(shell $(CXX) -MM ./src/src/gensol.cpp -std=c++11 -I./src/include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./src/include -g -Ofast -Wall -Wextra
libgensol: .output/libgensol/libgensol.a
.PHONY: libgensol
.output/libgensol/libgensol.a: build.libgensol/src/gensol.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(AR) rc $@ build.libgensol/src/gensol.cpp.o
install.libgensol: libgensol
	@mkdir -p $(PREFIX)/include
	@echo "Install ./src/include/gensol.h"
	@install -m 0644 ./src/include/gensol.h $(PREFIX)/include/`basename ./src/include/gensol.h`
	@mkdir -p $(PREFIX)/lib
	@echo "Install .output/libgensol/libgensol.a"
	@install -m 0644 .output/libgensol/libgensol.a $(PREFIX)/lib/`basename .output/libgensol/libgensol.a`
.PHONY: install.libgensol
build.gensol/src/main.cpp.o: $(shell $(CXX) -MM ./src/main.cpp -std=c++11 -I./include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
gensol: .output/gensol/gensol
.PHONY: gensol
.output/gensol/gensol: libgensol build.gensol/src/main.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(CXX) -o $@ build.gensol/src/main.cpp.o -L.output/libgensol -lgensol -g -Ofast
install.gensol: gensol
	@mkdir -p $(PREFIX)/bin
	@echo "Install .output/gensol/gensol"
	@install -m 0755 .output/gensol/gensol $(PREFIX)/bin/`basename .output/gensol/gensol`
.PHONY: install.gensol
clean:
	@echo "Remove objects"
	@-rm -f build.libgensol/src/gensol.cpp.o build.gensol/src/main.cpp.o
	@echo "Remove outputs"
	@-rm -f .output/libgensol/libgensol.a .output/gensol/gensol
.PHONY: clean
install: install.libgensol install.gensol
.PHONY: install
viewcompiler:
	@echo "c compiler: $(CC)"
	@echo "c++ compiler: $(CXX)"
	@echo "assembly compiler: $(AS)"
	@echo "archive linker: $(AR)"
.PHONY: viewcompiler
