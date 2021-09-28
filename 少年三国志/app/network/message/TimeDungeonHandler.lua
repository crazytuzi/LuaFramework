local HandlerBase = require("app.network.message.HandlerBase")
local TimeDungeonHandler = class("TimeDungeonHandler", HandlerBase)


function TimeDungeonHandler:_onCtor( ... )
	
end

function TimeDungeonHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetTimeDungeonList, self.recvGetTimeDungeonList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetTimeDungeonInfo, self.recvGetTimeDungeonInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddTimeDungeonBuff, self.recvAddTimeDungeonBuff, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AttackTimeDungeon, self.recvAttackTimeDungeon, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushTimeDungeonList, self.recvFlushTimeDungeonList, self)
end

-- reveive message
----------------------------------------------------------------
-- 获取副本列表
function TimeDungeonHandler:recvGetTimeDungeonList(msgId, msg, len)
	  local decodeBuffer = self:_decodeBuf("cs.S2C_GetTimeDungeonList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timeDungeonData:storeDungeonInfoList(decodeBuffer.info)
    end
end


function TimeDungeonHandler:recvFlushTimeDungeonList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushTimeDungeonList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.timeDungeonData:storeDungeonInfoListWithFlush(decodeBuffer.info)
end


function TimeDungeonHandler:recvGetTimeDungeonInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetTimeDungeonInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timeDungeonData:updateCurDungeonInfo(decodeBuffer.info)
    end
end



function TimeDungeonHandler:recvAddTimeDungeonBuff(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_AddTimeDungeonBuff", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timeDungeonData:updateCurDungeonInfo(decodeBuffer.info)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_DUNGEON_INSPIRE_SUCC, nil, false)
    end
end



function TimeDungeonHandler:recvAttackTimeDungeon(msgId, msg, len)
	  local decodeBuffer = self:_decodeBuf("cs.S2C_AttackTimeDungeon", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timeDungeonData:storeBattleResult(decodeBuffer)
        if decodeBuffer.battle_report.is_win then
            G_Me.timeDungeonData:updateCurDungeonInfo(decodeBuffer.info)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_DUNGEON_OPEN_BATTLE_SCENE, nil, false, decodeBuffer)
    end
end

-- send message
----------------------------------------------------------------
-- 请求获取副本列表
function TimeDungeonHandler:sendGetTimeDungeonList()
	  local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetTimeDungeonList", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetTimeDungeonList, msgBuffer)	
end

--
function TimeDungeonHandler:sendGetTimeDungeonInfo()
	  local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetTimeDungeonInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetTimeDungeonInfo, msgBuffer)
end

function TimeDungeonHandler:sendAddTimeDungeonBuff(nStageId, nStageIndex, nBuffId)
  	local tMsg = {
  		id = nStageId,
  		dungeon_index = nStageIndex,
  		buff_id = nBuffId
  	}
    local msgBuffer = protobuf.encode("cs.C2S_AddTimeDungeonBuff", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_AddTimeDungeonBuff, msgBuffer)
end

function TimeDungeonHandler:sendAttackTimeDungeon(nDungeonId, nDungeonIndex)
	local tMsg = {
		id = nDungeonId,
		dungeon_index = nDungeonIndex,
	}
    local msgBuffer = protobuf.encode("cs.C2S_AttackTimeDungeon", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_AttackTimeDungeon, msgBuffer)
end

return TimeDungeonHandler


