

function split(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end


function start(api)
	local path 
	if IsUnityEditor then
		path = '..\\..\\GameEditors\\UIEdit\\res\\ui_edit\\lua\\design'
	else
		path = '..\\..\\GameEditors\\UIEdit\\res\\ui_edit\\lua_standalone\\design'
	end
	local comand = 'dir /s /b '..path
	local s = io.popen(comand)

	local file_lists = s:read('*all')
	s:close()
	file_lists = split(file_lists,'\n')
	local ret = {}
	for _, v in ipairs(file_lists) do
		local find_index = string.find(v,'.lua',1,true)
		if find_index then
			local file_name = split(v,'\\')
			file_name = file_name[#file_name]
			file_name = split(file_name,'.')[1]
			local check_chunk = split(file_name,'_')
			if #check_chunk > 1 and check_chunk[1] == 'quest' and tonumber(check_chunk[2]) then
				local num = tonumber(check_chunk[2])
				num = math.floor(num / 1000)				
				table.insert(ret,string.format('%s = %d,\n',file_name,num))
			else
				table.insert(ret,string.format('%s = 3,\n',file_name))		
			end		
		end
	end
	local file_path = path..'\\file_list.lua'
	local f = io.open(file_path,'w')
	f:write('--文件名称 类型\n')
	f:write('return {\n')
	f:write(unpack(ret))
	f:write('}')
	f:close()
end
