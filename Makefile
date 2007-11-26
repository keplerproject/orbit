# $Id: Makefile,v 1.1.1.1 2007/11/26 17:12:24 mascarenhas Exp $

include config

all:

install:
	mkdir -p $(LUA_DIR)
	cp src/orbit.lua $(LUA_DIR)
	mkdir -p $(LUA_DIR)/orbit
	cp src/model.lua $(LUA_DIR)/orbit
	mkdir -p $(BIN_DIR)
	cp src/orbit $(BIN_DIR)
	if [ -f ./wsapi/Makefile ]; then \
	  cd wsapi && make install; \
	fi

clean:
