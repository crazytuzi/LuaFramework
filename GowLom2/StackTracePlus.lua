local _G = _G
local string = string
local io = io
local debug = debug
local coroutine = coroutine
local tostring = tostring
local print = print
local require = require
local next = next
local assert = assert
local pcall = pcall
local type = type
local pairs = pairs
local ipairs = ipairs
local error = error

assert(debug, "debug table must be available at this point")

local io_open = io.open
local string_gmatch = string.gmatch
local string_sub = string.sub
local table_concat = table.concat
local _M = {
	max_tb_output_len = 70
}
local m_known_tables = {
	[_G] = "_G (global table)"
}

local function add_known_module(name, desc)
	local ok, mod = pcall(require, name)

	if ok then
		m_known_tables[mod] = desc
	end

	return 
end

slot21("string", "string module")
add_known_module("io", "io module")
add_known_module("os", "os module")
add_known_module("table", "table module")
add_known_module("math", "math module")
add_known_module("package", "package module")
add_known_module("debug", "debug module")
add_known_module("coroutine", "coroutine module")
add_known_module("bit32", "bit32 module")
add_known_module("bit", "bit module")
add_known_module("jit", "jit module")

if "Lua 5.3" <= _VERSION then
	add_known_module("utf8", "utf8 module")
end

local m_user_known_tables = {}
local m_known_functions = {}

for _, name in ipairs({
	"assert",
	"collectgarbage",
	"dofile",
	"error",
	"getmetatable",
	"ipairs",
	"load",
	"loadfile",
	"next",
	"pairs",
	"pcall",
	"print",
	"rawequal",
	"rawget",
	"rawlen",
	"rawset",
	"require",
	"select",
	"setmetatable",
	"tonumber",
	"tostring",
	"type",
	"xpcall",
	"gcinfo",
	"getfenv",
	"loadstring",
	"module",
	"newproxy",
	"setfenv",
	"unpack"
}) do
	if _G[name] then
		m_known_functions[_G[name]] = name
	end
end

local m_user_known_functions = {}

local function safe_tostring(value)
	local ok, err = pcall(tostring, value)

	if ok then
		return err
	else
		return "<failed to get printable value>: '%s'":format(err)
	end

	return 
end

local function ParseLine(line)
	assert(type(line) == "string")

	local match = line.match(line, "^%s*function%s+(%w+)")

	if match then
		return match
	end

	match = line.match(line, "^%s*local%s+function%s+(%w+)")

	if match then
		return match
	end

	match = line.match(line, "^%s*local%s+(%w+)%s+=%s+function")

	if match then
		return match
	end

	match = line.match(line, "%s*function%s*%(")

	if match then
		return "(anonymous)"
	end

	return "(anonymous)"
end

local function GuessFunctionName(info)
	if type(info.source) == "string" and info.source:sub(1, 1) == "@" then
		local file, err = io_open(info.source:sub(2), "r")

		if not file then
			print("file not found: " .. tostring(err))

			return "?"
		end

		local line = nil

		for _ = 1, info.linedefined, 1 do
			line = file.read(file, "*l")
		end

		if not line then
			print("line not found")

			return "?"
		end

		return ParseLine(line)
	else
		local line = nil
		local lineNumber = 0

		for l in string_gmatch(info.source, "([^\n]+)\n-") do
			lineNumber = lineNumber + 1

			if lineNumber == info.linedefined then
				line = l

				break
			end
		end

		if not line then
			print("line not found")

			return "?"
		end

		return ParseLine(line)
	end

	return 
end

local Dumper = {
	new = function (thread)
		local t = {
			lines = {}
		}

		for k, v in pairs(Dumper) do
			t[k] = v
		end

		t.dumping_same_thread = thread == coroutine.running()

		if type(thread) == "thread" then
			t.getinfo = function (level, what)
				if t.dumping_same_thread and type(level) == "number" then
					level = level + 1
				end

				return debug.getinfo(thread, level, what)
			end
			t.getlocal = function (level, loc)
				if t.dumping_same_thread then
					level = level + 1
				end

				return debug.getlocal(thread, level, loc)
			end
		else
			t.getinfo = debug.getinfo
			t.getlocal = debug.getlocal
		end

		return t
	end,
	add = function (self, text)
		self.lines[#self.lines + 1] = text

		return 
	end,
	add_f = function (self, fmt, ...)
		self.add(self, fmt.format(fmt, ...))

		return 
	end,
	concat_lines = function (self)
		return table_concat(self.lines)
	end,
	DumpLocals = function (self, level)
		local prefix = "\t "
		local i = 1

		if self.dumping_same_thread then
			level = level + 1
		end

		local name, value = self.getlocal(level, i)

		if not name then
			return 
		end

		self.add(self, "\tLocal variables:\r\n")

		while name do
			if type(value) == "number" then
				self.add_f(self, "%s%s = number: %g\r\n", prefix, name, value)
			elseif type(value) == "boolean" then
				self.add_f(self, "%s%s = boolean: %s\r\n", prefix, name, tostring(value))
			elseif type(value) == "string" then
				self.add_f(self, "%s%s = string: %q\r\n", prefix, name, value)
			elseif type(value) == "userdata" then
				self.add_f(self, "%s%s = %s\r\n", prefix, name, safe_tostring(value))
			elseif type(value) == "nil" then
				self.add_f(self, "%s%s = nil\r\n", prefix, name)
			elseif type(value) == "table" then
				if m_known_tables[value] then
					self.add_f(self, "%s%s = %s\r\n", prefix, name, m_known_tables[value])
				elseif m_user_known_tables[value] then
					self.add_f(self, "%s%s = %s\r\n", prefix, name, m_user_known_tables[value])
				else
					local txt = "{"

					for k, v in pairs(value) do
						txt = txt .. safe_tostring(k) .. ":" .. safe_tostring(v)

						if _M.max_tb_output_len < #txt then
							txt = txt .. " (more...)"

							break
						end

						if next(value, k) then
							txt = txt .. ", "
						end
					end

					self.add_f(self, "%s%s = %s  %s\r\n", prefix, name, safe_tostring(value), txt .. "}")
				end
			elseif type(value) == "function" then
				local info = self.getinfo(value, "nS")
				local fun_name = info.name or m_known_functions[value] or m_user_known_functions[value]

				if info.what == "C" then
					self.add_f(self, "%s%s = C %s\r\n", prefix, name, (fun_name and "function: " .. fun_name) or tostring(value))
				else
					local source = info.short_src

					if source.sub(source, 2, 7) == "string" then
						source = source.sub(source, 9)
					end

					fun_name = fun_name or GuessFunctionName(info)

					self.add_f(self, "%s%s = Lua function '%s' (defined at line %d of chunk %s)\r\n", prefix, name, fun_name, info.linedefined, source)
				end
			elseif type(value) == "thread" then
				self.add_f(self, "%sthread %q = %s\r\n", prefix, name, tostring(value))
			end

			i = i + 1
			name, value = self.getlocal(level, i)
		end

		return 
	end
}
_M.stacktrace = function (thread, message, level)
	if type(thread) ~= "thread" then
		level = message
		message = thread
		thread = nil
	end

	thread = thread or coroutine.running()
	level = level or 1
	local dumper = Dumper.new(thread)
	local original_error = nil

	if type(message) == "table" then
		dumper.add(dumper, "an error object {\r\n")

		local first = true

		for k, v in pairs(message) do
			if first then
				dumper.add(dumper, "  ")

				first = false
			else
				dumper.add(dumper, ",\r\n  ")
			end

			dumper.add(dumper, safe_tostring(k))
			dumper.add(dumper, ": ")
			dumper.add(dumper, safe_tostring(v))
		end

		dumper.add(dumper, "\r\n}")

		original_error = dumper.concat_lines(dumper)
	elseif type(message) == "string" then
		dumper.add(dumper, message)

		original_error = message
	end

	dumper.add(dumper, "\r\n")
	dumper.add(dumper, "Stack Traceback\n===============\n")

	local level_to_show = level

	if dumper.dumping_same_thread then
		level = level + 1
	end

	local info = dumper.getinfo(level, "nSlf")

	while info do
		if info.what == "main" then
			if string_sub(info.source, 1, 1) == "@" then
				dumper.add_f(dumper, "(%d) main chunk of file '%s' at line %d\r\n", level_to_show, string_sub(info.source, 2), info.currentline)
			else
				dumper.add_f(dumper, "(%d) main chunk of %s at line %d\r\n", level_to_show, info.short_src, info.currentline)
			end
		elseif info.what == "C" then
			local function_name = m_user_known_functions[info.func] or m_known_functions[info.func] or info.name or tostring(info.func)

			dumper.add_f(dumper, "(%d) %s C function '%s'\r\n", level_to_show, info.namewhat, function_name)
		elseif info.what == "tail" then
			dumper.add_f(dumper, "(%d) tail call\r\n", level_to_show)
			dumper.DumpLocals(dumper, level)
		elseif info.what == "Lua" then
			local source = info.short_src
			local function_name = m_user_known_functions[info.func] or m_known_functions[info.func] or info.name

			if source.sub(source, 2, 7) == "string" then
				source = source.sub(source, 9)
			end

			local was_guessed = false

			if not function_name or function_name == "?" then
				function_name = GuessFunctionName(info)
				was_guessed = true
			end

			local function_type = (info.namewhat == "" and "function") or info.namewhat

			if info.source and info.source:sub(1, 1) == "@" then
				dumper.add_f(dumper, "(%d) Lua %s '%s' at file '%s:%d'%s\r\n", level_to_show, function_type, function_name, info.source:sub(2), info.currentline, (was_guessed and " (best guess)") or "")
			elseif info.source and info.source:sub(1, 1) == "#" then
				dumper.add_f(dumper, "(%d) Lua %s '%s' at template '%s:%d'%s\r\n", level_to_show, function_type, function_name, info.source:sub(2), info.currentline, (was_guessed and " (best guess)") or "")
			else
				dumper.add_f(dumper, "(%d) Lua %s '%s' at line %d of chunk '%s'\r\n", level_to_show, function_type, function_name, info.currentline, source)
			end

			dumper.DumpLocals(dumper, level)
		else
			dumper.add_f(dumper, "(%d) unknown frame %s\r\n", level_to_show, info.what)
		end

		level = level + 1
		level_to_show = level_to_show + 1
		info = dumper.getinfo(level, "nSlf")
	end

	return dumper.concat_lines(dumper), original_error
end
_M.add_known_table = function (tab, description)
	if m_known_tables[tab] then
		error("Cannot override an already known table")
	end

	m_user_known_tables[tab] = description

	return 
end
_M.add_known_function = function (fun, description)
	if m_known_functions[fun] then
		error("Cannot override an already known function")
	end

	m_user_known_functions[fun] = description

	return 
end

return _M
