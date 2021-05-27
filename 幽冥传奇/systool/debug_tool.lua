
local print = print

-- 打印普通日志
function Log(...)
	print(...)
end

-- 测试日志
function LogT(...)
	-- print(...)
end

-- 会打印栈信息
function DebugLog(...)
	print(debug.traceback() .. "\n\t[Debug]", ...)
end

-- 错误日志，会打印栈信息
function ErrorLog(...)
	print(debug.traceback() .. "\n\t[Error]", ...)
end

-- 格式化输出字符串，类似c函数printf风格
function Printf(fmt, ...)
	print(string.format(fmt, ...))
end

-- 打印一个table
function PrintTable(tbl, level)
	if nil == tbl or "table" ~= type(tbl) then
		print("[PrintTable] arg is nil or not a table!!!")
		return
	end

	level = level or 1

	local indent_str = ""
	for i = 1, level do
		indent_str = indent_str.."  "
	end

	print(indent_str .. "{")
	for k,v in pairs(tbl) do
		local item_str = string.format("%s%s = %s", indent_str .. "  ", tostring(k), tostring(v))
		print(item_str)
		if type(v) == "table" then
			PrintTable(v, level + 1)
		end
	end
	print(indent_str .. "}")
end

-- 自动打印table
function Print(...)
	print(...)
	local count = select('#', ...)
	local param = {...}
	for i = 1, count do
		if nil == param[i] or "table" ~= type(param[i]) then
			-- print(i .. " = ", param[i])
		else
			print(i .. " = table")
			PrintTable(param[i])
		end
	end
end

function OutputTable(tbl, level)
	if logi == nil then
		PrintTable(tbl, level)
	else
		if nil == tbl or "table" ~= type(tbl) then
			logi("[PrintTable] arg is nil or not a table!!!")
			return
		end
		
		level = level or 1
		
		local indent_str = ""
		for i = 1, level do
			indent_str = indent_str.."  "
		end
		
		logi(indent_str .. "{")
		for k,v in pairs(tbl) do
			local item_str = string.format("%s%s = %s", indent_str .. "  ", tostring(k), tostring(v))
			logi(item_str)
			if type(v) == "table" then
				OutputTable(v, level + 1)
			end
		end
		logi(indent_str .. "}")
	end
end
