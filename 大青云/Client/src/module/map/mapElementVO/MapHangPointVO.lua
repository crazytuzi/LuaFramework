--[[
地图元素：挂机点
2015年4月12日11:51:08
haohu
]]

_G.MapHangPointVO = MapElementVO:new();

MapHangPointVO.flag = nil; --flag: 黄金挂机点3，安全挂机点4

function MapHangPointVO:GetClass()
	return MapHangPointVO;
end

function MapHangPointVO:GetType()
	return MapConsts.Type_Hang;
end

-- 获取地图图标tips文本
function MapHangPointVO:GetTipsTxt()
	if self.flag == 3 then
		return StrConfig['map117'];
	elseif self.flag == 4 then
		return StrConfig['map118'];
	end
end

function MapHangPointVO:GetAsLinkage()
	if self.flag == 3 then
		return "hang_best";
	elseif self.flag == 4 then
		return "hang_safe";
	end
end