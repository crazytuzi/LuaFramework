--[[
地图单位：队长
2015年4月11日17:34:39
haohu
]]

_G.MapPlayerVO = MapElementVO:new();

MapPlayerVO.name         = nil
MapPlayerVO.level        = nil
MapPlayerVO.relationType = nil --队长1，队员2，帮主3，帮派成员4, 北仓界高分玩家5
MapPlayerVO.param        = nil -- prof为5时:北仓界分数

-- flag : MapRelationPlayer
function MapPlayerVO:ParseFlag( flag )
	local mapRelationPlayer = flag
	self.name         = mapRelationPlayer:GetName()
	self.level        = mapRelationPlayer:GetLevel()
	local relation    = mapRelationPlayer:GetRelation()
	self.relationType = relation:GetType()
	self.param        = relation:GetParam()
end

function MapPlayerVO:GetLayer()
	return "middle";
end

function MapPlayerVO:GetClass()
	return MapPlayerVO;
end

function MapPlayerVO:GetType()
	return MapConsts.Type_Player;
end

function MapPlayerVO:GetPosName()
	if self.relationType == MapRelationConsts.TeamCaptain then
		return StrConfig['map112'];
	elseif self.relationType == MapRelationConsts.Teammate then
		return StrConfig['map113'];
	elseif self.relationType == MapRelationConsts.Gangster then
		return StrConfig['map114'];
	elseif self.relationType == MapRelationConsts.Gang then
		return StrConfig['map115'];
	elseif self.relationType == MapRelationConsts.BCJ then
		return ""
	elseif self.relationType == MapRelationConsts.DG_Flag then 
		return StrConfig["map122"]
	else
		return "tool tip missing!"
	end
end

function MapPlayerVO:GetLevel()
	return self.level;
end

-- 获取地图图标tips文本
function MapPlayerVO:GetTipsTxt()
	local posName = self:GetPosName();
	local x, y = self:Get2DPos();
	if self.name == "" then
		return posName;
	else
		return string.format( StrConfig['map116'], posName, self.name, self.level, x, y );
	end
end

--返回玩家显示的图标
function MapPlayerVO:GetAsLinkage()
	if self.relationType == MapRelationConsts.TeamCaptain then
		return "player_captain";
	elseif self.relationType == MapRelationConsts.Teammate then
		return "player_teammate";
	elseif self.relationType == MapRelationConsts.Gangster then
		return "player_gangster";
	elseif self.relationType == MapRelationConsts.Gang then
		return "player_gang";
	elseif self.relationType == MapRelationConsts.BCJ then
		return "player_bcj";
	elseif self.relationType == MapRelationConsts.DG_Flag then
		return "player_captain";
	end
end

function MapPlayerVO:ToString()
	local typeStr = self:GetType();
	return string.format( "%s%s", typeStr, self.cid );
end
