
local HandlerBase = require("app.network.message.HandlerBase")
local ArenaHandler = class("ArenaHandler",HandlerBase)

function ArenaHandler:ctor(...)
   
end

function ArenaHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetArenaInfo, self._recvGetArenaInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChallengeArena, self._revChallengeResult, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetArenaTopInfo, self._revRankingList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetArenaUserInfo, self._recvUserInfo, self)

    -- 争粮战相关消息
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetUserRice, self._recvGetUserRice, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushRiceRivals, self._recvFlushRiceRivals, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RobRice, self._recvRobRice, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRiceEnemyInfo, self._recvGetRiceEnemyInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RevengeRiceEnemy, self._recvRevengeRiceEnemy, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRiceAchievement, self._recvGetRiceAchievement, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRiceRankList, self._recvGetRiceRankList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BuyRiceToken, self._recvBuyRiceToken, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRiceRankAward, self._recvGetRiceRankAward, self)

    ----------- 争粮战单纯服务端推送的协议 ----------------
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UpdateUserRice, self._recvUpdateUserRice, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChangeUserRice, self._recvChangeUserRice, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushRiceRank, self._recvFlushRiceRank, self)


end

-- 请求进入竞技场
function ArenaHandler:sendGetArenaInfo()
    local GetArenaInfo = {}
    __LogTag(TAG,"sendGetArenaInfo")
    local msgBuffer = protobuf.encode("cs.C2S_GetArenaInfo", GetArenaInfo) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetArenaInfo, msgBuffer)
end

-- 收到竞技场信息
function ArenaHandler:_recvGetArenaInfo(msgId, msg, len)
    __LogTag(TAG,"recvGetArenaInfo messageId = %d",msgId)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetArenaInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        --设置最高历史记录
        G_Me.arenaData:setMaxHistory(decodeBuffer.max_rank)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ARENA_LIST, nil, false, decodeBuffer)
    end
end


--发送挑战消息
function ArenaHandler:sendChallenge(ran)
    G_commonLayerModel:setDelayUpdate(true)

    __LogTag(TAG,"ArenaHandler:sendChallenge rank = %s",ran)
    local ChallengeUser = {
        rank = ran
    } 
    local msgBuffer = protobuf.encode("cs.C2S_ChallengeArena", ChallengeUser) 
    self:sendMsg(NetMsg_ID.ID_C2S_ChallengeArena, msgBuffer)
end

--接收挑战结果
function ArenaHandler:_revChallengeResult(msgId, msg, len)
    __LogTag(TAG,"_revChallengeResult messageId = %d",msgId)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ChallengeArena", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag(TAG,"_revChallengeResult ret = " .. decodeBuffer.ret)
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ARENA_CHALLENGE, nil, false, decodeBuffer)
    end
end


--发送竞技场排行榜消息

function ArenaHandler:sendRankingList()
    local ChallengeUser = {
    } 
    local msgBuffer = protobuf.encode("cs.C2S_GetArenaTopInfo", ChallengeUser) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetArenaTopInfo, msgBuffer)
end
--接收竞技场排行榜消息
function ArenaHandler:_revRankingList(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetArenaTopInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ARENA_RANKING_LIST, nil, false, decodeBuffer)
    end
end


--发送查看玩家阵容信息
function ArenaHandler:sendCheckUserInfo(userId)
    local user = {
        user_id = userId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetArenaUserInfo", user) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetArenaUserInfo, msgBuffer)
end
--接收玩家阵容信息
function ArenaHandler:_recvUserInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetArenaUserInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ARENA_USER_INFO, nil, false, decodeBuffer)
    end
end 

------------------------------------------争粮战------------------------------------------
-- 发送获取争粮战首页首页信息
function ArenaHandler:sendGetUserRice( ... )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetUserRice", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetUserRice, msgBuffer)
end

function ArenaHandler:_recvGetUserRice( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetUserRice", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 232 then
            G_Me.arenaRobRiceData:updateRiceRank(-1)
            G_Me.arenaRobRiceData:setAttendInfo(false)
            G_Me.arenaRobRiceData:updateAchievementState()
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICT_NOT_ATTENT, nil, false)    
        end
        
    end
end

-- 刷新争粮战的对手
function ArenaHandler:sendFlushRiceRivals( ... )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_FlushRiceRivals", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_FlushRiceRivals, msgBuffer)
end

-- TODO:上一个方法的返回没有走这个协议？？？
function ArenaHandler:_recvFlushRiceRivals( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushRiceRivals", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)
        -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_ROB_RICE, nil, false, decodeBuffer)
    end
end

-- 抢粮
function ArenaHandler:sendRobRice( userId )
    local msg = {
        user_id = userId
    }
    local msgBuffer = protobuf.encode("cs.C2S_RobRice", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_RobRice, msgBuffer)
end

function ArenaHandler:_recvRobRice( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_RobRice", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_ROB_RICE, nil, false, decodeBuffer)
    end
end

-- 获取抢粮对手信息
function ArenaHandler:sendGetRiceEnemyInfo(  )
    __Log("===========ArenaHandler:sendGetRiceEnemyInfo===================")
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetRiceEnemyInfo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetRiceEnemyInfo, msgBuffer)
end

function ArenaHandler:_recvGetRiceEnemyInfo( msgId, msg, len )
    __Log("===========ArenaHandler:_recvGetRiceEnemyInfo===================")
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRiceEnemyInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)
        G_Me.arenaRobRiceData:updateRiceEnemyInfo(decodeBuffer.enemys)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_GET_RICE_ENEMY, nil, false)
    end
end

-- 复仇
function ArenaHandler:sendRevengeRiceEnemy( enemyId )
    local msg = {
        enemy_id = enemyId
    }
    local msgBuffer = protobuf.encode("cs.C2S_RevengeRiceEnemy", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_RevengeRiceEnemy, msgBuffer)
 end 

function ArenaHandler:_recvRevengeRiceEnemy( msgId, msg, len )
    __Log("===========ArenaHandler:_recvRevengeRiceEnemy===================")
    local decodeBuffer = self:_decodeBuf("cs.S2C_RevengeRiceEnemy", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_GET_REVENGE_ENEMY, nil, false, decodeBuffer)
    end
end

-- 获取成就奖励
function ArenaHandler:sendGetRiceAchievement( achievementId )
    local msg = {
        achievement_id = achievementId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetRiceAchievement", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetRiceAchievement, msgBuffer)
end

function ArenaHandler:_recvGetRiceAchievement( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRiceAchievement", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)
        if decodeBuffer.ret == 1 then
            G_Me.arenaRobRiceData:updateAchievementList(decodeBuffer.achievement_id)
        end
        G_Me.arenaRobRiceData:setAchievementId(decodeBuffer.achievement_id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_GET_RICE_ACHIEVEMENT, nil, false, decodeBuffer)
    end
end

-- 获取粮草排行
function ArenaHandler:sendGetRiceRankList(  )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetRiceRankList", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetRiceRankList, msgBuffer)
end

function ArenaHandler:_recvGetRiceRankList( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRiceRankList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.arenaRobRiceData:updateRankList(decodeBuffer.rank_list)
        local myRank = rawget(decodeBuffer, "my_rank")
        if myRank ~= nil then
            if myRank > 200 then
                myRank = 0
            end
            G_Me.arenaRobRiceData:updateRiceRank(myRank)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_RANK_LIST, nil, false)
    end
end

-- 购买抢夺、复仇次数
function ArenaHandler:sendBuyRiceToken( type, totalNum )
    local msg = {
        token_type = type,
        num = totalNum
    }
    local msgBuffer = protobuf.encode("cs.C2S_BuyRiceToken", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_BuyRiceToken, msgBuffer)
end

function ArenaHandler:_recvBuyRiceToken( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_BuyRiceToken", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer then
        -- dump(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_BUY_RICE_TOKEN, nil, false, decodeBuffer)
    end
end

function ArenaHandler:sendGetRiceRankAward( ... )
    local msg = {}

    local msgBuffer = protobuf.encode("cs.C2S_GetRiceRankAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetRiceRankAward, msgBuffer)

end

function ArenaHandler:_recvGetRiceRankAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRiceRankAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer then
        -- dump(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_GET_RANK_AWARD, nil, false, decodeBuffer)
    end
end

---------------------------------- 争粮战之单纯服务端推送协议 ----------------------------------
-- 更新玩家粮草信息
function ArenaHandler:_recvUpdateUserRice( msgId, msg, len )
    -- __Log("=====ArenaHandler:_recvUpdateUserRice=============")
    local decodeBuffer = self:_decodeBuf("cs.S2C_UpdateUserRice", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)

        G_Me.arenaRobRiceData:updateUserRiceInfo(decodeBuffer.user_rice)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_UPDATE_USER_RICE, nil, false)
    end
    -- __Log("=====ArenaHandler:_recvUpdateUserRice=============")
end

-- 改变玩家粮草？？？
function ArenaHandler:_recvChangeUserRice( msgId, msg, len )
    
end

-- 玩家排名推送
function ArenaHandler:_recvFlushRiceRank( msgId, msg, len )
    -- __Log("=====ArenaHandler:_recvFlushRiceRank=============")
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushRiceRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        -- dump(decodeBuffer)
        -- __Log(decodeBuffer.rob_token)
        G_Me.arenaRobRiceData:updateRiceRank(decodeBuffer.rice_rank)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_RICE_FLUSH_USER_RANK, nil, false)
    end
    -- __Log("=====ArenaHandler:_recvFlushRiceRank=============")
end

return ArenaHandler

