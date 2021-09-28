local MoShenHandler = class("MoShenHandler ", require("app.network.message.HandlerBase"))

function MoShenHandler:_onCtor( ... )
    
end

function MoShenHandler :initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRebel, self._recvGetRebel, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_EnterRebelUI, self._recvEnterRebelUI, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AttackRebel, self._recvAttackRebel, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PublicRebel, self._recvPublicRebel, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RebelRank, self._recvRebelRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_MyRebelRank, self._recvMyRebelRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RefreshRebel, self._recvRefreshRebel, self)
    -- uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChooseFriend, self._recvChooseFriend, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetExploitAward, self._recvGetExploitAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetExploitAwardType, self._recvGetExploitAwardType, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RefreshRebelShow, self._recvRefreshRebelShow, self)

    -- 世界Boss
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_EnterRebelBossUI, self._recvEnterRebelBossUI, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SelectAttackRebelBossGroup, self._recvSelectAttackRebelBossGroup, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChallengeRebelBoss, self._recvChallengeRebelBoss, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RebelBossRank, self._recvRebelBossRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RebelBossAwardInfo, self._recvRebelBossAwardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RebelBossCorpAwardInfo, self._recvRebelBossCorpAwardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RebelBossAward, self._recvRebelBossAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RefreshRebelBoss, self._recvRefreshRebelBoss, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PurchaseAttackCount, self._recvPurchaseAttackCount, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRebelBossReport, self._recvGetRebelBossReport, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushBossACountTime, self._recvFlushBossACountTime, self)

end

--副本 获取叛军消息
function MoShenHandler:_recvGetRebel( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRebel", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_GET_REB, nil, false, decodeBuffer)
    end
end

--进入叛军界面
function MoShenHandler:sendEnterRebelUI()
    __LogTag(TAG,"ShopHandler:sendEnterRebelUI")
    local rebel = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_EnterRebelUI", rebel) 
    self:sendMsg(NetMsg_ID.ID_C2S_EnterRebelUI, msgBuffer)
end

--接收进入叛军界面的消息
function MoShenHandler:_recvEnterRebelUI( msgId, msg, len)
    __LogTag(TAG,"MoShenHandler:_recvEnterRebelUI")
    local decodeBuffer = self:_decodeBuf("cs.S2C_EnterRebelUI", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        --设置功勋,功勋排行,伤害排行,最高伤害
        G_Me.moshenData:setGongXun(decodeBuffer.exploit)
        G_Me.moshenData:setGongXunRank(decodeBuffer.exploit_rank)
        G_Me.moshenData:setHarmRank(decodeBuffer.max_harm_rank)
        G_Me.moshenData:setMaxHarm(decodeBuffer.max_harm)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_ENTER_REBEL_UI, nil, false, decodeBuffer)
    end
end

--攻击叛军类型（普通攻击 or 全力一击）
function MoShenHandler:sendAttackRebel(_user_id,_mode)
    G_commonLayerModel:setDelayUpdate(true)
    local AttackRebel = {
        user_id = _user_id,
        mode = _mode
    }
    local msgBuffer = protobuf.encode("cs.C2S_AttackRebel", AttackRebel) 
    self:sendMsg(NetMsg_ID.ID_C2S_AttackRebel, msgBuffer)
end

--接收攻击叛军返回的结果
--[[
    message S2C_AttackRebel {
        required uint32 ret = 1;
        optional BattleReport report = 2;
        optional uint32 exploit = 3;
        optional uint32 harm = 4;
        optional bool public = 5;
    }
]]

function MoShenHandler:_recvAttackRebel(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_AttackRebel", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            G_Me.moshenData:addGongXun(decodeBuffer.exploit)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_ATTACK_REBEL, nil, false, decodeBuffer)
    end
end

--分享好友
function MoShenHandler:sendPublicRebel()
    local PublicRebel = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_PublicRebel", PublicRebel) 
    self:sendMsg(NetMsg_ID.ID_C2S_PublicRebel, msgBuffer)
end

--接收分享好友结果
--[[
    message S2C_PublicRebel {
        required uint32 ret = 1;
    }
]]
function MoShenHandler:_recvPublicRebel(msgId,msg,len)
    __LogTag(TAG,"MoShenHandler:_recvPublicRebel")
    local decodeBuffer = self:_decodeBuf("cs.S2C_PublicRebel", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_PUBLIC_REBEL, nil, false, decodeBuffer)
    end
end

--排行榜,功勋排行和伤害排行
function MoShenHandler:sendRebelRank()
    __LogTag(TAG,"ShopHandler:sendPublicRebel")
    local RebelRank = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RebelRank", RebelRank) 
    self:sendMsg(NetMsg_ID.ID_C2S_RebelRank, msgBuffer)
end

--接收排行榜消息
--[[
    message RebelRank {
        required uint32 id = 1;
        required uint32 level = 2;
        required uint32 value = 3;
        required uint32 attack_value = 4;
        required uint32 rank = 5;
        required string name = 6;
    }
    message S2C_RebelRank {
      required uint32 ret = 1;
      repeated RebelRank exploit_rank = 2; 
      repeated RebelRank max_harm_rank = 3; 
    }
]]
function MoShenHandler:_recvRebelRank(msgId,msg,len)
    __LogTag(TAG,"MoShenHandler:_recvRebelRank")
    local decodeBuffer = self:_decodeBuf("cs.S2C_RebelRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            -- G_Me.moshenData:setGongXunRank(decodeBuffer.exploit_rank)
            -- G_Me.moshenData:setHarmRank(decodeBuffer.max_harm_rank)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_REBEL_RANK, nil, false, decodeBuffer)
    end
end

--我的排名
--[[
    enum REBEL_RANK_TYPE {
        EXPLOIT = 1;
        MAX_HARM = 2;
    }
]]
function MoShenHandler:sendMyRebelRank(_mode)
    __LogTag(TAG,"ShopHandler:sendMyRebelRank")
    local MyRebelRank = {
        mode = _mode
    }
    local msgBuffer = protobuf.encode("cs.C2S_MyRebelRank", MyRebelRank) 
    self:sendMsg(NetMsg_ID.ID_C2S_MyRebelRank, msgBuffer)
end

--[[
    message S2C_MyRebelRank {
        required uint32 ret = 1;
        required uint32 mode = 2;
        repeated RebelRank rank = 3;
    }
]]

function MoShenHandler:_recvMyRebelRank(msgId,msg,len)
    __LogTag(TAG,"MoShenHandler:_recvMyRebelRank")
    local decodeBuffer = self:_decodeBuf("cs.S2C_MyRebelRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_MY_REBEL_RANK, nil, false, decodeBuffer)
    end
end


--刷新boss
--[[
    message C2S_RefreshRebel {
    }
]]
function MoShenHandler:sendRefreshRebel()
    __LogTag(TAG,"ShopHandler:sendMyRebelRank")
    local RefreshRebel = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RefreshRebel", RefreshRebel) 
    self:sendMsg(NetMsg_ID.ID_C2S_RefreshRebel, msgBuffer)
end

--[[
    message S2C_RefreshRebel {
      required uint32 ret = 1;
      repeated Rebel rebels = 2;
    }
]]
function MoShenHandler:_recvRefreshRebel(msgId,msg,len)
    __LogTag(TAG,"MoShenHandler:_recvRefreshRebel")
    local decodeBuffer = self:_decodeBuf("cs.S2C_RefreshRebel", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_REFRESH_REBEL, nil, false, decodeBuffer)
    end
end


--功勋奖励类型
--[[]]
function MoShenHandler:sendGetExploitAwardType()
    __LogTag(TAG,"ShopHandler:sendGetExploitAwardType")
    local GetExploitAwardType = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetExploitAwardType", GetExploitAwardType) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetExploitAwardType, msgBuffer)
end
--[[
    message S2C_GetExploitAwardType {
        required uint32 mode = 1;
    }
]]
function MoShenHandler:_recvGetExploitAwardType(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetExploitAwardType", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        --获取已领取列表
        G_Me.moshenData:setAwardSignList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_GET_EXPLOIT_AWARD_TYPE, nil, false, decodeBuffer)
    end
end




--领取功勋奖励
--[[
    message C2S_GetExploitAward {
        required uint32 id = 1;
    }
]]
function MoShenHandler:sendGetExploitAward(_id)
    __LogTag(TAG,"ShopHandler:sendGetExploitAward id = %s",_id)
    local GetExploitAward = {
        id = _id
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetExploitAward", GetExploitAward) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetExploitAward, msgBuffer)
end

--[[
    message S2C_GetExploitAward {
        required uint32 ret = 1;
        required uint32 id = 2;.
        optional Award award = 3;
    }
]]
function MoShenHandler:_recvGetExploitAward(msgId,msg,len)
    __LogTag(TAG,"MoShenHandler:_recvRefreshRebel")
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetExploitAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            --标记该奖励已领取
            G_Me.moshenData:setAwardSign(decodeBuffer.id) 
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_GET_EXPLOIT_AWARD, nil, false, decodeBuffer)
    end
end


--[[
    刷新当前pageview的boss血量
]]


--[[
    显示boss被攻击的状态
]]
function MoShenHandler:sendRefreshRebelShow(ids,_last_att_indexs)
    local RefreshRebelShow = {
        rebel_ids = ids,
        last_att_indexs = _last_att_indexs
    }
    local msgBuffer = protobuf.encode("cs.C2S_RefreshRebelShow", RefreshRebelShow) 
    self:sendMsg(NetMsg_ID.ID_C2S_RefreshRebelShow, msgBuffer)
end

function MoShenHandler:_recvRefreshRebelShow(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RefreshRebelShow", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MOSHEN_REFRESH_REBEL_SHOW, nil, false, decodeBuffer)
    end
end

---------------------------------------------------------------------------------------------
-- 世界Boss

--[[
message RebelBoss {
    required uint32 id =1;             
    required string name = 2;
    required uint64 hp = 3;
    required uint64 max_hp = 4;
    required uint32 level = 5;
    required uint32 end_time = 6; 
    optional string killer_name = 7;
    optional uint32 killer_time = 8;
    required uint32 last_att_index = 9;
}

message C2S_EnterRebelBossUI {
}

message S2C_EnterRebelBossUI {
    required uint32 ret = 1;
    required uint32 total_honor = 2;
    required uint32 group_thonor_rank = 3;
    required uint32 max_harm = 4;
    required uint32 group_mharm_rank = 5;
    required uint64 total_harm = 6;
    required uint32 corp_rank = 7;
    required RebelBoss rebel_boss = 8; 
    required uint32 state = 9;                     //0:活动关闭或者BOSS 挂掉 1:活动期间
    repeated RebelBossRank group_first_ranks = 10; //各阵容累计荣誉排名第一
    optional uint32 att_count = 11;                //攻击次数
    optional uint32 enc_count = 12;                //成功鼓舞次数
    optional uint32 group = 13;                    //所在阵容
}

message C2S_RebelBossEncourage {
}

message S2C_RebelBossEncourage {
    required uint32 ret = 1;
    optional bool success = 2;
    optional uint32 total_count = 3;
    optional uint32 count = 4;
}

message C2S_SelectAttackRebelBossGroup {
    required uint32 group  = 1;
}

message S2C_SelectAttackRebelBossGroup {
    required uint32 ret = 1;
    required uint32 group  = 2;
}

message C2S_ChallengeRebelBoss {
}

message S2C_ChallengeRebelBoss {
    required uint32 ret = 1;
    optional BattleReport report = 2;
    optional uint32 honor = 3;   //荣誉
    optional uint32 harm = 4;    //伤害
    optional Award faward = 5;   //第一次攻击奖励
    optional Award kaward = 6;   //击杀奖励
    optional Award award = 7;    //攻击奖励 
}

message RebelBossRank {
    required uint32 id = 1;
    required uint32 fight_value = 2;  //战力
    required uint32 mode = 3; //1:累计荣誉 2:最高伤害
    required uint64 value = 4;   
    required uint32 rank = 5;
    required string name = 6;
    required string corp_name = 7;
    required uint32 user_id = 8;
    required uint32 dress_id = 9;
}

message RebelBossSimpleRank {
    required uint32 rank = 1;
    required uint32 group = 2;
    required uint64 value = 3; //累计荣誉,最高伤害
}

enum REBEL_BOSS_RANK_TYPE {
    RANK_HONOR = 1;
    RANK_MAX_HARM = 2;
}

message C2S_RebelBossRank {
    required uint32 mode = 1;
    required uint32 group = 2;
}

message S2C_RebelBossRank {
    required uint32 ret = 1;
    optional uint32 mode = 2;
    optional uint32 group = 3;
    repeated RebelBossRank rbh_ranks = 4;    //累计荣誉排名
    repeated RebelBossRank rbmh_ranks = 5;   //最高伤害排名
    optional RebelBossSimpleRank rbh_my_rank = 6;
    optional RebelBossSimpleRank rbmh_my_rank = 7;
}

enum REBEL_BOSS_AWARD_TYPE {
    AWARD_HARM = 1;
    AWARD_CORP_HONOR = 2;
}

message C2S_RebelBossAwardInfo {
    required uint32 mode = 1;
}

message S2C_RebelBossAwardInfo {
    required uint32 ret = 1;
    required uint32 mode = 2;
    repeated uint32 status = 3; //0:未领取 1:已领取
}

message C2S_RebelBossAward {
    required uint32 mode = 1;   //1:击杀奖励 2:军团奖励 
    required uint32 id = 2;   //
}

message S2C_RebelBossAward {
    required uint32 ret = 1;
    required uint32 id = 2;
    optional Award award = 3;
}

message AttackRebelBossInfo {
    required string name = 1;
    required uint32 harm = 2;
}

//5s 刷新一次BOSS信息
message C2S_RefreshRebelBoss {
    required uint32 last_att_index = 1;
}

message S2C_RefreshRebelBoss {
    required uint32 ret = 1;
    required RebelBoss rebel_boss = 2;
    repeated AttackRebelBossInfo infos = 3;
}

message C2S_PurchaseAttackCount {
}

message S2C_PurchaseAttackCount {
    required uint32 ret = 1;
    required uint32 attack_count = 2;    //可攻击次数
    required uint32 remain_pur_count = 3;//剩余购买挑战次数
}

message C2S_RebelBossCorpAwardInfo {
}


message RebelBoss_CorpRank {
    required uint32 rank = 1;
    required string corp_name = 2;
    required uint32 honor = 3;
    optional uint32 state = 4; //1:活动开启中(000) 2:活动关闭中(100) 3:已经领取(010) 4:未领取(000) 5:达到领取条件(001) 6:未达到领取条件(000) 
}

message S2C_RebelBossCorpAwardInfo {
    required uint32 ret = 1;
    repeated RebelBoss_CorpRank ranks = 2;
    optional RebelBoss_CorpRank my_rank = 3;
}



]]

-- 进入叛军Boss主界面，要请求拉取一次数据
function MoShenHandler:sendEnterRebelBossUI()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_EnterRebelBossUI", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_EnterRebelBossUI, msgBuffer)
end

function MoShenHandler:_recvEnterRebelBossUI(msgId,msg,len)
    __Log("-- _recvEnterRebelBossUI")
    local decodeBuffer = self:_decodeBuf("cs.S2C_EnterRebelBossUI", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeInitializeInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_ENTER_MAIN_LAYER, nil, false, decodeBuffer)
    end
end

-- 选择自己的阵营
function MoShenHandler:sendSelectAttackRebelBossGroup(nGroup)
    local tMsg = {
        group = nGroup,
    }
    local msgBuffer = protobuf.encode("cs.C2S_SelectAttackRebelBossGroup", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_SelectAttackRebelBossGroup, msgBuffer)
end

function MoShenHandler:_recvSelectAttackRebelBossGroup(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_SelectAttackRebelBossGroup", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeMyGroup(decodeBuffer.group)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_CHOOSE_GROUP_SUCC, nil, false, decodeBuffer)
    end
end

-- 请求战斗
function MoShenHandler:sendChallengeRebelBoss(nTime)
    local tMsg = {
        time = nTime
    }
    local msgBuffer = protobuf.encode("cs.C2S_ChallengeRebelBoss", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ChallengeRebelBoss, msgBuffer)
end

function MoShenHandler:_recvChallengeRebelBoss(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ChallengeRebelBoss", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeRebelBossBattleResult(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_OPEN_BATTLE_SCENE, nil, false, decodeBuffer)
    end
end

-- 请求排行榜
-- nMode, 荣誉排行，最高伤害排行
-- nGroup 阵营
function MoShenHandler:sendRebelBossRank(nMode, nGroup)
    local tMsg = {
       mode = nMode,
       group = nGroup 
    }
    local msgBuffer = protobuf.encode("cs.C2S_RebelBossRank", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RebelBossRank, msgBuffer)
end

function MoShenHandler:_recvRebelBossRank(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RebelBossRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeRankList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_HONOR_RANK, nil, false, decodeBuffer)  
    end
end

-- 请求奖励列表
-- nMode 1:荣誉奖励 2:Boss等级 
function MoShenHandler:sendRebelBossAwardInfo(nMode)
    local tMsg = {
       mode = nMode,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RebelBossAwardInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RebelBossAwardInfo, msgBuffer)
end

function MoShenHandler:_recvRebelBossAwardInfo(msgId,msg,len)
    __Log("-- _recvRebelBossAwardInfo")
    local decodeBuffer = self:_decodeBuf("cs.S2C_RebelBossAwardInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeClaimedAwardList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_CLAIMED_AWARD_LIST, nil, false, decodeBuffer.mode)
    end
end

-- 请求奖励列表
-- nMode  3:军团奖励
function MoShenHandler:sendRebelBossCorpAwardInfo()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_RebelBossCorpAwardInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RebelBossCorpAwardInfo, msgBuffer)
end

function MoShenHandler:_recvRebelBossCorpAwardInfo(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RebelBossCorpAwardInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeLegionRankInfoList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_CLAIMED_AWARD_LIST, nil, false, 3)
        -- 更新征战界面的快捷入口和红点
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_SHOW_QUICK_ENTER, nil, false, 3)
    end
end

-- 请求领取奖励(荣誉、Boss等级、军团)
function MoShenHandler:sendRebelBossAward(nMode, nId)
    local tMsg = {
       mode = nMode,
       id = nId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RebelBossAward", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RebelBossAward, msgBuffer)
end

function MoShenHandler:_recvRebelBossAward(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RebelBossAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_CLIAM_AWARD_SUCC, nil, false, decodeBuffer)
    end
end

-- 每过5秒，更新一次界面
function MoShenHandler:sendRefreshRebelBoss(nLastAttackIndex)
    local tMsg = {
       last_att_index = nLastAttackIndex,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RefreshRebelBoss", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RefreshRebelBoss, msgBuffer)
end

function MoShenHandler:_recvRefreshRebelBoss(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RefreshRebelBoss", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:updateRebelBoss(decodeBuffer.rebel_boss)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MAIN_LAYER_EACH_5_SECONDS, nil, false, decodeBuffer)
    end
end

-- 购买挑战次数
function MoShenHandler:sendPurchaseAttackCount(nCount)
    local tMsg = {
        count = nCount,
    }
    local msgBuffer = protobuf.encode("cs.C2S_PurchaseAttackCount", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_PurchaseAttackCount, msgBuffer)
end

function MoShenHandler:_recvPurchaseAttackCount(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_PurchaseAttackCount", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:updateChallengeTime(decodeBuffer.attack_count)
        G_Me.moshenData:updateRemainPurchaseTime(decodeBuffer.remain_pur_count)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_PURCHASE_CHALLENGE_TIME_SUCC, nil, false, decodeBuffer)
    end
end

-- Boss战报
function MoShenHandler:sendGetRebelBossReport()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetRebelBossReport", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetRebelBossReport, msgBuffer)
end

function MoShenHandler:_recvGetRebelBossReport(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRebelBossReport", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeBossReport(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_BOSS_REPORT, nil, false, decodeBuffer)
    end
end

-- 挑战次数恢复时间
function MoShenHandler:sendFlushBossACountTime()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_FlushBossACountTime", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_FlushBossACountTime, msgBuffer)
end

function MoShenHandler:_recvFlushBossACountTime(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushBossACountTime", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.moshenData:storeRecoverTimestamp(decodeBuffer.attack_count_time)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_CHALLENGE_TIME_RECOVER, nil, false, decodeBuffer)
    end
end


return MoShenHandler
