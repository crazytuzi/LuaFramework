--[[
地图元素对象池
2015年4月6日22:48:39
haohu
]]

_G.MapObjectPool = {};

MapObjectPool.pool = {}; -- pool
MapObjectPool.maximum = 100; -- pool最大容量

-- @param class:地图元素vo类
function MapObjectPool:GetObject(class)
	local classTable = self.pool[class];
	if classTable and #classTable > 0 then
		return table.remove(classTable);
	end
	return class:new();
end

-- @param class:地图元素vo实例
function MapObjectPool:ReturnObject(elemVO)
	local class = elemVO:GetClass();
	if not self.pool[class] then
		self.pool[class] = {};
	end
	local arr = self.pool[class];
	if #arr < self.maximum then
		table.push( arr, elemVO );
	else
		elemVO:Dispose();
	end
end