-- battle message handler

local BattleHandler = class("BattleHandler", require("app.network.message.HandlerBase"))

function BattleHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TestBattle, self._receiveTestBattle, self)
end

function BattleHandler:sendBattleTest()
    local msgBuffer = protobuf.encode("cs.C2S_TestBattle", {})
    self:sendMsg(NetMsg_ID.ID_C2S_TestBattle, msgBuffer)
end

function BattleHandler:_receiveTestBattle(msgId, msg, len)
    -- handle battle message
    local message = decodeBuf("cs.S2C_TestBattle", msg, len)
    if message.ret == NetMsg_ERROR.RET_OK then
        message = message.info
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_BATTLE, nil, false, message) 
    end
end

return BattleHandler
