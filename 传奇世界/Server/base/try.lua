--[[try.lua
Note:
	用于捕获异常,安全运行代码,提供类似try..catch..finally机制.

Exported API:
	throw(exception)
	error(exception)
	try(statement)

Example:
	print("begin")

	try{
		function()
			print("try outer")

			try{
				function()
					print("try inner")
					assert(false, "Haha Error!")
					print("no execute inner")
				end
			,catch = {
				{AssertException,
					function(ex)
						print(ex, ex:getMessage())
						throw(Exception("New Error", ex))
					end
				},
			}
			,finally = function()
				print("finally inner")
			end}

			print("no execute outer")
		end
	,catch = {
		{Exception,
			function(ex)
				print(ex, ex:getMessage())
			end
		},
	}
	,finally = function()
		print("finally outer")
	end}

	print("end")
--]]

local try_flag = 0

local raw_throw = assert

local function raw_error(ex)
	if try_flag == 0 then
		ex:printStackTrace()
		raw_throw(nil, ex:tostring())
	else
		raw_throw(nil, toString(ex))
	end
end

function error(ex)
	if not instanceof(ex, Exception) then
		raw_error(Exception(ex))
	end
	raw_error(ex)
end

throw = error

function assert(condition, msg)
	if not condition then
		print(string.format("Error Message: %s\n%s", tostring(msg), debug.traceback()))
		throw(AssertException(msg))
	else
		return condition
	end
end

function try(statement)
	try_flag = try_flag + 1
	local status, result = pcall(statement[1])
	try_flag = try_flag - 1
	if status then
		return result
	end

	local catched = false
	local ex = (type(result) == "string") and RuntimeException(result) or result
	for i, item in ipairs(statement.catch) do
		if instanceof(ex, item[1]) then
			result = item[2](ex)
			catched = true
			break
		end
	end
	if type(statement.finally) == "function" then
		result = statement.finally() or result
	end
	if not catched then
		error(result)
	end
	return result
end

function safeCall(method, ...)
	local args = {...}
	local status, result = false
	try {
		function()
			if type(method)=="function" then
				result = method(unpack(args))
				status = true
			else
				print(string.format("safeCall error. method=%s\n%s", tostring(method), debug.traceback()))
			end
		end
	, catch = {
		{Exception,
			function(ex)
				print(string.format("catch safeCall error. method=%s\n%s", tostring(method), debug.traceback()))
				print(ex:getMessage())
			end
		}
	}}
	return status, result
end