-- ----------------------------------
-- 性能测试
-- hosr
-- ----------------------------------
ZTest = ZTest or {}

-- 检查是否存在ItemSlot未释放
-- hosr
ZTest.ItemSlotTab = {}
function ZTest.CheckItemSlot()
	local count = 0
	local count1 = 0
	for k,v in pairs(ZTest.ItemSlotTab) do
		if BaseUtils.is_null(v.gameObject) then
			count = count + 1
			print(v.trace)
		else
			count1 = count1 + 1
		end
	end

	Log.Error(string.format("未正常释放的ItemSlot数量=%s", count))
	Log.Error(string.format("使用中的ItemSlot数量=%s", count1))
end

-- 检查是否存在SkillSlot未释放
-- hosr
ZTest.SkillSlotTab = {}
function ZTest.CheckSkillSlot()
	local count = 0
	local count1 = 0
	for k,v in pairs(ZTest.SkillSlotTab) do
		if BaseUtils.is_null(v.gameObject) then
			count = count + 1
			print(v.trace)
		else
			count1 = count1 + 1
		end
	end

	Log.Error(string.format("未正常释放的SkillSlot数量=%s", count))
	Log.Error(string.format("使用中的SkillSlot数量=%s", count1))
end

ZTest.Look_G = function()
	local __g = _G
	local str = ""
	for k,v in pairs(__g) do
		local num = 0
		if type(v) == "table"then
			for _,vv in pairs(v) do
				num = num + 1
			end
			str = string.format("%s \n%s(table) : %s", str, tostring(k), num)
		else
			str = string.format("%s \n%s : %s", str, tostring(k), type(v))
		end
	end
	LocalSaveManager.Instance:writeFile("Look_G.lua", str, "/Users/huangzefeng/Documents")
end

ZTest.GetRef = function(obj, result)
	local readed = {}
	local pathList = {}
	local __g = _G
	for k,v in pairs(__g) do
		readed[v] = true
		if type(v) == "table" or type(k) == "table" and string.sub(tostring(k), 1, 4) ~= "Data" then
			if type(v) == "table" then
				ZTest.Find(readed, obj, v, "_G", pathList)
				pcall(function()
					if v.Instance ~= nil then
						readed[v.Instance] = true
						local str = string.format("_G.%s.Instance", tostring(k))
						ZTest.Find(readed, obj, v.Instance, str, pathList)
					end
				end)
			else
				ZTest.Find(readed, obj, k, "_G", pathList)
				pcall(function()
					if k.Instance ~= nil then
						readed[k.Instance] = true
						local str = string.format("_G.%s.Instance", tostring(k))
						ZTest.Find(readed, obj, v.Instance, str, pathList)
					end
				end)
			end
		elseif obj == v then
			print("_G")
			print("\n")
		elseif obj == k then
			print("_G")
		else
		end
	end
	local str = ""
	for i,v in ipairs(pathList) do
		str = string.format("%s\n%s", str, v)
	end
	if result then
		result = string.format("%s\n%s", result, str)
		return result
	end
	local savepath = "/tmp"
	if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor then
		savepath = nil
	end
	LocalSaveManager.Instance:writeFile("Ref.lua", str, savepath)
	if savepath then
		print("搜索完成，结果保存在"..savepath)
	else
		print("搜索完成，结果保存在"..ctx.ResourcesPath.."/chatLog/")
	end
end

ZTest.Find = function(rectable, obj, currtable, up_path, pathList)
	local tabletype = "table"
	for k,v in pairs(currtable) do
		if v == obj or k == obj then
			if up_path == nil then
				return true, "_G"
			else
				if type(k) == "table" then
					table.insert(pathList, string.format("%s/(tablekey)%s", up_path, tostring(v)))
					local subpath = string.format("%s/%s", up_path, "self")
					ZTest.Find(rectable, obj, k, subpath, pathList)
					return true, subpath
				else
					table.insert(pathList, string.format("%s/%s", up_path, tostring(k)))
					-- local subpath = string.format("%s/%s", up_path, tostring(k))
					local subpath = string.format("%s/%s", up_path, "self")
					ZTest.Find(rectable, obj, v, subpath, pathList)
					return true, subpath
				end
			end
		elseif not rectable[v] and (type(v) == tabletype or type(k) == tabletype) then
			local subpath = string.format("%s/%s", up_path, tostring(k))
			-- print(subpath)
			if type(v) == tabletype then
				rectable[v] = true
				local find,path = ZTest.Find(rectable, obj, v, subpath, pathList)
				if find == true then
					-- print(string.format("<color='#ff0000'>%s</color>", path))
					table.insert(pathList, path)
				end
			else
				rectable[k] = true
				local find,path = ZTest.Find(rectable, obj, k, subpath, pathList)
				if find == true then
					-- print(string.format("<color='#ff0000'>%s</color>", path))
					table.insert(pathList, path)
				end
			end
		end
	end
	return false
end
