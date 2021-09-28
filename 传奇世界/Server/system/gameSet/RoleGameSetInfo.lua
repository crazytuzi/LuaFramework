--RoleGameSetInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleGameSetInfo.lua
 --* Author:  seezon
 --* Modified: 2014年6月23日
 --* Purpose: Implementation of the class RoleGameSetInfo
 -------------------------------------------------------------------*/

RoleGameSetInfo = class()

local prop = Property(RoleGameSetInfo)
prop:accessor("roleSID")
prop:accessor("roleID")

function RoleGameSetInfo:__init()
	self._datas = {}
    self._datas.gameSets = {}
    self._datas.guardStep = {99999}
end

--设置游戏
function RoleGameSetInfo:doSetGame(gameSetID, gameSetValue)
	--/*20150708
	if self._datas.gameSets[gameSetID] == gameSetValue then
		return
	end
	
	self._datas.gameSets[gameSetID] = gameSetValue
	--*/20150708
	if self._datas.gameSets[gameSetID] == DefaultGameSet[gameSetID] then
		self._datas.gameSets[gameSetID] = nil
	end
	self:cast2db()
end

--设置游戏
function RoleGameSetInfo:getGameSetValue(gameSetID)
	return self._datas.gameSets[gameSetID] or DefaultGameSet[gameSetID]
end

--设置游戏向导
function RoleGameSetInfo:doSetGameGuard(gameGuardID, gameGuardState)
	if not table.contains(self._datas.guardStep, gameGuardID) then
		table.insert(self._datas.guardStep, gameGuardID)
	end
	
	self:cast2db()

	--Tlog[GuideFlow]
	local roleSID = self:getRoleSID()
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_tlogMgr:TlogGuideFlow(player,gameGuardID,gameGuardState)
	end
end

--获取需要加载给客户端的数据
function RoleGameSetInfo:getloadData()
	local retData = {}
    local gameSetNum = table.size(self._datas.gameSets)
	retData.gameSetNum = gameSetNum
	retData.gameConfig = {}
	if gameSetNum > 0 then
		for k,v in pairs(self._datas.gameSets) do
			local gameSets = {}
			gameSets.key = k
			gameSets.value = v
			table.insert(retData.gameConfig,gameSets)
		end
	end

	return retData
end

--获取需要加载给客户端的向导数据
function RoleGameSetInfo:getloadGuardData()
	local retData = {}
	local guardData = serialize(self._datas.guardStep)
	retData.guardStep = guardData
	return retData
end

--保存到数据库
function RoleGameSetInfo:cast2db()
	local cache_buff = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_GAMESET, cache_buff, #cache_buff)
end

--加载数据库的数据
function RoleGameSetInfo:loadData(cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("GameSetProtocol", cache_buf)
		self._datas.guardStep = datas.guardStep
		for _,v in pairs(datas.gameSets) do
			self._datas.gameSets[v.id] = v.value
		end
	end

	--向team更新数据
	if self._datas.gameSets then
		local autoInvitedSet = self._datas.gameSets[GAME_SET_ID_AUTOINTEAM]
		if not autoInvitedSet then autoInvitedSet = 1 end
		local autoApplySet = self._datas.gameSets[GAME_SET_ID_AUTOAPPLY]
		if not autoApplySet then autoApplySet = 1 end

		local needUpdate = false
		if 0 == autoInvitedSet or 0 == autoApplySet then 
			needUpdate = true
		end

		if needUpdate then
			surfaceInfo = {}
			surfaceInfo.autoInvited = autoInvitedSet
			surfaceInfo.autoApply = autoApplySet
			g_TeamPublic:updateMemSurface(self:getRoleSID(),surfaceInfo)
		end
	end
end

--保存到数据库
function RoleGameSetInfo:writeObject()
	local datas = {}
	datas.gameSets = {}
	
	for id, value in pairs(self._datas.gameSets) do
		local set = {}
		set.id = id 
		set.value = value
		table.insert(datas.gameSets, set)
	end
	
	datas.guardStep = self._datas.guardStep
	return protobuf.encode("GameSetProtocol", datas)
end

--切换world的通知
function RoleGameSetInfo:switchWorld(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_GAMECONFIG_SETS)
	--具体数据跟在后面
	local buff = self:writeObject()
	luaBuf:pushLString(buff, #buff)
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

function RoleGameSetInfo:notifyClient()
	self:notifyClientLoadData()
	self:notifyClientGuardData()
end

--给客户端发需要加载的数据
function RoleGameSetInfo:notifyClientLoadData()
    local roleID = self:getRoleID()
    SCSETLOADDATA.writeFun(roleID)
end

--给客户端发加载的向导数据
function RoleGameSetInfo:notifyClientGuardData()
    local roleID = self:getRoleID()
    SCSETLOADGUARD.writeFun(roleID)
end

function RoleGameSetInfo:getTeamAutoInviteSet()
	return self._datas.gameSets[GAME_SET_ID_AUTOINTEAM]
end

function RoleGameSetInfo:getTeamAutoApplySet()
	return self._datas.gameSets[GAME_SET_ID_AUTOAPPLY]
end