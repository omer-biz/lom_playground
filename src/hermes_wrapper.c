#include <emscripten/emscripten.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <stdio.h>
#include <string.h>

#include "effect.h"
#include "parser.h"

static lua_State *G_L = NULL;

int hermes_init(void) {
  if (G_L)
    return 0;

  lua_State *L = luaL_newstate();
  if (!L) {
    return 0;
  }

  luaL_openlibs(L);

  luaopen_parser_core(L);

  lua_getglobal(L, "package");
  lua_getfield(L, -1, "path");

  luaL_requiref(L, "parser.core", luaopen_parser_core, 1);
  lua_pop(L, 1);

  G_L = L;

  return 1;
}

EMSCRIPTEN_KEEPALIVE
Effect *hermes_run(const char *script, const char *input) {
  if (!G_L) {
    fprintf(stderr, "[hermes] not initialized");
    return 0;
  }

  lua_pushstring(G_L, input);
  lua_setglobal(G_L, "_INPUT");

  int top_before = lua_gettop(G_L);
  if (luaL_dostring(G_L, script) != LUA_OK) {
    fprintf(stderr, "Lua error: %s\n", lua_tostring(G_L, -1));
    lua_pop(G_L, 1);
    return 0;
  }
  int top_after = lua_gettop(G_L);

  if (top_after == top_before) {
    printf("returned nothing\n");
    return NULL;
  }

  int type = lua_type(G_L, -1);

  if (type == LUA_TNIL) {
    printf("returned nil\n");
    lua_pop(G_L, 1);
    return NULL;
  }

  if (type != LUA_TTABLE) {
    printf("returned non table thing\n");
    lua_pop(G_L, 1);
    return NULL;
  }

  lua_getfield(G_L, -1, "kind");
  if (lua_isnil(G_L, -1)) {
    printf("returned unknown table\n");
    lua_pop(G_L, 2);
    return NULL;
  }
  lua_pop(G_L, 1);

  Effect *e = parse_effect(G_L, -1);
  lua_pop(G_L, 1);

  printf("returning: %p", e);
  return e;
}

void hermes_close(void) {
  if (G_L) {
    lua_close(G_L);
    G_L = NULL;
  }
}
