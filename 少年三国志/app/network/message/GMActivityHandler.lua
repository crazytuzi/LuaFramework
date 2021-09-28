local GMActivityHandler = class("GMActivityHandler ", require("app.network.message.HandlerBase"))

function GMActivityHandler:_onCtor( ... )
end

function GMActivityHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCustomActivityInfo, self._recvCustomActivityInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpdateCustomActivity, self._recvUpdateCustomActivity, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpdateCustomActivityQuest, self._recvUpdateCustomActivityQuest, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCustomActivityAward, self._recvGetCustomActivityAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpdateCustomSeriesActivity, self._recvUpdateCustomSeriesActivity, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCustomSeriesActivity, self._recvGetCustomSeriesActivity, self)

end

--[[
    接收可配置活动信息 
    1, 推进
    2，限时玩法福利
    3，限时贩售&物品兑换
    4，累冲/单冲
]]
function GMActivityHandler:_recvCustomActivityInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCustomActivityInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then
        G_Me.activityData.custom:initActivity(decodeBuffer)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_INFO, nil, false, decodeBuffer)
end

--发送可配置活动信息 
function GMActivityHandler:sendCustomActivityInfo()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCustomActivityInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCustomActivityInfo, msgBuffer)
end

--[[
    message S2C_UpdateCustomActivity {
      repeated CustomActivity activity = 1;
      repeated CustomActivityQuest quest = 2;
    }
]]
function GMActivityHandler:_recvUpdateCustomActivity( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpdateCustomActivity", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.activityData.custom:updateActivity(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_UPDATE, nil, false, decodeBuffer)
end

--[[
    message S2C_UpdateCustomActivityQuest {
      repeated UserCustomActivityQuest user_quest = 1;
    }
]]
function GMActivityHandler:_recvUpdateCustomActivityQuest( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpdateCustomActivityQuest", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.activityData.custom:updateActivityQuest(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_UPDATE_QUEST, nil, false, decodeBuffer)
end


--领奖
function GMActivityHandler:sendGetCustomActivityAward(act_id,quest_id,award_id,num)
    if not num or type(num) ~= "number" then
        num = 1
    end
    local msg = {
        act_id = act_id,
        quest_id = quest_id,
        num=num,
    }
    if award_id ~= nil and type(award_id) == "number"then
        msg["award_id"] = award_id
    end
    local msgBuffer = protobuf.encode("cs.C2S_GetCustomActivityAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCustomActivityAward, msgBuffer)
end

function GMActivityHandler:_recvGetCustomActivityAward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCustomActivityAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_GET_AWARD, nil, false, decodeBuffer)
end


--刷新系列活动
function GMActivityHandler:_recvUpdateCustomSeriesActivity(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpdateCustomSeriesActivity", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    dump(decodeBuffer)
    if rawget(decodeBuffer,"series_id") and decodeBuffer.series_id > 0 then
        self:sendGetCustomSeriesActivity(decodeBuffer.series_id)
    end
    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_GET_AWARD, nil, false, decodeBuffer)
end

function GMActivityHandler:sendGetCustomSeriesActivity(series_id)
    local msg = {
        series_id = series_id
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCustomSeriesActivity", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCustomSeriesActivity, msgBuffer)
end

function GMActivityHandler:_recvGetCustomSeriesActivity(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCustomSeriesActivity", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        --注意顺序
        if not rawget(decodeBuffer,"series_id") or decodeBuffer.series_id == 0 then
            --如果没有系列活动了需要删除原来的系列活动
            return
        end
        G_Me.activityData.custom:updateSeriesActivity(decodeBuffer)

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_UPDATE, nil, false, decodeBuffer)
    end
    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_GET_AWARD, nil, false, decodeBuffer)
end


return GMActivityHandler
