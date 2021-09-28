--HeroUpgradeHandler.lua


local HandlerBase = require("app.network.message.HandlerBase")
local HeroUpgradeHandler = class("HeroUpgradeHandler", HandlerBase)


function HeroUpgradeHandler:_onCtor( ... )
    -- body
end

function HeroUpgradeHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpgradeKnight, self._onReceiveUpradeKnight, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AdvancedKnight, self._onReceiveAdvancedKnight, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TrainingKnight, self._onReceiveTrainingKnightResult, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SaveTrainingKnight, self._onReceiveSaveTrainingKnightResult, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GiveupTrainingKnight, self._onReceiveGiveUpTrainingKnightResult, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpgradeKnightHalo, self._onReceiveGuanghuanReresult, self)


    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetKnightAttr, self._onReceiveGetKnightAttr, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KnightOrangeToRed, self._onReceiveGodKnight, self)

end

-- 强化部分
function HeroUpgradeHandler:sendUpgradeKnightRequest( upgradeKnight, knightList )
    local msg = 
    {
        upgrade_id = upgradeKnight,
        knight_list = knightList,
    }

    local msgBuffer = protobuf.encode("cs.C2S_UpgradeKnight", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_UpgradeKnight, msgBuffer)
end

function HeroUpgradeHandler:_onReceiveUpradeKnight( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpgradeKnight", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_UPGRADE_KNIGHT, nil, false, decodeBuffer.ret)
end


--升阶部分
function HeroUpgradeHandler:sendAdvancedKnight( advancedKnight, knightList )
	local msg = 
    {
        advanced_id = advancedKnight,
        knight_list = knightList,
    }

    local msgBuffer = protobuf.encode("cs.C2S_AdvancedKnight", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_AdvancedKnight, msgBuffer)
end

function HeroUpgradeHandler:_onReceiveAdvancedKnight( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_AdvancedKnight", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_ADVANCED_KNIGHT, nil, false, decodeBuffer.ret, decodeBuffer.new_knight)
end


--历练部分
function HeroUpgradeHandler:sendTrainingKnight( knightId, trainingType, trainingTimes )
	local msg = 
    {
        knight_id = knightId,
        training_type = trainingType,
        training_times = trainingTimes or 1,
    }

    local msgBuffer = protobuf.encode("cs.C2S_TrainingKnight", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_TrainingKnight, msgBuffer)
end

function HeroUpgradeHandler:sendSaveTrainingKnight( knightId )
	local msg = 
    {
        knight_id = knightId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_SaveTrainingKnight", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_SaveTrainingKnight, msgBuffer)
end

function HeroUpgradeHandler:sendGiveUpTrainingKnight( knightId )
	local msg = 
    {
        knight_id = knightId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_GiveupTrainingKnight", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GiveupTrainingKnight, msgBuffer)
end

function HeroUpgradeHandler:_onReceiveTrainingKnightResult( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_TrainingKnight", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_TRAINING_KNIGHT, nil, false, decodeBuffer.ret)
end

function HeroUpgradeHandler:_onReceiveSaveTrainingKnightResult( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_SaveTrainingKnight", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_SAVE_TRAINING, nil, false, decodeBuffer.ret)
end

function HeroUpgradeHandler:_onReceiveGiveUpTrainingKnightResult( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GiveupTrainingKnight", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GIVEUP_TRAINING, nil, false, decodeBuffer.ret)
end

--光环部分
function HeroUpgradeHandler:sendGuanghuanKnight( knightId )
    local msg = 
    {
        knight_id = knightId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_UpgradeKnightHalo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_UpgradeKnightHalo, msgBuffer)
end

function HeroUpgradeHandler:_onReceiveGuanghuanReresult( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpgradeKnightHalo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --self:_disposeErrorMsg(decodeBuffer.ret)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_HALO_KNIGHT, nil, false, decodeBuffer.ret)
end

-- 化神部分
function HeroUpgradeHandler:sendGodKnight(knightId)
    
    local msg =
    {
        kid = knightId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_KnightOrangeToRed", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_KnightOrangeToRed, msgBuffer)
end

function HeroUpgradeHandler:_onReceiveGodKnight(msgId, msg, len)

    local decodeBuffer = self:_decodeBuf("cs.S2C_KnightOrangeToRed", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECEIVE_GOD_KNIGHT, nil, false, nil)
    end
end

--测试使用
function HeroUpgradeHandler:sendGetKnightAttr( knightId )

    local msg = 
    {
        knight_id = knightId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_GetKnightAttr", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetKnightAttr, msgBuffer)

end

function HeroUpgradeHandler:_onReceiveGetKnightAttr( msgId, msg, len )
    print("_onReceiveGetKnightAttr")
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetKnightAttr", msg, len)
--    dump(decodeBuffer)
end


return HeroUpgradeHandler
