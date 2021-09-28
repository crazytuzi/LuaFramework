--GameSetManager.lua
--/*-----------------------------------------------------------------
 --* Module:  GameSetManager.lua
 --* Author:  seezon
 --* Modified: 2014年6月23日
 --* Purpose: 系统设置管理器
 -------------------------------------------------------------------*/
require ("system.gameSet.GameSetConstant")
require ("system.gameSet.GameSetServlet")
require ("system.gameSet.RoleGameSetInfo")
require ("system.gameSet.GameSetEventParse")
	
GameSetManager = class(nil, Singleton)
--全局对象定义
g_gameSetServlet = GameSetServlet.getInstance()

function GameSetManager:__init()
	self._roleGameSetInfos = {} --运行时ID
	self._roleGameSetInfoBySID = {} --数据库ID
	self._roleDBData = {} --数据库的数据
	g_listHandler:addListener(self)
end


function GameSetManager:getPlayerInfo(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local memInfo = self:getRoleGameSetInfoBySID(roleSID)

	if not memInfo then
		memInfo = RoleGameSetInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleGameSetInfos[roleID] = memInfo
		self._roleGameSetInfoBySID[roleSID] = memInfo
	end
	return memInfo
end

--玩家上线
function GameSetManager:onPlayerLoaded(player)
	local memInfo = self:getPlayerInfo(player)
	
	memInfo:notifyClient()
	memInfo:cast2db()
end

--玩家注销
function GameSetManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleGameSetInfoBySID(roleSID)
	if not memInfo then
		return
	end

	if memInfo then
		self._roleGameSetInfos[roleID] = nil
		self._roleGameSetInfoBySID[roleSID] = nil
	end
end

--掉线登陆
function GameSetManager:onActivePlayer(player)
	local memInfo = self:getRoleGameSetInfoBySID(player:getSerialID()) 
	if not memInfo then
		return
	end
    memInfo:notifyClient()
end

function GameSetManager.loadDBData(player, cache_buf, roleSid)		
	local memInfo = g_gameSetMgr:getPlayerInfo(player)
	if #cache_buf > 0 then
		memInfo:loadData(cache_buf)
	end
end

--缓存下数据库的系统设置数据
function GameSetManager.SaveGameSetData(roleID, buff)
	g_gameSetMgr._roleDBData[roleID] = buff
end

--改变游戏设置
function GameSetManager:changeGameSet(roleID, gameSetID, gameSetValue)
	local memInfo = self:getRoleGameSetInfo(roleID)
	if not memInfo then
		return
	end

	memInfo:doSetGame(gameSetID, gameSetValue)
end

--改变游戏向导
function GameSetManager:changeGameGuard(roleID, gameGuardID, gameGuardState)
	local memInfo = self:getRoleGameSetInfo(roleID)
	if not memInfo then
		return
	end

	memInfo:doSetGameGuard(gameGuardID, gameGuardState)
end

--切换world的通知
function GameSetManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local memInfo = self:getRoleGameSetInfo(roleID)
	if memInfo then
		memInfo:switchWorld(peer, dbid, mapID)
	end
end

--切换到本world的通知
function GameSetManager:onPlayerSwitch(player, type, buff)
	if type == EVENT_GAMECONFIG_SETS then
		local roleID = player:getID()
		local roleSID = player:getSerialID()
		memInfo = RoleGameSetInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleGameSetInfos[roleID] = memInfo
		self._roleGameSetInfoBySID[roleSID] = memInfo	
		local cache_buf = buff:popLString()
		memInfo:loadData(cache_buf)
	end	
end

function GameSetManager.getDoubleFireValue(roleSID)
	return g_gameSetMgr:getRoleGameSetValue(roleSID, GAME_SET_ID_AUTO_DOUBLE_FIRE)
end

function GameSetManager:getRoleGameSetValue(roleSID, setId)
	local info =  self:getRoleGameSetInfoBySID(roleSID)
	return info:getGameSetValue(setId)
end

--获取玩家数据
function GameSetManager:getRoleGameSetInfo(roleID)
	return self._roleGameSetInfos[roleID]
end

--获取玩家数据通过数据库ID
function GameSetManager:getRoleGameSetInfoBySID(roleSID)
	return self._roleGameSetInfoBySID[roleSID]
end

function GameSetManager.getInstance()
	return GameSetManager()
end

g_gameSetMgr = GameSetManager.getInstance()