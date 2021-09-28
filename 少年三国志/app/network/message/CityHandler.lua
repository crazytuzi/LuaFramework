-- City message handler

local CityHandler = class("CityHandler", require("app.network.message.HandlerBase"))

function CityHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityInfo, self._receiveCityInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityAttack, self._receiveCityAttack, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityPatrol, self._receiveCityPatrol, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityCheck, self._receiveCityCheck, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityReward, self._receiveCityAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityAssist, self._receiveCityAssist, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityAssisted, self._receiveCityAssisted, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityOneKeyReward, self._receiveCityOneKeyReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityOneKeyPatrolSet, self._receiveCityOneKeyPatrolSet, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CityTechUp, self._receiveCityTechUp, self)
end

function CityHandler:sendCityInfo(userId)
    local msgBuffer = protobuf.encode("cs.C2S_CityInfo", {id=userId})
    self:sendMsg(NetMsg_ID.ID_C2S_CityInfo, msgBuffer)
end

function CityHandler:sendCityAttack()
    local msgBuffer = protobuf.encode("cs.C2S_CityAttack", {})
    self:sendMsg(NetMsg_ID.ID_C2S_CityAttack, msgBuffer)
end

function CityHandler:sendCityPatrol(cityIndex, knightId, timeSelected, efficienySelected)
    local msgBuffer = protobuf.encode("cs.C2S_CityPatrol", {city=cityIndex, knight=knightId, duration=timeSelected, efficiency=efficienySelected})
    self:sendMsg(NetMsg_ID.ID_C2S_CityPatrol, msgBuffer)
end

function CityHandler:sendCityCheck(friends)
    local msgBuffer = protobuf.encode("cs.C2S_CityCheck", {id=friends})
    self:sendMsg(NetMsg_ID.ID_C2S_CityCheck, msgBuffer)
end

function CityHandler:sendCityAward(cityId)
    G_commonLayerModel:setDelayUpdate(true)
    local msgBuffer = protobuf.encode("cs.C2S_CityReward", {city=cityId})
    self:sendMsg(NetMsg_ID.ID_C2S_CityReward, msgBuffer)
end

function CityHandler:sendCityAssist(friendId, cityId)
    local msgBuffer = protobuf.encode("cs.C2S_CityAssist", {id=friendId, city=cityId})
    self:sendMsg(NetMsg_ID.ID_C2S_CityAssist, msgBuffer)
end

function CityHandler:sendCityOneKeyReward()
    local msgBuffer = protobuf.encode("cs.C2S_CityOneKeyReward", {})
    self:sendMsg(NetMsg_ID.ID_C2S_CityOneKeyReward, msgBuffer)
end

-- 一键巡逻方案保存
function CityHandler:sendCityOneKeyPatrolSet(config)
    local cfgArray = {}
    for i, v in ipairs(config) do
        cfgArray[i] = { id = v.city_id,
                        skac = v.hero_id,
                        sduration = v.duration_type,
                        sefficiency = v.interval_type
                      }
    end

    local msgBuffer = protobuf.encode("cs.C2S_CityOneKeyPatrolSet", {cokps = cfgArray})
    self:sendMsg(NetMsg_ID.ID_C2S_CityOneKeyPatrolSet, msgBuffer)
end

-- 提升领地科技等级
function CityHandler:sendCityTechUp(cityId)
    local msgBuffer = protobuf.encode("cs.C2S_CityTechUp", {id=cityId})
    self:sendMsg(NetMsg_ID.ID_C2S_CityTechUp, msgBuffer)
end

function CityHandler:_receiveCityInfo(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityInfo", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    G_Me.cityData:setCityInfo(message)
end

function CityHandler:_receiveCityAttack(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityAttack", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_ATTACK, nil, false, message)
    end
end

function CityHandler:_receiveCityPatrol(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityPatrol", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK then
        G_Me.cityData:setCityPatrol(message)
    end
end

function CityHandler:_receiveCityCheck(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityCheck", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_CHECK, nil, false, message)
end

function CityHandler:_receiveCityAward(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityReward", msg, len)
    if type(message) ~= "table" then 
        return 
    end

    if message.ret == NetMsg_ERROR.RET_OK then
        G_Me.cityData:updateTotalPatrolTime(rawget(message, "totaltime"))
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_AWARD, nil, false, message)
    end
end

function CityHandler:_receiveCityAssist(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityAssist", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    if message.ret == NetMsg_ERROR.RET_OK or message.ret == NetMsg_ERROR.RET_RIOT_ASSISTED then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_ASSIST, nil, false, message)
    end
end

function CityHandler:_receiveCityAssisted(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityAssisted", msg, len)
    if type(message) ~= "table" then 
        return 
    end
    
    G_Me.cityData:setCityAssisted(message)
end

function CityHandler:_receiveCityOneKeyReward(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityOneKeyReward", msg, len)
    if type(message) ~= "table" then
        return
    end

    if message.ret == NetMsg_ERROR.RET_OK then
        G_Me.cityData:updateTotalPatrolTime(rawget(message, "totaltime"))
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_ONEKEYREWARD, nil, false, message)
    end
end

function CityHandler:_receiveCityOneKeyPatrolSet(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityOneKeyPatrolSet", msg, len)
    if type(message) ~= "table" then
        return
    end

    if message.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_ONEKEYPATROL_SET, nil, false)
    end
end

function CityHandler:_receiveCityTechUp(msgId, msg, len)
    local message = self:_decodeBuf("cs.S2C_CityTechUp", msg, len)
    if type(message) ~= "table" then
        return
    end

    if message.ret == NetMsg_ERROR.RET_OK then
        G_Me.cityData:updateCityTechLevel(rawget(message, "id"), rawget(message, "level"))
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CITY_TECH_UP, nil, false)
    end
end

return CityHandler
