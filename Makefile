PREFIX=/usr/local
default: gensol
libgensol/src/gensol.cpp.o: $(shell $(CXX) -MM ./src/gensol.cpp -std=c++11 -I./include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
libgensol: .output/libgensol.a
.output/libgensol.a: libgensol/src/gensol.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(AR) rc $@ libgensol/src/gensol.cpp.o
install.libgensol: libgensol
	@mkdir -p $(PREFIX)/include
	@echo "Install ./include/gensol.h"
	@install -m 0644 ./include/gensol.h $(PREFIX)/include/`basename ./include/gensol.h`
	@mkdir -p $(PREFIX)/lib
	@echo "Install .output/libgensol.a"
	@install -m 0644 .output/libgensol.a $(PREFIX)/lib/`basename .output/libgensol.a`
gensol/src/main.cpp.o: $(shell $(CXX) -MM ./src/main.cpp -std=c++11 -I./include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
gensol: .output/gensol
.output/gensol: libgensol gensol/src/main.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(CXX) -o $@ gensol/src/main.cpp.o -L.output -lgensol -g -Ofast
install.gensol: gensol
	@mkdir -p $(PREFIX)/bin
	@echo "Install .output/gensol"
	@install -m 0755 .output/gensol $(PREFIX)/bin/`basename .output/gensol`
clean:
	@echo "Remove objects"
	@-rm -f libgensol/src/gensol.cpp.o gensol/src/main.cpp.o
	@echo "Remove outputs"
	@-rm -f .output/libgensol.a .output/gensol
.PHONY: clean
install: install.libgensol install.gensol
.PHONY: install
viewcompiler:
	@echo "c compiler: $(CC)"
	@echo "c++ compiler: $(CXX)"
	@echo "archive linker: $(AR)"
.PHONY: viewcompiler
