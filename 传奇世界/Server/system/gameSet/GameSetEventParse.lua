--GameSetEventParse.lua
--/*-----------------------------------------------------------------
 --* Module:  GameSetEventParse.lua
 --* Author:  seezon
 --* Modified: 2014年6月23日
 --* Purpose: Implementation of the class WingEventParse
 -------------------------------------------------------------------*/
 --改变配置
CSCHANGE = {}
--GAMECONFIG_CS_CHANGE后端读消息
CSCHANGE.readFun = function(pbc_string)
	local data = protobuf.decode("GameConfigChangeProtocol" , pbc_string)

	local gameSetID = data.gameSetID
	local gameSetValue = data.gameSetValue

	return gameSetID,gameSetValue
end

 --改变向导
CSCHANGEGUARD = {}
--GAMECONFIG_CS_CHANGE_GUARD后端读消息
CSCHANGEGUARD.readFun = function(pbc_string)
	local data = protobuf.decode("GameConfigChangGuardProtocol" , pbc_string)
	local gameGuardID = data.gameGuardID
	local gameGuardState = data.state
	return gameGuardID, gameGuardState
end

--服务器推送系统配置数据给客户端
SCSETLOADDATA = {}
--GAMECONFIG_SC_LOADDATA后端写消息
SCSETLOADDATA.writeFun = function(roleID)
	local memInfo = g_gameSetMgr:getRoleGameSetInfo(roleID)
	if not memInfo then
		return false
	end
	local retData = memInfo:getloadData()
	fireProtoMessage(roleID,GAMECONFIG_SC_LOADDATA,"GameConfigLoadDataRetProtocol",retData)
end

--服务器推送向导数据给客户端
SCSETLOADGUARD = {}
--GAMECONFIG_SC_LOADGUARD后端写消息
SCSETLOADGUARD.writeFun = function(roleID)
	local memInfo = g_gameSetMgr:getRoleGameSetInfo(roleID)
	if not memInfo then
		return false
	end
	local retData = memInfo:getloadGuardData()
	fireProtoMessage(roleID,GAMECONFIG_SC_LOADGUARD,"GameConfigLoadGuardRetProtocol",retData)
end

 --客户端拉取装备图鉴数据
CSGETEQUIPMAP = {}
--GAMECONFIG_CS_GETEQUIPMAP后端读消息
CSGETEQUIPMAP.readFun = function(buffer)
	local roleID = buffer:popInt()
	local equipType = buffer:popChar()
	local data = {}
	data[1] = roleID
	data[2] = equipType
	return data
end

--服务器推送装备图鉴数据给客户端
CSGETEQUIPMAPRET = {}
--GAMECONFIG_CS_GETEQUIPMAP_RET后端写消息
CSGETEQUIPMAPRET.writeFun = function(roleID, equipType)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(GAMECONFIG_SC_GETEQUIPMAP_RET)
	local memInfo = g_gameSetMgr:getRoleGameSetInfo(roleID)
	if not memInfo then
		return false
	end
	memInfo:pushEquipMap(retBuff, equipType)
	return retBuff
end