PREFIX=/usr/local
default: gensol
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
libgensol/src/gensol.cpp.o: $(shell $(CXX) -MM ./src/gensol.cpp -std=c++11 -I./include | tr '\n' ' ' | tr '\\' ' ' | perl -pe 's/.*://')
	@mkdir -p `dirname $@`
	@echo "Compile $<"
	@$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
libgensol: .output/libgensol/libgensol.a
.output/libgensol/libgensol.a: libgensol/src/gensol.cpp.o
	@mkdir -p `dirname $@`
	@echo "Link $@"
	@$(AR) rc $@ libgensol/src/gensol.cpp.o
install.libgensol: libgensol
	@mkdir -p $(PREFIX)/include
	@echo "Install ./include/gensol.h"
	@install -m 0644 ./include/gensol.h $(PREFIX)/include/`basename ./include/gensol.h`
	@mkdir -p $(PREFIX)/lib
	@echo "Install .outputlibgensol/libgensol.a"
	@install -m 0644 .outputlibgensol/libgensol.a $(PREFIX)/lib/`basename .outputlibgensol/libgensol.a`
clean:
	@echo "Remove objects"
	@-rm -f libgensol/src/gensol.cpp.o libgensol/src/gensol.cpp.o
	@echo "Remove outputs"
	@-rm -f .output/libgensol/libgensol.a .output/libgensol/libgensol.a
.PHONY: clean
install: install.libgensol install.libgensol
.PHONY: install
viewcompiler:
	@echo "c compiler: $(CC)"
	@echo "c++ compiler: $(CXX)"
	@echo "archive linker: $(AR)"
.PHONY: viewcompiler
