PREFIX=/usr/local
default:
libgensol/src/gensol.cpp.o: $(shell $(CXX) -MM ./src/src/gensol.cpp -std=c++11 -I./src/include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./src/include -g -Ofast -Wall -Wextra
libgensol: .output/libgensol/libgensol.a
.output/libgensol/libgensol.a: libgensol/src/gensol.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(AR) rc $@ libgensol/src/gensol.cpp.o
install.libgensol: libgensol
	@mkdir -p $(PREFIX)/include
	@echo "Install ./src/include/gensol.h"
	@install -m 0644 ./src/include/gensol.h $(PREFIX)/include/`basename ./src/include/gensol.h`
	@mkdir -p $(PREFIX)/lib
	@echo "Install .outputlibgensol/libgensol.a"
	@install -m 0644 .outputlibgensol/libgensol.a $(PREFIX)/lib/`basename .outputlibgensol/libgensol.a`
gensol/src/main.cpp.o: $(shell $(CXX) -MM ./src/main.cpp -std=c++11 -I./include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
gensol: .output/gensol/gensol
.output/gensol/gensol: libgensol gensol/src/main.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(CXX) -o $@ gensol/src/main.cpp.o -L.outputlibgensol -lgensol -g -Ofast
install.gensol: gensol
	@mkdir -p $(PREFIX)/bin
	@echo "Install .outputgensol/gensol"
	@install -m 0755 .outputgensol/gensol $(PREFIX)/bin/`basename .outputgensol/gensol`
clean:
	@echo "Remove objects"
	@-rm -f libgensol/src/gensol.cpp.o gensol/src/main.cpp.o
	@echo "Remove outputs"
	@-rm -f .output/libgensol/libgensol.a .output/gensol/gensol
.PHONY: clean
install: install.libgensol install.gensol
.PHONY: install
viewcompiler:
	@echo "c compiler: $(CC)"
	@echo "c++ compiler: $(CXX)"
	@echo "archive linker: $(AR)"
.PHONY: viewcompiler
