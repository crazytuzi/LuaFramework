local HandlerBase = require("app.network.message.HandlerBase")
local StoryDungeonHandler = class("StoryDungeonHandler", HandlerBase)

function StoryDungeonHandler:_onCtor( ... )
    -- body
end

function StoryDungeonHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetStoryList, self._recvGetStoryList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExecuteBarrier, self._recvExecuteBarrier, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetBarrierAward, self._recvGetBarrierAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishSanguozhiAward, self._recvFinishSanguozhiAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddStoryDungeon, self._recvAddStoryDungeon, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetStoryTag, self._recvSetStoryTag, self)
end

-- 请求副本剧情列表
function StoryDungeonHandler:sendGetStoryList()
    local msgBuffer = protobuf.encode("cs.C2S_GetStoryList", {}) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetStoryList, msgBuffer)
end

-- 设置副本开启状态
function StoryDungeonHandler:sendSetStoryTag(dungeonId)
    local msgBuffer = protobuf.encode("cs.C2S_SetStoryTag", {dungeon_id = dungeonId}) 
    self:sendMsg(NetMsg_ID.ID_C2S_SetStoryTag, msgBuffer)
end

function StoryDungeonHandler:_recvSetStoryTag(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_SetStoryTag", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            G_Me.storyDungeonData:modifyStoryDungeon(decodeBuffer.dungeon)
        end
    end
    
end

 -- 收到剧情副本列表
 function StoryDungeonHandler:_recvGetStoryList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetStoryList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            G_Me.storyDungeonData:addDungeonList(decodeBuffer)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_STORYDUNGEON_DUNGEONLIST, nil, false,decodeBuffer)
    end
 end
 
  -- 添加新的副本
 function StoryDungeonHandler:_recvAddStoryDungeon(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_AddStoryDungeon", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.storyDungeonData:modifyStoryDungeon(decodeBuffer.dungeon)
    end
 end
 
 -- 执行剧情副本
 -- waveIndex 当前第几波
 function StoryDungeonHandler:sendExecuteBarrier(_dungeon_id,_barrier_id,waveIndex)
     G_commonLayerModel:setDelayUpdate(true)
     local ExecuteBarrierMsg =
     {
        dungeon_id = _dungeon_id,
        barrier_id = _barrier_id,
        wave_id = waveIndex,
     }
    local msgBuffer = protobuf.encode("cs.C2S_ExecuteBarrier", ExecuteBarrierMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ExecuteBarrier, msgBuffer)
 end
 
 -- 收到执行副本结果
function StoryDungeonHandler:_recvExecuteBarrier(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ExecuteBarrier", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            G_Me.storyDungeonData:modifyStoryDungeon(decodeBuffer.dungeon)
            G_Me.storyDungeonData:setCurrStoryStatus(
                decodeBuffer.dungeon_id,decodeBuffer.barrier_id,decodeBuffer.drop_awards,decodeBuffer.monster_awards)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_STORYDUNGEON_EXECUTEBARRIER, nil, false,decodeBuffer)
    end
 end
 
-- 请求领取宝箱
function StoryDungeonHandler:sendGetBarrierAward(drop_id)
    local GetBarrierAwardMsg =
     {
        id = drop_id
     }
    local msgBuffer = protobuf.encode("cs.C2S_GetBarrierAward", GetBarrierAwardMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetBarrierAward, msgBuffer)
 end
 
 -- 收到领取宝箱
 function StoryDungeonHandler:_recvGetBarrierAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetBarrierAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
            G_Me.storyDungeonData:modifyStoryDungeon(decodeBuffer.dungeon)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_STORYDUNGEON_GETBARRIERAWARD, nil, false,decodeBuffer)
        end
    end
 end
 
 -- 领取三国志奖励
function StoryDungeonHandler:sendFinishSanguozhiAward(_sgz_id)

    local msgBuffer = protobuf.encode("cs.C2S_FinishSanguozhiAward", {sgz_id = _sgz_id}) 
    self:sendMsg(NetMsg_ID.ID_C2S_FinishSanguozhiAward, msgBuffer)
 end
 
 -- 收到领取三国志奖励结果
 function StoryDungeonHandler:_recvFinishSanguozhiAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FinishSanguozhiAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
             G_Me.storyDungeonData:addIdToSanGuoZhiFinishiList(decodeBuffer.sgz_id)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_STORYDUNGEON_FINISHSANGUOZHIAWARD, nil, false,decodeBuffer)
    end
 end
 
return StoryDungeonHandler

