--[[
	2016年1月4日11:47:25
	wangyanwei
	圣灵镶嵌VO
]]

_G.HallowsVO = {};

function HallowsVO:new()
	local obj = setmetatable({},{__index = self})
	obj.id = 0;				--圣器ID
	obj.openHole = 0;		--开启格子数量
	obj.sortList = {};		--圣灵镶嵌信息
	return obj;
end

--圣灵是否开启
function HallowsVO:GetOpen()
	local id = self.id;
	local binghunCfg = t_binghun[id];
	if not binghunCfg then return end
	return BingHunUtil:GetIsBingHunActive(id);
end

--获取格子镶嵌信息
function HallowsVO:GetSortList()
	return self.sortList;
end

--获取开启格子数量
function HallowsVO:GetOpenHole()
	return self.openHole;
end

--获取总级数
function HallowsVO:GetAllLevel()
	local level = 0;
	for i , v in pairs(self.sortList) do
		if t_binghungem[v.id] then
			level = level + t_binghungem[v.id].gem;
		end
	end
	return level;
end