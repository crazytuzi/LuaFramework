local COLOR_RED = ""
local COLOR_BLUE = ""
local COLOR_RESET = ""
local function pretty(obj, recurse)
  local coerceable = function(tbl)
    local meta = getmetatable(tbl)
    return meta and meta.__tostring
  end
  if type(obj) == "string" then
    return string.format("%q", obj)
  elseif type(obj) == "table" and not coerceable(obj) and not recurse then
    local str = "{"
    for k, v in pairs(obj) do
      local pair = pretty(k, true) .. " = " .. pretty(v, true)
      str = str .. (str == "{" and pair or ", " .. pair)
    end
    return str .. "}"
  else
    local success, value = pcall(function()
      return tostring(obj)
    end)
    return success and value or "<!!error in __tostring metamethod!!>"
  end
end
local help_message = [[
[return] - re-run last command
c(ontinue) - contiue execution
s(tep) - step forward by one line (into functions)
n(ext) - step forward by one line (skipping over functions)
p(rint) [expression] - execute the expression and print the result
f(inish) - step forward until exiting the current function
u(p) - move up the stack by one frame
d(own) - move down the stack by one frame
t(race) - print the stack trace
l(ocals) - print the function arguments, locals and upvalues.
h(elp) - print this message
]]
local LOCAL_STACK_LEVEL = 6
local stack_top = 0
local stack_offset = 0
local dbg
local function dbg_read(prompt)
  dbg.write(prompt)
  local input = LuaConsole.ConsoleRead()
  return input
end
local dbg_write = function(str, ...)
  LuaConsole.ConsoleWrite(string.format(str, ...))
end
local function dbg_writeln(str, ...)
  dbg.write((str or "") .. "\n", ...)
end
local search_func_name = function(info, stackLevel)
  local func_name = info.name or "Anonymous"
  if func_name == "func" then
    local upStackInfo = debug.getinfo(stackLevel + 3)
    if upStackInfo ~= nil then
      local i = 1
      while true do
        local name, value = debug.getupvalue(upStackInfo.func, i)
        if not name then
          break
        end
        if name == "methodName" then
          return value
        end
        i = i + 1
      end
    end
  end
  return func_name
end
local function format_stack_frame_info(info, stackLevel)
  local fname = search_func_name(info, stackLevel)
  return string.format(COLOR_BLUE .. "%s:%d" .. COLOR_RESET .. " in '%s'", info.short_src, info.currentline, fname)
end
local repl
local function hook_factory(repl_threshold)
  return function(offset)
    return function(event, _)
      local info = debug.getinfo(2)
      if event == "call" and info.linedefined >= 0 then
        offset = offset + 1
      elseif event == "return" and info.linedefined >= 0 then
        if offset <= repl_threshold then
        else
          offset = offset - 1
        end
      elseif event == "line" and offset <= repl_threshold then
        repl()
      end
    end
  end
end
local hook_step = hook_factory(1)
local hook_next = hook_factory(0)
local hook_finish = hook_factory(-1)
local table_merge = function(t1, t2)
  local tbl = {}
  for k, v in pairs(t1) do
    tbl[k] = v
  end
  for k, v in pairs(t2) do
    tbl[k] = v
  end
  return tbl
end
local function local_bindings(offset, include_globals)
  local level = stack_offset + offset + LOCAL_STACK_LEVEL
  local func = debug.getinfo(level).func
  local bindings = {}
  do
    local i = 1
    repeat
      local name, value = debug.getupvalue(func, i)
      if name then
        bindings[name] = value
      end
      i = i + 1
    until name == nil
  end
  do
    local i = 1
    repeat
      local name, value = debug.getlocal(level, i)
      if name then
        bindings[name] = value
      end
      i = i + 1
    until name == nil
  end
  local varargs = {}
  do
    local i = -1
    repeat
      local name, value = debug.getlocal(level, i)
      table.insert(varargs, value)
      i = i - 1
    until name == nil
  end
  if #varargs ~= 0 then
    bindings["..."] = varargs
  end
  if include_globals then
    local env = _VERSION <= "Lua 5.1" and getfenv(func) or bindings._ENV
    return setmetatable(table_merge(env or {}, bindings), {__index = _G})
  else
    return bindings
  end
end
local compile_chunk = function(expr, env)
  local source = "debugger.lua REPL"
  if _VERSION <= "Lua 5.1" then
    local chunk = loadstring("return " .. expr, source)
    if chunk then
      setfenv(chunk, env)
    end
    return chunk
  else
    return load("return " .. expr, source, "t", env)
  end
end
local unpack = unpack or table.unpack
local function cmd_print(expr)
  local env = local_bindings(1, true)
  local chunk = compile_chunk(expr, env)
  if chunk == nil then
    dbg.writeln(COLOR_RED .. "Error: Could not evaluate expression." .. COLOR_RESET)
    return false
  end
  local results = {
    pcall(chunk, unpack(rawget(env, "...") or {}))
  }
  if not results[1] then
    dbg.writeln(COLOR_RED .. "Error:" .. COLOR_RESET .. " %s", results[2])
  elseif #results == 1 then
    dbg.writeln(COLOR_BLUE .. expr .. COLOR_RED .. " => " .. COLOR_BLUE .. "<no result>" .. COLOR_RESET)
  else
    local result = ""
    for i = 2, #results do
      result = result .. (i ~= 2 and ", " or "") .. pretty(results[i])
    end
    dbg.writeln(COLOR_BLUE .. expr .. COLOR_RED .. " => " .. COLOR_RESET .. result)
  end
  return false
end
local function cmd_up()
  local info = debug.getinfo(stack_offset + LOCAL_STACK_LEVEL + 1)
  if info then
    stack_offset = stack_offset + 1
  else
    dbg.writeln(COLOR_BLUE .. "Already at the top of the stack." .. COLOR_RESET)
  end
  dbg.writeln("Inspecting stack: " .. format_stack_frame_info(debug.getinfo(stack_offset + LOCAL_STACK_LEVEL), stack_offset + LOCAL_STACK_LEVEL))
  return false
end
local function cmd_down()
  if stack_offset > stack_top then
    stack_offset = stack_offset - 1
  else
    dbg.writeln(COLOR_BLUE .. "Already at the bottom of the stack." .. COLOR_RESET)
  end
  dbg.writeln("Inspecting stack: " .. format_stack_frame_info(debug.getinfo(stack_offset + LOCAL_STACK_LEVEL), stack_offset + LOCAL_STACK_LEVEL))
  return false
end
local function trackbackex(stackLevel)
  for i = stackLevel + 1, math.huge do
    local info = debug.getinfo(i)
    if not info then
      return
    end
    local stackInfo = i .. " - " .. format_stack_frame_info(debug.getinfo(i), i)
    dbg.writeln(stackInfo)
  end
end
local function cmd_trace()
  local location = format_stack_frame_info(debug.getinfo(stack_offset + LOCAL_STACK_LEVEL), stack_offset + LOCAL_STACK_LEVEL)
  local message = string.format("Inspecting stack: %d - (%s)", stack_top + LOCAL_STACK_LEVEL + 1, location)
  dbg.writeln(message)
  trackbackex(stack_top + LOCAL_STACK_LEVEL)
  return false
end
local function cmd_locals()
  local bindings = local_bindings(1, false)
  local keys = {}
  for k, _ in pairs(bindings) do
    table.insert(keys, k)
  end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local v = bindings[k]
    if not rawequal(v, dbg) and k ~= "_ENV" and k ~= "(*temporary)" then
      dbg.writeln("\t" .. COLOR_BLUE .. "%s " .. COLOR_RED .. "=>" .. COLOR_RESET .. " %s", k, pretty(v))
    end
  end
  return false
end
local last_cmd = false
local function match_command(line)
  local commands = {
    ["c"] = function()
      return true
    end,
    ["s"] = function()
      return true, hook_step
    end,
    ["n"] = function()
      return true, hook_next
    end,
    ["f"] = function()
      return true, hook_finish
    end,
    ["p%s?(.*)"] = cmd_print,
    ["u"] = cmd_up,
    ["d"] = cmd_down,
    ["t"] = cmd_trace,
    ["l"] = cmd_locals,
    ["h"] = function()
      dbg.writeln(help_message)
      return false
    end
  }
  for cmd, cmd_func in pairs(commands) do
    local matches = {
      string.match(line, "^(" .. cmd .. ")$")
    }
    if matches[1] then
      return cmd_func, select(2, unpack(matches))
    end
  end
end
local function run_command(line)
  if line == nil then
    dbg.writeln()
    return true
  end
  if line == "" then
    if last_cmd then
      line = last_cmd
    else
      return false
    end
  else
    last_cmd = line
  end
  local command, command_arg = match_command(line)
  if command then
    return unpack({
      command(command_arg)
    })
  else
    dbg.writeln(COLOR_RED .. "Error:" .. COLOR_RESET .. " command '%s' not recognized", line)
    return false
  end
end
function repl()
  dbg.writeln(format_stack_frame_info(debug.getinfo(LOCAL_STACK_LEVEL - 3 + stack_top), LOCAL_STACK_LEVEL - 3 + stack_top))
  repeat
    local success, done, hook = pcall(run_command, dbg.read(COLOR_RED .. "debugger.lua> " .. COLOR_RESET))
    if success then
      debug.sethook(hook and hook(0), "crl")
    else
      local message = string.format(COLOR_RED .. [[
INTERNAL DEBUGGER.LUA ERROR. ABORTING
:]] .. COLOR_RESET .. " %s", done)
      dbg.writeln(message)
      error(message)
    end
  until done
end
dbg = setmetatable({}, {
  __call = function(self, condition, offset)
    if condition then
      return
    end
    offset = offset or 0
    stack_offset = offset
    stack_top = offset
    debug.sethook(hook_next(1), "crl")
    return
  end
})
dbg.read = dbg_read
dbg.write = dbg_write
dbg.writeln = dbg_writeln
dbg.pretty = pretty
function dbg.error(err, level)
  level = level or 1
  dbg.writeln(COLOR_RED .. "Debugger stopped on error:" .. COLOR_RESET .. "(%s)", pretty(err))
  dbg(false, level)
  error(err, level)
end
function dbg.assert(condition, message)
  if not condition then
    dbg.writeln(COLOR_RED .. "Debugger stopped on " .. COLOR_RESET .. "assert(..., %s)", message)
    dbg(false, 1)
  end
  assert(condition, message)
end
function dbg.call(f, l)
  return (xpcall(f, function(err)
    dbg.writeln(COLOR_RED .. "Debugger stopped on error: " .. COLOR_RESET .. pretty(err))
    dbg(false, (l or 0) + 1)
    return
  end))
end
function dbg.msgh(...)
  dbg.write(...)
  dbg(false, 1)
  return ...
end
if jit then
  dbg.writeln(COLOR_RED .. "debugger.lua: Loaded for " .. jit.version .. COLOR_RESET)
elseif _VERSION == "Lua 5.2" or _VERSION == "Lua 5.1" then
  dbg.writeln(COLOR_RED .. "debugger.lua: Loaded for " .. _VERSION .. COLOR_RESET)
else
  dbg.writeln(COLOR_RED .. "debugger.lua: Not tested against " .. _VERSION .. COLOR_RESET)
  dbg.writeln(COLOR_RED .. "Please send me feedback!" .. COLOR_RESET)
end
local stdin_isatty = true
local stdout_isatty = true
local ffi = jit and require("ffi")
if ffi then
  ffi.cdef([[
		bool isatty(int);
		void free(void *ptr);
		
		char *readline(const char *);
		int add_history(const char *);
	]])
  stdin_isatty = ffi.C.isatty(0)
  stdout_isatty = ffi.C.isatty(1)
end
local color_maybe_supported = stdout_isatty and os.getenv("TERM") and os.getenv("TERM") ~= "dumb"
if color_maybe_supported and not os.getenv("DBG_NOCOLOR") then
  COLOR_RED = string.char(27) .. "[31m"
  COLOR_BLUE = string.char(27) .. "[34m"
  COLOR_RESET = string.char(27) .. "[0m"
end
local dbg_readline
pcall(function()
  if ffi and stdin_isatty and not os.getenv("DBG_NOREADLINE") then
    do
      local readline = ffi.load("readline")
      function dbg_readline(prompt)
        local cstr = readline.readline(prompt)
        if cstr ~= nil then
          local str = ffi.string(cstr)
          if string.match(str, "[^%s]+") then
            readline.add_history(cstr)
          end
          ffi.C.free(cstr)
          return str
        else
          return nil
        end
      end
      dbg.read = dbg_readline
      dbg.writeln(COLOR_RED .. "debugger.lua: Readline support enabled." .. COLOR_RESET)
    end
  end
end)
return dbg
