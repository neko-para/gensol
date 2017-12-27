libgensol/src/gensol.cpp.o: $(shell $(CXX) -MM ./src/gensol.cpp -std=c++11 -I./include | perl -pe 's/.*://')
	mkdir -p `dirname $@`
	$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
libgensol: libgensol/libgensol.a
.PHONY: libgensol
libgensol/libgensol.a: libgensol/src/gensol.cpp.o
	mkdir -p `dirname $@`
	$(AR) rc $@ libgensol/src/gensol.cpp.o
gensol/src/main.cpp.o: $(shell $(CXX) -MM ./src/main.cpp -std=c++11 -I./include | perl -pe 's/.*://')
	mkdir -p `dirname $@`
	$(CXX) -c -o $@ $< -std=c++11 -I./include -g -Ofast -Wall -Wextra
gensol: gensol/gensol
.PHONY: gensol
gensol/gensol: libgensol gensol/src/main.cpp.o
	mkdir -p `dirname $@`
	$(CXX) -o $@ gensol/src/main.cpp.o -Llibgensol -lgensol -g -Ofast
