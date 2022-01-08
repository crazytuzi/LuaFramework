module("LuaDoc", package.seeall)

function serialize(t)
    local mark={}
    local assign={}

    local function tb(len, f)
        local ret = ''
        while len > 1 do
            ret = ret .. '       '
            len = len - 1
        end
        if len >= 1 then
            ret = ret .. (f and '├┄┄' or '       ')
        end
        return ret
    end

    local function table2str(t, parent, deep)
        deep = deep or 0       
        mark[t] = parent
        local ret = {}
        table.foreach(t, function(f, v)
            local k = type(f)=="number" and "["..f.."]" or '["' .. tostring(f) .. '"]'
            local dotkey = parent..(type(f)=="number" and k or "."..k)
            local t = type(v)
            if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
                table.insert(ret, string.format("%s=%q", k, tostring(v)))
            elseif t == "table" then
                if mark[v] then
                    table.insert(assign, dotkey.."="..mark[v])
                else
                    table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey, deep + 1)))
                end
            elseif t == "string" then
                table.insert(ret, string.format("%s=%q", k, v))
                --table.insert(ret, string.format("%s=[[%s]]", k, v))
            elseif t == "number" then
                if v == math.huge then
                    table.insert(ret, string.format("%s=%s", k, "math.huge"))
                elseif v == -math.huge then
                    table.insert(ret, string.format("%s=%s", k, "-math.huge"))
                else
                    table.insert(ret, string.format("%s=%s", k, tostring(v)))
                end
            else
                table.insert(ret, string.format("%s=%s", k, tostring(v)))
            end
        end)
        return "{\n" .. tb(deep + 1) .. table.concat(ret,",\n" .. tb(deep + 1)) .. '\n' .. tb(deep) .."}"
    end

    if type(t) == "table" then
        local str = string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))
        return str
    else
        return tostring(t)
    end
end

function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end

function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end

function string.mfind (str, pat)
	local i, j = 0, 1
	local ret = {}
	repeat
		i, j = string.find(str, pat, j)
		if i then
			ret[#ret + 1] = string.sub(str, i, j)
		else
			break
		end
	until not i
	return ret
end

function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(str, delimiter, pos) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function printt(tb)
	print(tb, " = {")
	for k, v in pairs(tb) do
		print('\t[', k, '] = [', v, ']')
	end
	print("}")
end

function pt(tb)
    print(serialize(tb))
end

function table.count(tab)
    local cnt = 0
    for _, _ in pairs(tab) do
        cnt = cnt + 1
    end
    return cnt
end

function scandirwin(directory, t)
   local popen = io.popen
   directory = directory or '.'
   i = i or 0
   t = t or {}
   for filename in popen('dir "'..directory..'" /b /a-d-h-s'):lines() do
      local path = directory .. '/' .. filename
      t[#t + 1] = {name = filename, path = path}
   end
   for filename in popen('dir "'..directory..'" /b /ad-h-s'):lines() do
      scandirwin(directory .. '/' .. filename, t)
   end
   return t
end

function write(szPath, str, mode)
   mode = mode or 'w'
   local file = io.open(szPath, mode)
   str = 'local t = ' .. str .. '\n\nreturn t'
   file:write(str)
   io.close(file)
end

function readFile(path)
	local f = io.open(path, 'r')
	local text = f:read("*all")
	f:close()
	return text
end

function run(dir, isWriteFile)
	local files = scandirwin(dir)
	local fileContents = {}
	for k, v in pairs(files) do
		local name = v.name
        print(name)
		name = string.gsub(name, "%..*", "")
		fileContents[name] = readFile(v.path)
	end

	local ret = {}
	for k, v in pairs(fileContents) do
		local ms = work(k, v)
		ret[#ret + 1] = ms
	end
	return ret
end

function work(name, text)
	local ms = {}
	text = string.gsub(text, "%-%-%[%[%-%-(.-)%]%](.-function )(.-)%)", function (cmt, _, func) 
		cmt = string.trim(cmt)
		if func then
			func = func .. ')'
		end
		ms[func] = cmt
		return _ .. func
	end)

	ms["default"] = ''
	text = string.gsub(text, "%-%-%[%[%-%-(.-)%]%]", function (cmt) 
		cmt = string.trim(cmt)
		ms["default"] = ms["default"] .. (ms["default"] == '' and '' or '\n') .. cmt
	end)

    ms.__fileName = name
	return ms
end

function runWithLuaCode(dir, isWriteFile)
    local tRet = run(dir, isWriteFile)

    local tConfig = {}

    local szLabel = ""
 .. "\t\t{\n"
 .. "\t\t\tclassname = 'TFLabel',\n"
 --.. "\t\t\tobjectname = '',\n"
 .. "\t\t\ttext = [[%s]],\n"
 .. "\t\t\tcolor = %s,\n"
 .. "\t\t\tfontSize = 20,\n"
 .. "\t\t\tlayout = {\n"
 .. "\t\t\t\ttype = 'line',\n"
 .. "\t\t\t\tgravity = TF_L_GRAVITY_LEFT,\n"
 .. "\t\t\t\tmargin = '0, 0, 0, %d',\n"
 .. "\t\t\t}\n"
 .. "\t\t},\n"

    for k, v in pairs(tRet) do
        tConfig[v.__fileName] = ''
        local str = tConfig[v.__fileName]

        str = str .. "\n{components = {{\n\tclassname='TFPanel',\n\tlayout = {type = 'line',gravity = TF_L_GRAVITY_LEFT,margin = '0, 0, 0, 20',},\n\tlayoutType = TF_LAYOUT_LINEAR_VERTICAL,\n\twidth = 800,\n\theight = 600,\n\tcomponents = {\n"
        str = str 
        for name, cmt in pairs(v) do
            if name ~= '__fileName' and cmt ~= '' then
                local szCmt = string.format(szLabel, cmt, '0xFF00FF', 5)
                local szName = string.format(szLabel, name, '0xFF0000', 25)
                str = str .. szCmt .. '\n'
                str = str ..szName .. '\n'
            end
        end
        str = str .. '\n\t},\n}}}'
        tConfig[v.__fileName] = str
    end
    return tConfig
end

--[[--
    这是一个测试
]]

return LuaDoc