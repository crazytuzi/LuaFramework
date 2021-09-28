-- crusade handler


local TrigramsHandler = class("TrigramsHandler", require("app.network.message.HandlerBase"))
  
function TrigramsHandler:initHandler(...)
    
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TrigramInfo, self._recvGetTrigramsInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TrigramPlay, self._recvGetPlay, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TrigramPlayAll, self._recvGetPlayAll, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TrigramReward, self._recvGetReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_TrigramRefresh, self._recvGetRefresh, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetTrigramRank, self._recvGetRankList, self)

end

--获取基本信息
function TrigramsHandler:sendGetTrigramsInfo()

    local msg = 
    {

    }

    local msgBuffer = protobuf.encode("cs.C2S_TrigramInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TrigramInfo, msgBuffer)

end


function TrigramsHandler:_recvGetTrigramsInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TrigramInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    --服务器没有返回ret字段
    --if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.trigramsData:updateInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_INFO, nil, false, decodeBuffer)
    --end
    
end

--抽奖
function TrigramsHandler:sendPlay(_id)

    if type(_id) ~= "number" or _id < 1 then 
        return 
    end

    local msg = 
    {
        pos = _id
    }

    local msgBuffer = protobuf.encode("cs.C2S_TrigramPlay", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TrigramPlay, msgBuffer)

end


function TrigramsHandler:_recvGetPlay(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TrigramPlay", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        G_Me.trigramsData:updatePlayOne(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_PLAY_RESULT, nil, false, decodeBuffer)

        if rawget(decodeBuffer, "new_trigram_info") then
            --等弹出获奖信息后再更新数据并发送消息
        	--G_Me.trigramsData:updateTrigram(decodeBuffer.new_trigram_info)
        	--等弹出获奖信息框后再发送消息
        	--uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_INFO, nil, false, decodeBuffer)
        end
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR3 then
        self:sendGetTrigramsInfo()
    end
    
end


--一键抽取
function TrigramsHandler:sendPlayAll()

    local msg = 
    {

    }

    local msgBuffer = protobuf.encode("cs.C2S_TrigramPlayAll", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TrigramPlayAll, msgBuffer)

end


function TrigramsHandler:_recvGetPlayAll(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TrigramPlayAll", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)


    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

    	G_Me.trigramsData:updatePlayAll(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_PLAY_ALL_RESULT, nil, false, decodeBuffer)

    	if rawget(decodeBuffer, "new_trigram_info") then
            --dump(decodeBuffer.new_trigram_info)
        	G_Me.trigramsData:updateTrigram(decodeBuffer.new_trigram_info)
        	--uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_INFO, nil, false, decodeBuffer)
        end
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR3 then
        self:sendGetTrigramsInfo()
    end
    
end

--刷新
function TrigramsHandler:sendRefresh()

    local msg = 
    {

    }

    local msgBuffer = protobuf.encode("cs.C2S_TrigramRefresh", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TrigramRefresh, msgBuffer)

end


function TrigramsHandler:_recvGetRefresh(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TrigramRefresh", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	if rawget(decodeBuffer, "new_trigram_info") then
        	G_Me.trigramsData:updateTrigram(decodeBuffer.new_trigram_info)        	
        	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_REFRESH_INFO, nil, false, decodeBuffer)
        end
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR3 then
        self:sendGetTrigramsInfo()
    end
    
end

--获取排行榜
function TrigramsHandler:sendGetRankList()

    local msg = 
    {

    }


    local msgBuffer = protobuf.encode("cs.C2S_GetTrigramRank", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetTrigramRank, msgBuffer)

end


function TrigramsHandler:_recvGetRankList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetTrigramRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.trigramsData:updateRankList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_RANK, nil, false, decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR3 then
        self:sendGetTrigramsInfo()
    end
    
end

--领奖
function TrigramsHandler:sendGetReward()

    local msg = 
    {
    }

    local msgBuffer = protobuf.encode("cs.C2S_TrigramReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_TrigramReward, msgBuffer)

end


function TrigramsHandler:_recvGetReward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_TrigramReward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    --dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.trigramsData:updateReward(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TRIGRAMS_GET_REWARD, nil, false, decodeBuffer)
    elseif decodeBuffer.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR3 then
        self:sendGetTrigramsInfo()
    end

end

return TrigramsHandler
