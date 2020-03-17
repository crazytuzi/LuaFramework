--[[
帮派副本model
2015年1月8日14:37:26
haohu
]]

_G.UnionDungeonModel = Module:new();

UnionDungeonModel.dungeonList = {};

function UnionDungeonModel:Init()
	self:SetDungeonList( t_guildActivity );
end

function UnionDungeonModel:SetDungeonList( dungeonList )
	self.dungeonList = dungeonList;
	self:sendNotification( NotifyConsts.UnionDungeonListUpdate );
end

function UnionDungeonModel:GetDungeonList()
	return self.dungeonList;
end

function UnionDungeonModel:GetDungeon(id)
	return self.dungeonList[id];
end