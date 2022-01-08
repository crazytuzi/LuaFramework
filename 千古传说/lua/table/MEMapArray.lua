--[[--
	带Map的数组

	--By: Stephen.tao
	--2013/11/25
]]


MEMapArray = class("MEMapArray", TFArray)


function MEMapArray:ctor()
	self.super.ctor(self)

	self.map = {}
end

--[[--
	在数组末尾插入新的元素
	@param obj: 元素
	@return nil
]]	
function MEMapArray:push(obj)
	self.super.push(self, obj)
	if obj.id then
		self.map[obj.id] = obj
	end
end

--[[--
	在数组末尾插入新的元素
	@param obj: 元素
	@return nil
]]	
function MEMapArray:pushbyid(id,obj)
	self.super.push(self, obj)
	if id then
		self.map[id] = obj
	end
end

function MEMapArray:getMap()
	return self.map;
end

--[[--
	删除数组首元素,并返回其值
	@return 首元素值
]]	
function MEMapArray:popFront()
	local obj = self.super.popFront(self)
	obj = self:getTableObj(obj);
	return obj
end

--[[--
	删除数组末元素,并返回其值
	@return 首元素值
]]	
function MEMapArray:popBack()
	local obj = self.super.popBack(self)
	obj = self:getTableObj(obj);
	return obj
end

--[[--
	返回数组首元素
]]	
function MEMapArray:front()
	local obj = self.super.front(self)
	local tbobj = self:getTableObj(obj);
	if tbobj ~= obj then
		local nIndex = self.head;
		self:removeObjectAt(nIndex)
		self:insertAt(nIndex, tbobj)
	end
	return tbobj
end

--[[--
	返回数组末尾元素
]]	
function MEMapArray:back()
	local obj = self.super.back(self)
	local tbobj = self:getTableObj(obj);
	if tbobj ~= obj then
		local nIndex = self.tail - 1;
		self:removeObjectAt(nIndex)
		self:insertAt(nIndex, tbobj)
	end
	return tbobj
end

--[[--
	返回指定位置索引的元素
	@param nIndex: 索引
	@return 指定位置的元素
]]	
function MEMapArray:getObjectAt(nIndex)
	local obj = self.super.getObjectAt(self,nIndex)
	local tbobj = self:getTableObj(obj);
	if tbobj ~= obj then
		self:removeObjectAt(nIndex)
		self:insertAt(nIndex, tbobj)
	end
	return tbobj
end

--[[--
	返回指定位置索引的元素
	@param nIndex: 索引
	@return 指定位置的元素
]]	
function MEMapArray:objectAt(nIndex)
	local obj = self.super.objectAt(self,nIndex)
	local tbobj = self:getTableObj(obj);
	if tbobj ~= obj then
		self:removeObjectAt(nIndex)
		self:insertAt(nIndex, tbobj)
	end
	return tbobj
end

--[[--
	返回指定Key值的元素
	@param id: Key值
	@return 指定Key值的元素
]]	
function MEMapArray:objectByID(id)
	if id == nil then
		return nil
	end
	local obj = self.map[id];
	obj = self:getTableObj(obj);
	self.map[id] = obj

	return obj;
end

function MEMapArray:getTableObj(obj)
	if obj == nil then
		return nil
	end

	if obj and type(obj) =="string" then
		obj = loadstring('do return ' .. obj .. ' end')()
		if self.item_mt then
			obj.__index = self.item_mt
			setmetatable(obj, self.item_mt)
		end
	end
	return obj;
end

--[[--
	清空数组
]]
function MEMapArray:clear()
	self.super.clear(self)
	self.map = {}
end

--[[--
	删除指定元素
	@param obj: 元素
]]	
function MEMapArray:removeInMapList(obj)
	-- print("self.super = ", self.super)
	self:removeObject(obj)
	if obj then
		local id 		= obj.id
		self.map[id] 	= nil
	end
end
--[[--
	删除指定元素
	@param obj: 元素
]]	
function MEMapArray:removeById(id)
	if self.map[id] then
		self:removeObject(self.map[id])
		self.map[id] 	= nil
	end
end

return MEMapArray