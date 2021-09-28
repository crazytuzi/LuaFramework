local HandlerBase = require("app.network.message.HandlerBase")
local DungeonHandler = class("DungeonHandler",HandlerBase)

function DungeonHandler:_onCtor()
        
    -- dungeon
    
end

function DungeonHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetChapterList, self.recvGetChapterList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddStage, self.recvAddStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExecuteStage, self.recvExecuteStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FastExecuteStage, self.recvFastExecuteStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishChapterBoxRwd, self.recvFinishChapterBoxRwd, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetChapterRank, self.recvDungeonRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishChapterAchvRwd, self.recvFinishChapterAchvRwd, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetDungeonFastTimeCd, self.recvResetDungeonFastTimeCd, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetDungeonExecution, self.recvResetDungeonExecution, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExecuteMultiStage, self.recvExecuteMultiStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FirstEnterChapter, self.recvFirstEnterChapter, self)
end

-- 请求章节信息
function DungeonHandler:sendGetChapterListMsg()
        local ChapterListMsg = {}
        local msgBuffer = protobuf.encode("cs.C2S_GetChapterList", ChapterListMsg) 
        self:sendMsg(NetMsg_ID.ID_C2S_GetChapterList, msgBuffer)
end

-- 请求进入关卡
function DungeonHandler:sendExecuteStage(stageId, donotDelay)
    donotDelay = donotDelay or false
    if not donotDelay then
        G_commonLayerModel:setDelayUpdate(true)
    end

    local ExecuteStageMsg = {id = stageId}
    local msgBuffer = protobuf.encode("cs.C2S_ExecuteStage", ExecuteStageMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ExecuteStage, msgBuffer)
end

-- 请求秒杀
function DungeonHandler:sendFastExecuteStage(stageId)
    local FastExecuteStageMsg = {id = stageId}
    local msgBuffer = protobuf.encode("cs.C2S_FastExecuteStage", FastExecuteStageMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FastExecuteStage, msgBuffer)
end

-- 第一次进入副本
function DungeonHandler:sendFirstEnterChapter(chapterId)
    local msg = {id = chapterId}
    local msgBuffer = protobuf.encode("cs.C2S_FirstEnterChapter", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FirstEnterChapter, msgBuffer)
end

-- 收到第一次进入副本结果
function DungeonHandler:recvFirstEnterChapter(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FirstEnterChapter", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.dungeonData:setFirstEnterChapter(decodeBuffer)
    end
end

-- 收到章节列表
function DungeonHandler:recvGetChapterList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetChapterList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.dungeonData:setDungeonData(decodeBuffer.total_star,decodeBuffer.fast_execute_cd,decodeBuffer.fast_execute_time)
        G_Me.dungeonData:setChapterList(decodeBuffer.chapters)
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_RECVCHAPTERLIST, nil, false,nil)
    end
end

-- 添加关卡
function DungeonHandler:recvAddStage(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_AddStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.dungeonData:addNewStage(decodeBuffer.chpt_id,decodeBuffer.stage)
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_UPDATESTAGE, nil, false,nil)
    end
end

-- 请求副本排名
function DungeonHandler:sendGetDungeonRank() 
        local DungeonRankMsg = {}
        local msgBuffer = protobuf.encode("cs.C2S_GetChapterRank", DungeonRankMsg) 
        self:sendMsg(NetMsg_ID.ID_C2S_GetChapterRank, msgBuffer)
end

-- 收到副本排名
function DungeonHandler:recvDungeonRank(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetChapterRank", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.dungeonData:setMyRank(decodeBuffer.self_rank)
            G_Me.dungeonData:addDungeonRankList(decodeBuffer.ranks)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_GETDUNGEONRANK, nil, false,nil)
        end
    end
end

-- 收到进入关卡条件
function DungeonHandler:recvExecuteStage(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ExecuteStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.dungeonData:addStage(G_Me.dungeonData:getCurrChapterId(),decodeBuffer.stage)
            G_Me.dungeonData:addBattleRes(decodeBuffer)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_EXECUTESTAGE, nil, false,decodeBuffer)
    else
        __LogError("parse S2C_ExecuteStage error")
    end
end

-- 请求执行下一波数
function DungeonHandler:sendExecuteMultiStage(_stageid,_wave_id)
        local ExecuteMultiStageMsg = 
        {
            id = _stageid,
            wave_id = _wave_id
        }
        local msgBuffer = protobuf.encode("cs.C2S_ExecuteMultiStage", ExecuteMultiStageMsg) 
        self:sendMsg(NetMsg_ID.ID_C2S_ExecuteMultiStage, msgBuffer)
end


-- 收到波数请求
function DungeonHandler:recvExecuteMultiStage(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ExecuteMultiStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
          if decodeBuffer.ret == G_NetMsgError.RET_OK then
              uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_ENTERBATTLE, nil, false,decodeBuffer)
          end
     end

end

-- 收到秒杀结果
function DungeonHandler:recvFastExecuteStage(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FastExecuteStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.dungeonData:setFastExecuteCD(decodeBuffer.fast_execute_cd)
            G_Me.dungeonData:setFastExecuteTime(decodeBuffer.fast_execute_time)
            G_Me.dungeonData:addStage(G_Me.dungeonData:getCurrChapterId(),decodeBuffer.stage)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_FASTEXECUTESTAGE, nil, false,decodeBuffer)
    end
end


-- 宝箱奖励,(左下角的铜，银，金宝箱)
function DungeonHandler:sendFinishChapterBoxRwd(chapterId,_type)
    local FinishChapterBoxRwdMsg = 
    {
        ch_id = chapterId,
        box_type = _type
    }
    local msgBuffer = protobuf.encode("cs.C2S_FinishChapterBoxRwd", FinishChapterBoxRwdMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FinishChapterBoxRwd, msgBuffer)
end

function DungeonHandler:recvFinishChapterBoxRwd(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_FinishChapterBoxRwd", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
             G_Me.dungeonData:setBoxIsOpen(decodeBuffer.ch_id,decodeBuffer.box_type)
         end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_GETBOUNSSUCC, nil, false,decodeBuffer)

     end
end

-- 星数奖励
function DungeonHandler:sendFinishChapterAchvRwd(_id)
    local FinishChapterAchvRwdMsg = 
    {
        rwd_id = _id,
    }
    local msgBuffer = protobuf.encode("cs.C2S_FinishChapterAchvRwd", FinishChapterAchvRwdMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FinishChapterAchvRwd, msgBuffer)
end

function DungeonHandler:recvFinishChapterAchvRwd(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_FinishChapterAchvRwd", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
             G_Me.dungeonData:addToStarBounsList(decodeBuffer.rwd_id)
             uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_FINISHSTARBOUNS, nil, false,decodeBuffer)
         end
     end
end

-- 星数领取奖励
function DungeonHandler:sendFinishChapterAchvRwdInfo()
    local FinishChapterAchvRwdInfoMsg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ChapterAchvRwdInfo", FinishChapterAchvRwdInfoMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ChapterAchvRwdInfo, msgBuffer)
end

-- 清除CD
function DungeonHandler:sendResetDungeonFastTimeCd()
    local ResetDungeonFastTimeCdMsg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ResetDungeonFastTimeCd", ResetDungeonFastTimeCdMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetDungeonFastTimeCd, msgBuffer)
end

function DungeonHandler:recvResetDungeonFastTimeCd(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_ResetDungeonFastTimeCd", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
             G_Me.dungeonData:setFastExecuteCD(decodeBuffer.fast_execute_cd)
             G_Me.dungeonData:setFastExecuteTime(decodeBuffer.fast_execute_time)
             G_MovingTip:showMovingTip(G_lang:get("LANG_CLEARCD_SUCC"))
         end
     end
end

-- 副本重置
function DungeonHandler:sendResetDungeonExecution(id)
    local ResetDungeonExecutionMsg = 
    {
        stage_id = id
    }
    local msgBuffer = protobuf.encode("cs.C2S_ResetDungeonExecution", ResetDungeonExecutionMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetDungeonExecution, msgBuffer)
end

function DungeonHandler:recvResetDungeonExecution(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_ResetDungeonExecution", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.dungeonData:addStage(G_Me.dungeonData:getCurrChapterId(),decodeBuffer.stage)
            G_Me.dungeonData:setRestCost(decodeBuffer.next_reset_cost)
             G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_RESTDUNGEONSUCC"))
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DUNGEON_DUNGEONRESTSUCC, nil, false,decodeBuffer)
         end
     end
end

return DungeonHandler

