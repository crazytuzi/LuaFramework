


function ItemBeanToLUA(txt)
	local ret = {}
	string.gsub(txt, "<Item(.-)/>", function (props)
		local t = {}
		string.gsub(props, "([^%s]+)%s*=%s*\"([^%s]+)\"", function (key, val)
			if key and val then
				t[key] = val
			end
		end)
		ret[t.monsterId] = t

	end)


	local str = ''
	str = str .. 'local t = {\n'
	for k, v in pairs(ret) do
		str = str .. '\t[\"' .. k .. '"] = {\n'
		for kk, vv in pairs(v) do
			str = str .. '\t\t' .. kk .. ' = \"' .. vv .. '\",\n'
		end
		str = str .. '\t},\n'
		collectgarbage()
	end
	str = str .. '}\nreturn t'
	local file = io.open("./monsterBean.lua", "w")
	file:write(str)
	file:close()
end

function read(path)
	local ret = ''
	if path then
		local file = io.open(path, "r")
		ret = file:read('*all')
	end
	ItemBeanToLUA(ret)
	return ret
end

--read(arg[1])
read('./monsterBean.xml')