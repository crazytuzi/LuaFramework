--
-- @Author: LaoY
-- @Date:   2019-07-09 21:59:54
-- 

-- todo
-- 需要添加忽略列表

LuaMemManager = {}
LuaMemManager.__index = LuaMemManager

function LuaMemManager:new()
	local t = setmetatable({}, LuaMemManager)
	t:ctor()
	return t
end

function LuaMemManager:ctor()
	if LuaMemManager.Instance then
		return
	end
	LuaMemManager.Instance = self
	
	self.class_list = {}
	self.class_map = {}
	self.config_map = {}
	self.global_list = {}

	self:Init()

	self:ResetConfig()
	-- self:ResetGlobal()

	LateUpdateBeat:Add(self.Update, self, 4, 10)
end

function LuaMemManager:GetInstance()
	if not LuaMemManager.Instance then
		LuaMemManager()
	end
	return LuaMemManager.Instance
end

local string_gsub = string.gsub
local table_insert = table.insert

function LuaMemManager:Init()
	-- 重写 require
	old_require = require
	local ingore_config_map = {
		["FightConfig"] = true,
	}

	local ignore_list = {
		"Ctrl$",
		"Constant$",
		"Model$",
		"Controller$",
		"Manager$",
		"Event$",
		"^Event",
		"BitState",
		"FightConfig",
	}

	require = function(path)
		path = self:GetPath(path)
		local t = string.split(path,".")
		local file_name = t[#t]
		local isConfig = file_name and string.find(file_name,"^db_")
		if not isConfig then
			return old_require(path)
		end
		-- if file_name:find("db_item_10") then
		-- 	Yzprint('--LaoY LuaMemManager.lua,line 71--',data)
		-- end
		if isConfig and string.find(file_name,"_%d+$") then
			 local new_file_name = string.gsub(file_name,"_%d+$","")
			local info = self.config_map[new_file_name]
			if info then
				self.config_map[new_file_name] = nil
			end
			package.loaded[path] = nil
			return old_require(path)
		end
		
		if self.class_map[file_name] or self.config_map[file_name] then
			return
		end
		
		-- for k,v in pairs(ignore_list) do
		-- 	if file_name and file_name:find(v) then
		-- 		return old_require(path)
		-- 	end
		-- end

		local info = {is_load = false, path = path , file_name = file_name, last_use_time = 0}
		self.config_map[file_name] = info
		
		-- if isConfig then
		-- 	self.config_map[file_name] = info
		-- else
		-- 	return old_require(path)
		-- end

		-- if string.find(file_name,"^db_") then
		-- 	self.config_map[file_name] = info
		-- 	-- self:UnLoadConfig(info)
		-- elseif string.find(file_name,"^pb_") then
		-- 	self.class_map[file_name] = info
		-- 	table_insert(self.global_list,file_name)
		-- else
		-- 	local l_table = old_require(path)
		-- 	if not l_table or l_table == true then
		-- 		local g_table = _G[file_name]
		-- 		self:UnLoadPath(path)
		-- 		_G[file_name] = nil
		-- 		if g_table then
		-- 			if isClass(g_table) then
		-- 				self.class_map[file_name] = info
		-- 				table_insert(self.class_list,file_name)
		-- 			else
		-- 				self.class_map[file_name] = info
		-- 				table_insert(self.global_list,file_name)
		-- 			end					
		-- 		else
		-- 			-- logError("文件名字和Class名字不同 : ",file_name)
		-- 		end
		-- 		return true
		-- 	end
		-- 	return l_table
		-- end

		return true
	end
end

local rawget = rawget
local rawset = rawset

function LuaMemManager:ResetConfig()
	Config = Config or {}
	setmetatable(Config,{
	    __index = function (t,k,index)
	        local info = self.config_map[k]
	        if info then
	            if not info.is_load then
	                self:ReLoadConfig(info,k)
				end
                info.last_use_time = Time.time
	        end
	        local v = rawget(Config,k)
	        return v
	    end}
	)
end

function LuaMemManager:ResetGlobal()
	setmetatable(_G,{
		__newindex = function (t,k,v) 
            local info = self.class_map[k]
            if v == nil then
                if info then
                    self:UnLoadInfo(info)
                end 
            else
            	if info then
            		info.last_use_time = Time.time
            	end
            end
            rawset(_G ,k ,v)  
        end,

        __index = function (t,k)
            local info = self.class_map[k]
            if info then
            	if not info.is_load then
	                self:ReLoad(info)
	            end
                info.last_use_time = Time.time
            end
            return rawget(_G ,k)
        end}
    )
end

function LuaMemManager:GetPath(path)
	return string_gsub(path,"/",".")
end

local check_config_list
if AppConfig.Debug then
	check_config_list = {
		["db_item"] = 1,
	}
else
	check_config_list = {}
end

function LuaMemManager:ReLoadConfig(info,cfName)
	self:ReLoad(info)
	if AppConfig.Debug and check_config_list[cfName] then
		setmetatable(Config[cfName],{
		    __index = function (t,k,index)
		        local v = rawget(Config[cfName],k)
		        if not v and k then
		        	logError(string.format("【debug】config is nil,the config name is %s,the key is %s",cfName,k))
		        end
		        return v
		    end}
		)
	end
end

function LuaMemManager:ReLoad(info)
	info.is_load = true
    old_require(info.path)
end

function LuaMemManager:UnLoadInfo(info)
	self:UnLoadPath(info.path)
	info.is_load = false
end

function LuaMemManager:UnLoadPath(path)
	local bo = package.loaded[path]
	if bo then
		package.loaded[path] = nil
	end
end

local function is_has_obj(cls)
	return not table.isempty(obj_v_map[cls])
end

local function is_be_super_has_ref(cls)
	return super_v_map[cls] and super_v_map[cls] > 0
end

local function release_super_ref(cls)
	if not super_v_map[cls] then
		return
	end
	super_v_map[cls] = math.max(0,super_v_map[cls]-1)
end

-- 弃用
function LuaMemManager:ClearSuper(cls)
	local super = cls
	while(super)do
		-- local file_name = cls.__cname
		release_super_ref(super)
		-- if self::IsCanReleaseClass(file_name) then

		-- end
		super = super.super
	end
end

function LuaMemManager:UnLoadConfig(info)
	self:UnLoadInfo(info)
	Config[info.file_name] = nil
end

function LuaMemManager:UnLoadGlobal(info)
	self:UnLoadInfo(info)
	_G[info.file_name] = nil
end

function LuaMemManager:CheckConfig()
	local cur_time = Time.time
	for file,info in pairs(self.config_map) do
		if info and info.is_load and cur_time - info.last_use_time >= 60 * 10 then
			self:UnLoadConfig(info)
		end
	end
end

function LuaMemManager:CheckGlobal()
	local cur_time = Time.time
	for k,file_name in pairs(self.global_list) do
		local info = self.class_map[file_name]
		if info and info.is_load and cur_time - info.last_use_time >= 10 then
			self:UnLoadGlobal(info)
		end
	end
end

function LuaMemManager:IsCanReleaseClass(cname)
	local info = self.class_map[cname]
	if info and info.is_load and not super_v_map[cname] then
		local cls = _G[cname]
		if cls and not is_has_obj(cls) and not is_be_super_has_ref(cls) then
			return true
		end
	end
	return false
end

function LuaMemManager:CheckClass()
	local len = #self.class_list
	for i=len,1,-1 do
		local file_name = self.class_list[i]
		if self:IsCanReleaseClass(file_name) then
			-- local cls = _G[file_name]
			-- self:ClearSuper(cls)
			local info = self.class_map[file_name]
			self:UnLoadGlobal(info)
		end
	end
end

function LuaMemManager:Update()
	self:CheckConfig()
	-- self:CheckGlobal()
end

function LuaMemManager:GC()
	Util.ClearMemory()
	
	-- collectgarbage("collect")

	-- self:CheckClass()
	-- self:CheckGlobal()
end

setmetatable(LuaMemManager, {__call = LuaMemManager.new})

