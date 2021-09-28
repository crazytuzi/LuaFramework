local develop_mode = require("editor/develop_mode")
local is_develop = develop_mode:IsDeveloper()

BindTool = BindTool or {}

function BindTool.UnPack(param, count, i, ...)
	if i >= count then
		if i == count then
			return param[i], ...
		end
		return ...
	end
	return param[i], BindTool.UnPack(param, count, i + 1, ...)
end

function BindTool.Bind(func, ...)
	if type(func) ~= "function" then
		print_error("BindTool.Bind error!")
		return function() end
	end

	local count = select('#', ...)
	local param = {...}
	local new_func = nil

	if 0 == count then
		new_func = function(...) return func(...) end
	elseif 1 == count then
		new_func = function(...) return func(param[1], ...) end
	elseif 2 == count then
		new_func = function(...) return func(param[1], param[2], ...) end
	else
		new_func = function(...) return func(BindTool.UnPack(param, count, 1, ...)) end
	end

	if is_develop then
		develop_mode:OnBindFun(param[1], func, new_func)
	end

	return new_func
end

function BindTool.Bind1(func, param1)
	if type(func) ~= "function" then
		print_error("BindTool.Bind1 error!")
		return function() end
	end

	local new_func = function(...)
		return func(param1, ...)
	end

	if is_develop then
		develop_mode:OnBindFun(param1, func, new_func)
	end

	return new_func
end

function BindTool.Bind2(func, param1, param2)
	if type(func) ~= "function" then
		print_error("BindTool.Bind2 error!")
		return function() end
	end
	local new_func = function(...)
		return func(param1, param2, ...)
	end

	if is_develop then
		develop_mode:OnBindFun(param1, func, new_func)
	end

	return new_func
end

function BindTool.Bind3(func, param1, param2, param3)
	if type(func) ~= "function" then
		print_error("BindTool.Bind3 error!")
		return function() end
	end

	local new_func = function(...)
		return func(param1, param2, param3,...)
	end

	if is_develop then
		develop_mode:OnBindFun(param1, func, new_func)
	end

	return new_func
end

function BindTool.Bind4(func, param1, param2, param3, param4)
	if type(func) ~= "function" then
		print_error("BindTool.Bind4 error!")
		return function() end
	end
	
	local new_func = function(...)
		return func(param1, param2, param3, param4, ...)
	end

	if is_develop then
		develop_mode:OnBindFun(param1, func, new_func)
	end

	return new_func
end
