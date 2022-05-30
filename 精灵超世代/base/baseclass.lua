
--保存类类型的虚表
local _class = {}

function BaseClass(super)
	-- 生成一个类类型
	local class_type = {}
	-- 在创建对象的时候自动调用
	class_type.__init = false
	class_type.__delete = false
	class_type.super = super
	class_type.New = function(...)
		-- 生成一个类对象
		local obj = {}
		obj._class_type = class_type
		
		-- 在初始化之前注册基类方法
		setmetatable(obj, {__index = _class[class_type]})
		
		-- 调用初始化方法
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.__init then
					c.__init(obj, ...)
				end
			end
			
			create(class_type, ...)
		end
		
		-- 注册一个delete方法
		obj.DeleteMe = function(self)
			local now_super = self._class_type
			while now_super ~= nil do	
				if now_super.__delete then
					now_super.__delete(self)
				end
				now_super = now_super.super
			end
		end
		
		return obj
	end
	
	local vtbl = {}
	_class[class_type] = vtbl
	
	setmetatable(class_type, {__newindex =
	function(t, k, v)
		vtbl[k] = v
	end
	,
	__index = vtbl, --For call parent method
	})
	
	if super then
		setmetatable(vtbl, {__index =
			function(t, k)
				-- 上报报错
				if _class[super] == nil or k == nil then
					return {}
				end
				local ret = _class[super][k]
				--do not do accept, make hot update work right!
				-- vtbl[k] = ret
				return ret
			end
		})
	end
	
	return class_type
end

local parentG = {}
local requireList = NewModelFile or {}
local loading_module_list = {}
setmetatable(_G, parentG)
parentG.__index = function(t, k)
	local require_name = requireList[k]
	if require_name and not loading_module_list[require_name] then
		-- print("加载", require_name, k)
		requireList[k] = nil
		loading_module_list[require_name] = true
		local load_state = require(require_name)
		if type(load_state) == "boolean" then
			return _G[k]
		else
			return load_state
		end
	end
end

function setUpLocalizedData(k)
	local lanCode = cc.Application:getInstance():getCurrentLanguageCode()
	--local lanCode = GetLanguageCode()
	local localizedDataKey = firstToUpper(lanCode)..k
	if _G["Config"][localizedDataKey] then
		for subname,subtable in pairs(_G["Config"][localizedDataKey]) do
			if string.find(subname, "_table") == nil then

				local localizedSubType = type(_G["Config"][localizedDataKey][subname])
				local subType = type(_G["Config"][k][subname])
				if localizedSubType ~= subType then
					print(string.format("Error:%s@%s should be a [%s], current is [%s]", localizedDataKey, subname, subType, localizedSubType))
				end

				if localizedSubType == "table" then

					local key_depth = _G["Config"][localizedDataKey][subname.."_key_depth"]
					if key_depth == 1 then
						for subk, subv in pairs(_G["Config"][k][subname]) do

							if type(_G["Config"][localizedDataKey][subname][subk]) == "string" then
								_G["Config"][k][subname][subk] = _G["Config"][localizedDataKey][subname][subk]						
							elseif type(subv) == "table" and type(_G["Config"][localizedDataKey][subname][subk]) == "table" then
								for kk,vv in pairs(_G["Config"][localizedDataKey][subname][subk]) do
									_G["Config"][k][subname][subk][kk] = vv
								end
							else
								print("WTF___how did this happened? A", k, subname, type(subv), type(_G["Config"][localizedDataKey][subname][subk]))
							end

						end
					elseif key_depth == 2 then
						for subk, subv in pairs(_G["Config"][k][subname]) do
							for subkk,subvv in pairs(_G["Config"][k][subname][subk]) do
								if type(_G["Config"][localizedDataKey][subname][subk][subkk]) == "string" then
									_G["Config"][k][subname][subk][subkk] = _G["Config"][localizedDataKey][subname][subk][subkk]						
								elseif type(subvv) == "table" and type(_G["Config"][localizedDataKey][subname][subk][subkk]) == "table" then
									for kk,vv in pairs(_G["Config"][localizedDataKey][subname][subk][subkk]) do
										_G["Config"][k][subname][subk][subkk][kk] = vv
									end
								else
									print("WTF___how did this happened? B", k, subname, type(subvv), type(_G["Config"][localizedDataKey][subname][subk][subkk]))
								end
							end
						end
					elseif key_depth == 3 then
						for subk, subv in pairs(_G["Config"][k][subname]) do
							for subkk,subvv in pairs(_G["Config"][k][subname][subk]) do
								for subkkk,subvvv in pairs(_G["Config"][k][subname][subk][subkk]) do
									if type(_G["Config"][localizedDataKey][subname][subk][subkk][subkkk]) == "string" then
										_G["Config"][k][subname][subk][subkk][subkkk] = _G["Config"][localizedDataKey][subname][subk][subkk][subkkk]						
									elseif type(subvvv) == "table" and type(_G["Config"][localizedDataKey][subname][subk][subkk][subkkk]) == "table" then
										for kk,vv in pairs(_G["Config"][localizedDataKey][subname][subk][subkk][subkkk]) do
											_G["Config"][k][subname][subk][subkk][subkkk][kk] = vv
										end
									else
										print("WTF___how did this happened? C", k, subname, type(subvvv), type(_G["Config"][localizedDataKey][subname][subk][subkk][subkkk]))										
									end
								end
							end

						end
					end

					
				elseif localizedSubType == "function" then
					local origin_func = _G["Config"][k][subname]
					local localized_func = _G["Config"][localizedDataKey][subname]
					_G["Config"][k][subname] = function(key)
						local origin_data = origin_func(key)
						local localized_data = localized_func(key)

						if origin_data and localized_data then
							for kk, vv in pairs(localized_data) do
								origin_data[kk] = vv
							end
						end
						return origin_data
					end
				end
			end			
		end
	end
end

local parentGC = {}
local loading_config_module_list = {}
Config = Config or {}
setmetatable(_G["Config"], parentGC)
parentGC.__index = function(t, k)
	if not k then return end
	local k2 = "Config_" .. k
	local require_name = requireList[k2]
	if require_name and not loading_module_list[require_name] then
		-- print("加载配置", require_name, k2)
		requireList[k2] = nil
		loading_module_list[require_name] = true
		local load_state = require(require_name)
		if type(load_state) == "boolean" then
			--add by chenbin:处理多语言,将多语言子table合并进原始子table
			--TODO:新表格多语言多份配置，不再需要合并
			-- setUpLocalizedData(k)
			----------------------------------
			return _G["Config"] [k]
		else
			return load_state
		end
	end
end

-- 这个虚表重启的时候要清掉，不然越来越大
function clearSuperClass()
	_class = {}
	parentG = {}
	parentGC = {}
	requireList = {}
	loading_module_list = {}
	loading_config_module_list = {}
end

-- 获取指定对象虚表
function getSuperClass(class_type)
	return _class[class_type]
end
