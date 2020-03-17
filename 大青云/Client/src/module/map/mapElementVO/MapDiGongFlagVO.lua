--[[
地图元素：地宫争夺战地图单位
]]

_G.MapDiGongFlagVO = MapElementVO:new();
MapDiGongFlagVO.unitType = nil; -- 1柱子1，2柱子2
MapDiGongFlagVO.state = nil; -- 柱子状态

function MapDiGongFlagVO:ParseFlag( flag )
	self.unitType = flag.unitType;
	self.state = flag.state;
end

function MapDiGongFlagVO:GetClass()
	return MapDiGongFlagVO;
end

function MapDiGongFlagVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_UnionDiGongWar or mapName == MapConsts.MapName_Curr or
			mapName == MapConsts.MapName_Small then
		return true;
	end
	return false;
end

function MapDiGongFlagVO:GetType()
	return MapConsts.Type_UnionDiGongFlag;
end

-- 获取地图图标tips文本
function MapDiGongFlagVO:GetTipsTxt()
	local cfgVo = UnionDiGongModel:GetJianzhuInfo(self.unitType)
	if cfgVo.unionName and cfgVo.unionName ~= "" then 
		return cfgVo.unionName .. "帮派占领"
	end;
	return "暂无帮派占领"
end

function MapDiGongFlagVO:GetAsLinkage(mapName)
	if self.state == 0 then 
		return "UnionDigong_zhuA";
	end;
	if self.state == 1 then  --flag: 王座1
		return "UnionDigong_zhuB";
	end
	return "";
end