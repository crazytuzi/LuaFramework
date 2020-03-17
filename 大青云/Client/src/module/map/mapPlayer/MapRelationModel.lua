--[[
地图需要显示图标的玩家信息model
队长，队友，帮派成员，帮主，北仓界高中低分数段玩家,qizi
2015年6月5日10:28:17
haohu
]]


---------------------------------------------------

_G.MapRelationModel = {};

MapRelationModel.players = {};

function MapRelationModel:UpdateRelationalPlayer( playerList )
	-- list to map
	local newPlayerList = {}
	for _, vo in pairs( playerList ) do
		newPlayerList[vo.roleId] = vo
	end

	-- 遍历原列表，如果不在新列表里面，删除帮派、队伍相关relation
	for roleId, player in pairs( self.players ) do
		if newPlayerList[roleId] == nil then
			player:RemoveRelationByType( MapRelationConsts.TeamCaptain, MapRelationConsts.Teammate,
				MapRelationConsts.Gangster, MapRelationConsts.Gang, MapRelationConsts.DG_Flag )
			if not player:HasRelation() then
				self:RemoveRelationPlayer(roleId)
			end
		end
	end
	-- 遍历新列表，如果不在原列表里面，增加，如果在原列表里面，更新
	for roleId, vo in pairs( newPlayerList ) do
		local relationPlayer = self:GetRelationPlayer( roleId )
		if not relationPlayer then
			relationPlayer = MapObjectPool:GetObject( MapRelationPlayer )
			relationPlayer:Init( vo.roleId, vo.roleName, vo.level, vo.posX, vo.posY )
			relationPlayer:AddRelation( vo.flag )
			self:AddRelationPlayer( relationPlayer )
		else
			relationPlayer:SetLevel( vo.level )
			relationPlayer:Move( vo.posX, vo.posY )
			relationPlayer:AddRelation( vo.flag )
		end
	end
end

function MapRelationModel:ClearBCJPlayer()
	self:UpdateBcjPlayer({})
end

function MapRelationModel:UpdateBcjPlayer( playerList )
	-- list to map
	local newPlayerList = {}
	for _, vo in pairs( playerList ) do
		newPlayerList[vo.roleId] = vo
	end
	-- print("----------------北仓界玩家列表-----------------")
	-- print("playerList数量:",#playerList)
	-- trace(playerList)

	-- print("players数量:",#self.players)
	-- trace(self.players)
	-- 遍历原列表，如果不在新列表里面，删除北苍界相关relation
	for roleId, player in pairs( self.players ) do
		if newPlayerList[roleId] == nil then
			player:RemoveRelationByType( MapRelationConsts.BCJ )
			if not player:HasRelation() then
				self:RemoveRelationPlayer(roleId)
			end
		end
	end
	-- 遍历新列表，如果不在原列表里面，增加，如果在原列表里面，更新
	for roleId, vo in pairs( newPlayerList ) do
		local relationPlayer = self:GetRelationPlayer( roleId )
		if not relationPlayer then
			relationPlayer = MapObjectPool:GetObject( MapRelationPlayer )
			relationPlayer:Init( vo.roleId, vo.roleName, vo.level, vo.posX, vo.posY )
			relationPlayer:AddRelation( MapRelationConsts.BCJ, vo.score )
			self:AddRelationPlayer( relationPlayer )
		else
			relationPlayer:SetLevel( vo.level )
			relationPlayer:Move( vo.posX, vo.posY )
			relationPlayer:AddRelation( MapRelationConsts.BCJ, vo.score )
		end
	end
end

-- 清除队伍相关的relation
function MapRelationModel:ClearTeamRelation()
	self:ClearRelationByType( MapRelationConsts.TeamCaptain, MapRelationConsts.Teammate )
end

-- 清除帮派相关的relation
function MapRelationModel:ClearGangRelation()
	self:ClearRelationByType( MapRelationConsts.Gangster, MapRelationConsts.Gang )
end

-- ... relationType
function MapRelationModel:ClearRelationByType( ... )
	for roleId, player in pairs( self.players ) do
		player:RemoveRelationByType( ... )
		if not player:HasRelation() then
			self:RemoveRelationPlayer(roleId)
		end
	end
end

-- 清除北仓界相关的relation
function MapRelationModel:ClearBcjRelation()
	self:ClearRelationByType( MapRelationConsts.BCJ )
end

function MapRelationModel:GetRelationPlayer(roleId)
	return self.players[roleId]
end

function MapRelationModel:GetRelationPlayers()
	return self.players
end

function MapRelationModel:AddRelationPlayer(relationPlayer)
	local roleId = relationPlayer:GetId()
	self.players[roleId] = relationPlayer
end

function MapRelationModel:RemoveRelationPlayer( roleId )
	local player = self.players[roleId]
	if player then
		player:Dispose()
		MapObjectPool:ReturnObject( player )
	end
	self.players[roleId] = nil
end
