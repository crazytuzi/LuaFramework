DataMgr = {}

--读取数据（外部接口）
--"key"名称string
function DataMgr.ReadData(key,defaultValue)
	local defaultValueType = type(defaultValue)
	if defaultValueType == "table" then
		local str = DataMgr.WriteLuaTable(defaultValue, 0)
		local tab_str = DataMgr.GetString(key, str)
		--return loadstring(tab_str)()
		-- DataMgr.WriteData(key, defaultValue)
		local tab_str = DataMgr.GetString(key)
		if tab_str==nil or tab_str == "" then
			return nil
		else
			return assert(loadstring("return {" .. tab_str .. "}"))() -- loadstring(tab_str)
		end
	   
		--取string
	elseif defaultValueType == "string" then
		return DataMgr.GetString(key, defaultValue)
		--取数字
	elseif defaultValueType == "number" then
		return DataMgr.GetFloat(key, defaultValue)
		--取布尔
	elseif defaultValueType == "boolean" then
		return DataMgr.GetInt(key,defaultValue)
	end
	return -1
end

--写入数据(外部接口)
--"key"名称string
--"value"数值
function DataMgr.WriteData(key,value)
	local Type = type(value)
	if Type == "table" then
		local str = DataMgr.WriteLuaTable(value, 0)
		DataMgr.SetString(key, str)
	elseif Type == "string" then
		DataMgr.SetString(key, value)
	elseif Type == "number" then
		DataMgr.SetFloat(key, value)
	elseif Type == "boolean" then
		DataMgr.SetInt(key, value==true and 1 or 0)
	end
end

---------------------------------------以下外部不调用-----------------------------------------------
--封装PlayerPrefs,添加新字段时候用这两个参数初始化一下
function DataMgr.SetInt(key,value)
	UnityEngine.PlayerPrefs.SetInt(key,value)
end

function DataMgr.SetString(key,value)
	UnityEngine.PlayerPrefs.SetString(key,value)
end

function DataMgr.SetFloat(key,value)
	UnityEngine.PlayerPrefs.SetFloat(key,value)
end

function DataMgr.GetInt(key,defaultValue)
	return UnityEngine.PlayerPrefs.GetInt(key,defaultValue)
end

function DataMgr.GetString(key,defaultValue)
	return UnityEngine.PlayerPrefs.GetString(key,defaultValue)
end

function DataMgr.GetFloat(key,defaultValue)
	return UnityEngine.PlayerPrefs.GetFloat(key,defaultValue)
end

function DataMgr.DeleteKey(key)
	UnityEngine.PlayerPrefs.DeleteKey(key)
end

-- 检查本地是否有key字段
function DataMgr.HasKey(key)
	return UnityEngine.PlayerPrefs.HasKey(key)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------


--将table转换成string保存起来
function DataMgr.WriteLuaTable(lua_table, indent)
	indent = indent or 0
	local final_str = ""
	for k, v in pairs(lua_table) do
		if type(k) == "string" then
			k = string.format("%q", k)
		end
		local szSuffix = ""
		TypeV = type(v)
		if TypeV == "table" then
			szSuffix = "{"
		end
		local szPrefix = string.rep(" ", indent)
		local formatting = szPrefix.."["..k.."]".." = "..szSuffix
		if TypeV == "table" then
			final_str = final_str .. formatting .. "\n"
			final_str = final_str .. DataMgr.WriteLuaTable(v, indent + 1)
			final_str = final_str .. szPrefix .. "},\n"
		else
			local szValue = ""
			if TypeV == "string" then
				szValue = string.format("%q", v)
			else
				szValue = tostring(v)
			end
		   final_str = final_str  .. formatting .. szValue .. ",\n"
		end
	end
	return final_str
end

