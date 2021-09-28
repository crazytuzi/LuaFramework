local HandlerBase = require("app.network.message.HandlerBase")
local HardDungeonHandler = class("HardDungeonHandler",HandlerBase)

function HardDungeonHandler:_onCtor()
        
    -- dungeon
    
end

function HardDungeonHandler:initHandler(...)                       
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_GetChapterList, self.recvGetChapterList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_AddStage, self.recvAddStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_ExecuteStage, self.recvExecuteStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_FastExecuteStage, self.recvFastExecuteStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_FinishChapterBoxRwd, self.recvFinishChapterBoxRwd, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_GetChapterRank, self.recvDungeonRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_ResetDungeonExecution, self.recvResetDungeonExecution, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_ExecuteMultiStage, self.recvExecuteMultiStage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_FirstEnterChapter, self.recvFirstEnterChapter, self)

    -- 精英暴动
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_GetChapterRoit, self.recvGetRiotChapterList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Hard_FinishChapterRoit, self.recvGetRiotBattleInfo, self)
end

-- 请求章节信息
function HardDungeonHandler:sendGetChapterListMsg()
    local ChapterListMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_Hard_GetChapterList", ChapterListMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_GetChapterList, msgBuffer)
end

-- 请求进入关卡
function HardDungeonHandler:sendExecuteStage(stageId, donotDelay)
    donotDelay = donotDelay or false
    if not donotDelay then
        G_commonLayerModel:setDelayUpdate(true)
    end

    local ExecuteStageMsg = {id = stageId}
    local msgBuffer = protobuf.encode("cs.C2S_Hard_ExecuteStage", ExecuteStageMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_ExecuteStage, msgBuffer)
end

-- 请求秒杀
function HardDungeonHandler:sendFastExecuteStage(stageId)
    local FastExecuteStageMsg = {id = stageId}
    local msgBuffer = protobuf.encode("cs.C2S_Hard_FastExecuteStage", FastExecuteStageMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_FastExecuteStage, msgBuffer)
end

-- 第一次进入副本
function HardDungeonHandler:sendFirstEnterChapter(chapterId)
    local msg = {id = chapterId}
    local msgBuffer = protobuf.encode("cs.C2S_Hard_FirstEnterChapter", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_FirstEnterChapter, msgBuffer)
end

-- 收到第一次进入副本结果

function HardDungeonHandler:recvFirstEnterChapter(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_FirstEnterChapter", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.hardDungeonData:setFirstEnterChapter(decodeBuffer)
    end
end

-- 收到章节列表
function HardDungeonHandler:recvGetChapterList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_GetChapterList", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.hardDungeonData:setDungeonData(decodeBuffer.total_star,decodeBuffer.fast_execute_cd,decodeBuffer.fast_execute_time)
        G_Me.hardDungeonData:setChapterList(decodeBuffer.chapters)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_RECVCHAPTERLIST, nil, false,nil)
    end
end

-- 添加关卡
function HardDungeonHandler:recvAddStage(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_AddStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.hardDungeonData:addNewStage(decodeBuffer.chpt_id,decodeBuffer.stage)
         uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_UPDATESTAGE, nil, false,nil)
    end
end

-- 请求副本排名
function HardDungeonHandler:sendGetDungeonRank() 
        local DungeonRankMsg = {}
        local msgBuffer = protobuf.encode("cs.C2S_Hard_GetChapterRank", DungeonRankMsg) 
        self:sendMsg(NetMsg_ID.ID_C2S_Hard_GetChapterRank, msgBuffer)
end

-- 收到副本排名
function HardDungeonHandler:recvDungeonRank(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_GetChapterRank", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.hardDungeonData:setMyRank(decodeBuffer.self_rank)
            G_Me.hardDungeonData:addDungeonRankList(decodeBuffer.ranks)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_GETDUNGEONRANK, nil, false,nil)
        end
    end
end

-- 收到进入关卡条件
function HardDungeonHandler:recvExecuteStage(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_ExecuteStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.hardDungeonData:addStage(G_Me.hardDungeonData:getCurrChapterId(),decodeBuffer.stage)
            G_Me.hardDungeonData:addBattleRes(decodeBuffer)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_EXECUTESTAGE, nil, false,decodeBuffer)
    else
        __LogError("parse S2C_ExecuteStage error")
    end
end

-- 请求执行下一波数
function HardDungeonHandler:sendExecuteMultiStage(_stageid,_wave_id)
        local ExecuteMultiStageMsg = 
        {
            id = _stageid,
            wave_id = _wave_id
        }
        local msgBuffer = protobuf.encode("cs.C2S_Hard_ExecuteMultiStage", ExecuteMultiStageMsg) 
        self:sendMsg(NetMsg_ID.ID_C2S_Hard_ExecuteMultiStage, msgBuffer)
end


-- 收到波数请求
function HardDungeonHandler:recvExecuteMultiStage(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_ExecuteMultiStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
          if decodeBuffer.ret == G_NetMsgError.RET_OK then
              uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_ENTERBATTLE, nil, false,decodeBuffer)
          end
     end

end

-- 收到秒杀结果
function HardDungeonHandler:recvFastExecuteStage(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_FastExecuteStage", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.hardDungeonData:setFastExecuteCD(decodeBuffer.fast_execute_cd)
            G_Me.hardDungeonData:setFastExecuteTime(decodeBuffer.fast_execute_time)
            G_Me.hardDungeonData:addStage(G_Me.hardDungeonData:getCurrChapterId(),decodeBuffer.stage)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_FASTEXECUTESTAGE, nil, false,decodeBuffer)
    end
end


-- 宝箱奖励,(左下角的铜，银，金宝箱)
function HardDungeonHandler:sendFinishChapterBoxRwd(chapterId,_type)
    local FinishChapterBoxRwdMsg = 
    {
        ch_id = chapterId,
        box_type = _type
    }
    local msgBuffer = protobuf.encode("cs.C2S_Hard_FinishChapterBoxRwd", FinishChapterBoxRwdMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_FinishChapterBoxRwd, msgBuffer)
end

function HardDungeonHandler:recvFinishChapterBoxRwd(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_FinishChapterBoxRwd", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
             G_Me.hardDungeonData:setBoxIsOpen(decodeBuffer.ch_id,decodeBuffer.box_type)
         end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_GETBOUNSSUCC, nil, false,decodeBuffer)

     end
end

-- 星数奖励
function HardDungeonHandler:sendFinishChapterAchvRwd(_id)
    local FinishChapterAchvRwdMsg = 
    {
        rwd_id = _id,
    }
    local msgBuffer = protobuf.encode("cs.C2S_Hard_FinishChapterAchvRwd", FinishChapterAchvRwdMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_FinishChapterAchvRwd, msgBuffer)
end

function HardDungeonHandler:recvFinishChapterAchvRwd(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_FinishChapterAchvRwd", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
             G_Me.hardDungeonData:addToStarBounsList(decodeBuffer.rwd_id)
             uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_FINISHSTARBOUNS, nil, false,decodeBuffer)
         end
     end
end

-- 星数领取奖励
function HardDungeonHandler:sendFinishChapterAchvRwdInfo()
    local FinishChapterAchvRwdInfoMsg = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_Hard_ChapterAchvRwdInfo", FinishChapterAchvRwdInfoMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_ChapterAchvRwdInfo, msgBuffer)
end


function HardDungeonHandler:recvResetDungeonFastTimeCd(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_ResetDungeonFastTimeCd", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
             G_Me.hardDungeonData:setFastExecuteCD(decodeBuffer.fast_execute_cd)
             G_Me.hardDungeonData:setFastExecuteTime(decodeBuffer.fast_execute_time)
             G_MovingTip:showMovingTip(G_lang:get("LANG_CLEARCD_SUCC"))
         end
     end
end

-- 副本重置
function HardDungeonHandler:sendResetDungeonExecution(id)
    local ResetDungeonExecutionMsg = 
    {
        stage_id = id
    }
    local msgBuffer = protobuf.encode("cs.C2S_Hard_ResetDungeonExecution", ResetDungeonExecutionMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_ResetDungeonExecution, msgBuffer)
end

function HardDungeonHandler:recvResetDungeonExecution(msgId, msg, len)
     local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_ResetDungeonExecution", msg)
     if type(decodeBuffer) ~= "table" then 
        return 
    end
     if decodeBuffer then
         if decodeBuffer.ret == G_NetMsgError.RET_OK then
            G_Me.hardDungeonData:addStage(G_Me.hardDungeonData:getCurrChapterId(),decodeBuffer.stage)
            G_Me.hardDungeonData:setRestCost(decodeBuffer.next_reset_cost)
             G_MovingTip:showMovingTip(G_lang:get("LANG_DUNGEON_RESTDUNGEONSUCC"))
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_DUNGEON_DUNGEONRESTSUCC, nil, false,decodeBuffer)
         end
     end
end

-- 精英暴动
-------------------------------------------------------------------------------------

-- 请求获取暴动章节列表
function HardDungeonHandler:sendGetRiotChapterList()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_Hard_GetChapterRoit", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_GetChapterRoit, msgBuffer)    
end

-- 请求战斗
function HardDungeonHandler:sendGetRiotBattleInfo(nChapterId)
    local tMsg = { ch_id = nChapterId }
    local msgBuffer = protobuf.encode("cs.C2S_Hard_FinishChapterRoit", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Hard_FinishChapterRoit, msgBuffer)   
end

-- 获取到暴动章节列表
function HardDungeonHandler:recvGetRiotChapterList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_GetChapterRoit", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.hardDungeonData:storeRiotChapterList(decodeBuffer.roits)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_RIOT_UPDATE_MAIN_LAYER, nil, false, decodeBuffer)
    end
end

-- 获取到战斗信息（战报，战斗结果）
function HardDungeonHandler:recvGetRiotBattleInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Hard_FinishChapterRoit", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.hardDungeonData:storeRiotBattleResult(decodeBuffer)
        if decodeBuffer.info.is_win then
            G_Me.hardDungeonData:updateRiotChapter(decodeBuffer.roit)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HARD_RIOT_OPEN_BATTLE_SCENE, nil, false, decodeBuffer)
    end
end

return HardDungeonHandler

