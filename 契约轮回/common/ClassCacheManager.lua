-- 
-- @Author: LaoY
-- @Date:   2018-08-08 20:02:53
-- 

ClassCacheManager = ClassCacheManager or {}
ClassCacheManager.__index = ClassCacheManager

function ClassCacheManager:new()
	local t = setmetatable({}, ClassCacheManager)
	t:ctor()
	return t
end

function ClassCacheManager:ctor()
	if ClassCacheManager.Instance then
		return
	end
	ClassCacheManager.Instance = self
	self.cls_list = {}
	self.class_count 	= 0
	self.object_count 	= 0
end

function ClassCacheManager:GetInstance()
	if not ClassCacheManager.Instance then
		ClassCacheManager()
	end
	return ClassCacheManager.Instance
end

function ClassCacheManager:AddClassCacheInfo(cname,count)
	local config = self.cls_list[cname]
	if not config then
		config = {name = cname,count = count , list = list()}
		self.cls_list[cname] = config
		self.class_count = self.class_count + 1
	else
		config.count = count
	end
end

function ClassCacheManager:IsHasCacheInfo(cname)
	return self.cls_list[cname] ~= nil
end

function ClassCacheManager:AddClassCache(cls)
	local config = self.cls_list[cls.__cname]
	if not config then
		return false
	end
	if config.list.length >= config.count  then
		return false
	end
	if cls.__clear then
		cls:__clear()
	end
	cls.__is_clear = true
	config.list:push(cls)
	self.object_count = self.object_count + 1
	return true
end

function ClassCacheManager:GetClassCache(cname)
	local config = self.cls_list[cname]
	if not config then
		return
	end
	local object = config.list:pop()
	if object then
		object.__is_clear = false
		self.object_count = math.max(0,self.object_count - 1)
		if config.list.length == 0 then
			self.class_count =  math.max(0,self.class_count - 1)
		end
	end
	return object
end

function ClassCacheManager:Debug()
	local count = GetLuaMemory()
	logWarn(string.format("当前缓存类数量:%s,缓存对象的数量:%s,当前lua内存为:%sk",self.class_count,self.object_count,count))
end

setmetatable(ClassCacheManager, {__call = ClassCacheManager.new})