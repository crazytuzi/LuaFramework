--
-- @Author: LaoY
-- @Date:   2018-12-05 15:22:42
--
CacheManager = CacheManager or class("CacheManager",BaseManager)

local PlayerPrefs = UnityEngine.PlayerPrefs

function CacheManager:ctor()
	CacheManager.Instance = self
	self:Reset()
end

function CacheManager:Reset()

end

function CacheManager.GetInstance()
	if CacheManager.Instance == nil then
		CacheManager()
	end
	return CacheManager.Instance
end

--[[
	@author LaoY
	@des	缓存int
	@param1 key    string
	@return value
--]]
function CacheManager:SetInt(key,value)
	PlayerPrefs.SetInt(key,value)
end

--[[
	@author LaoY
	@des	获取int 缓存
	@param1 key		string
	@param1 default	int 	如果没有缓存，返回的默认值，可以不填。没有缓存且没有默认值时，返回0
	@return number
--]]
function CacheManager:GetInt(key,default)
	if default then
		return PlayerPrefs.GetInt(key,default)
	else
		return PlayerPrefs.GetInt(key)
	end
end

--[[
	@author LaoY
	@des	缓存float
	@param1 key    string
	@return value
--]]
function CacheManager:SetFloat(key,value)
	PlayerPrefs.SetFloat(key,value)
end

--[[
	@author LaoY
	@des	获取float 缓存
	@param1 key		string
	@param1 default	number 	如果没有缓存，返回的默认值，可以不填。没有缓存且没有默认值时，返回0
	@return number
--]]
function CacheManager:GetFloat(key,default)
	if default then
		return PlayerPrefs.GetFloat(key,default)
	else
		return PlayerPrefs.GetFloat(key)
	end
end

--[[
	@author LaoY
	@des	缓存string
	@param1 key    string
	@return value
--]]
function CacheManager:SetString(key,value)
	PlayerPrefs.SetString(key,value)
end

--[[
	@author LaoY
	@des	获取string 缓存
	@param1 key		string
	@param1 default	string 	如果没有缓存，返回的默认值，可以不填。没有缓存且没有默认值时，返回null
	@return number
--]]
function CacheManager:GetString(key,default)
	if default then
		return PlayerPrefs.GetString(key,default)
	else
		return PlayerPrefs.GetString(key)
	end
end


--[[
	@author LaoY
	@des	缓存bool PlayerPrefs没有bool类型。使用约定的int来表达bool，非0为true，0为false
	@param1 key		 string
	@return bool
--]]
function CacheManager:SetBool(key,value)
	CacheManager:SetInt(key,value and 1 or 0)
end

--[[
	@author LaoY
	@des	获取bool 缓存
	@param1 key		string
	@param1 default	string 	如果没有缓存，返回的默认值，可以不填。没有缓存且没有默认值时，返回null。不填又没有缓存，默认是false
	@return number
--]]
function CacheManager:GetBool(key,default)
	if type(default) == "boolean" then
		default = default and 1 or 0
	end
	return CacheManager:GetInt(key,default or 0) ~= 0
end
