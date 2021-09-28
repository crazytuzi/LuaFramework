-----------------------------------------------------------
-- @名人堂
-----------------------------------------------------------
local HandlerBase = require("app.network.message.HandlerBase")
local HallOfFrameHandler = class("HallOfFrameHandler",HandlerBase)

function HallOfFrameHandler:_onCtor()
        

    
end

function HallOfFrameHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_HOF_UIInfo, self._recvUIInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_HOF_Confirm, self._recvConfirm, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_HOF_Sign, self._recvSign, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_HOF_RankInfo, self._recvRankInfo, self)
end

--@desc 收到名人堂排名信息
function HallOfFrameHandler:_recvUIInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_HOF_UIInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HALLOFFRAME_INFO, nil, false,decodeBuffer)
    end
end

--@desc 收到点赞
function HallOfFrameHandler:_recvConfirm(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_HOF_Confirm", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer then
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HALLOFFRAME_CONFRIM, nil, false,decodeBuffer)
    end
end

--@desc 收到签名
function HallOfFrameHandler:_recvSign(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_HOF_Sign", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer then
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HALLOFFRAME_SIGN, nil, false,decodeBuffer)
    end
end

--@desc 收到名人堂排名信息
function HallOfFrameHandler:_recvRankInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_HOF_RankInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer then
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HALLOFFRAME_TOP, nil, false,decodeBuffer)
    end
end

--@desc 请求名人堂
function HallOfFrameHandler:sendRequestUIInfo(top_type)
    local typeMsg = {kind = top_type}
    local msgBuffer = protobuf.encode("cs.C2S_HOF_UIInfo", typeMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_HOF_UIInfo, msgBuffer)
end

--@desc 请求点赞
function HallOfFrameHandler:sendRequestConfirm(user_id)
    local confirmMsg = {id = user_id}
    local msgBuffer = protobuf.encode("cs.C2S_HOF_Confirm", confirmMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_HOF_Confirm, msgBuffer)
end

--@desc 请求签名
function HallOfFrameHandler:sendRequestSign(str)
    local infoMsg = {info = str}
    local msgBuffer = protobuf.encode("cs.C2S_HOF_Sign", infoMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_HOF_Sign, msgBuffer)
end

--@desc 请求排名
function HallOfFrameHandler:sendRequestRankInfo(top_type,startIndex,endIndex)
    local rankInfoMsg = {kind = top_type,start_rank = startIndex,stop_rank = endIndex}
    local msgBuffer = protobuf.encode("cs.C2S_HOF_RankInfo", rankInfoMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_HOF_RankInfo, msgBuffer)
end

return HallOfFrameHandler
