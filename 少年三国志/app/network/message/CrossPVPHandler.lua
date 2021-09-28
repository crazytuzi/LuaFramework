
local HandlerBase = require("app.network.message.HandlerBase")
local CrossPVPHandler = class("CrossPVPHandler",HandlerBase)

function CrossPVPHandler:ctor(...)
end

function CrossPVPHandler:initHandler( ... )
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpSchedule, self._onGetSchedule, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpBaseInfo, self._onGetBaseInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpScheduleInfo, self._onGetFieldInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ApplyCrossPvp, self._onApply, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossWaitRank, self._onGetLastRank, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossWaitInit, self._onGetReviewInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossWaitInitFlowerInfo, self._onGetBetInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossWaitFlower, self._onBet, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossWaitFlowerAward, self._onGetBetAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossWaitFlowerRank, self._onGetBetRank, self)

    -- 鼓舞
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ApplyAtcAndDefCrossPvp, self._recvApplyAtcAndDefCrossPvp, self)
    -- 战斗
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpRole, self._recvGetCrossPvpRole, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpArena, self._recvGetCrossPvpArena, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCrossPvpArena, self._recvFlushCrossPvpArena, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCrossPvpSpecific, self._recvFlushCrossPvpSpecific, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCrossPvpScore, self._recvFlushCrossPvpScore, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossPvpBattle, self._recvCrossPvpBattle, self)  
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpRank, self._recvGetCrossPvpRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossPvpOb, self._recvGetCrossPvpOb, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossPvpGetAward, self._recvCrossPvpGetAward, self)

    -- 弹幕
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetBulletScreenInfo, self._recvGetBulletScreenInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SendBulletScreenInfo, self._recvSendBulletScreenInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushBulletScreen, self._recvFlushBulletScreen, self)
        

    
end

-- 拉取所有比赛时间和赛场配置
function CrossPVPHandler:sendGetSchedule()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossPvpSchedule", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpSchedule, msgBuf)
	--__LogTag(TAG, "----请求时间")
end

function CrossPVPHandler:_onGetSchedule(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpSchedule", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----收到时间")
		G_Me.crossPVPData:updateScheduleInfo(decodeBuffer.schedule)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_SCHEDULE, nil, false)
    else
        require("app.scenes.crosspvp.CrossPVP").matchNotOpen()
	end
end

-- 拉取玩家的基本比赛信息
function CrossPVPHandler:sendGetBaseInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossPvpBaseInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpBaseInfo, msgBuf)
	--__LogTag(TAG, "----请求BaseInfo")
end

function CrossPVPHandler:_onGetBaseInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpBaseInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----收到BaseInfo")
		G_Me.crossPVPData:updateBaseInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BASE_INFO, nil, false, decodeBuffer)
	end
end

-- 拉取每个赛区的信息
function CrossPVPHandler:sendGetFieldInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossPvpScheduleInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpScheduleInfo, msgBuf)
	--__LogTag(TAG, "----请求赛场信息")
end

function CrossPVPHandler:_onGetFieldInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpScheduleInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----收到赛场信息")
		G_Me.crossPVPData:updateFieldInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_FIELD_INFO, nil, false)
	end
end

-- 发送报名请求
function CrossPVPHandler:sendApply(battlefield)
	local buffer = { stage = battlefield }
	local msgBuf = protobuf.encode("cs.C2S_ApplyCrossPvp", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_ApplyCrossPvp, msgBuf)
	--__LogTag(TAG, "----请求报名: " .. battlefield)
end

function CrossPVPHandler:_onApply(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_ApplyCrossPvp", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK or decodeBuffer.ret == NetMsg_ERROR.RET_CROSS_PVP_APPLY_FULL then
		--__LogTag(TAG, "----收到报名结果:" .. tostring(decodeBuffer.ret) .. " 赛区：".. tostring(decodeBuffer.stage) .. " 当前人数：" .. tostring(decodeBuffer.num))
        local isFull = decodeBuffer.ret == NetMsg_ERROR.RET_CROSS_PVP_APPLY_FULL
		G_Me.crossPVPData:updateApplyInfo(decodeBuffer, isFull)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_APPLY, nil, false, isFull)
	end
end

-- 拉取某个赛区上一轮的排行
function CrossPVPHandler:sendGetLastRank(battlefield, startRank, endRank)
	local buffer =
	{
		stage = battlefield,
		start = startRank,
		finish = endRank
	}
	local msgBuf = protobuf.encode("cs.C2S_CrossWaitRank", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossWaitRank, msgBuf)
	--__LogTag(TAG, "----请求上一轮排行：" .. battlefield .. " (" .. startRank .. "," .. endRank .. ")")
end

function CrossPVPHandler:_onGetLastRank(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossWaitRank", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_LAST_RANK, nil, false, decodeBuffer)
	end
end

-- 拉取上轮回顾信息
function CrossPVPHandler:sendGetReviewInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_CrossWaitInit", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossWaitInit, msgBuf)
	--__LogTag(TAG, "----请求上轮回顾信息")
end

function CrossPVPHandler:_onGetReviewInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossWaitInit", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----收到上轮回顾信息")
		G_Me.crossPVPData:updateReviewInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO, nil, false)
	end
end

-- 拉取当前的押注信息
function CrossPVPHandler:sendGetBetInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_CrossWaitInitFlowerInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossWaitInitFlowerInfo, msgBuf)
	--__LogTag(TAG, "----请求押注信息")
end

function CrossPVPHandler:_onGetBetInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossWaitInitFlowerInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----收到押注信息")
		G_Me.crossPVPData:updateBetInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_INFO, nil, false, decodeBuffer)
	end
end

-- 进行押注
function CrossPVPHandler:sendBet(userID, serverID, fieldID, betType, betCount)
	local buffer = 
	{
		sid 	= serverID,
		role_id = userID,
		stage 	= fieldID,
		type 	= betType,
		count 	= betCount,
	}
	local msgBuf = protobuf.encode("cs.C2S_CrossWaitFlower", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossWaitFlower, msgBuf)
	--__LogTag(TAG, "----进行押注，ID：" .. userID .. " SID：" .. serverID .. " 类型：" .. betType .. " 数量：" .. betCount)
end

function CrossPVPHandler:_onBet(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossWaitFlower", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----押注完成")
		G_Me.crossPVPData:addBetNum(decodeBuffer.type, decodeBuffer.count)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_BET_FINISH, nil, false, decodeBuffer)
	end
end

-- 领取投注奖励
function CrossPVPHandler:sendGetBetAward(betType)
    local buffer =
    {
        type = betType
    }
    local msgBuf = protobuf.encode("cs.C2S_CrossWaitFlowerAward", buffer)
    self:sendMsg(NetMsg_ID.ID_C2S_CrossWaitFlowerAward, msgBuf)
    --__LogTag(TAG, "----领取投注奖励：" .. betType)
end

function CrossPVPHandler:_onGetBetAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossWaitFlowerAward", msg, len)
    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        --__LogTag(TAG, "----领取投注奖励完成")
        G_Me.crossPVPData:onGetBetAward(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_AWARD, nil, false, decodeBuffer)
    end
end

-- 拉取投注榜
function CrossPVPHandler:sendGetBetRank(startRank, finishRank)
    local buffer = 
    {
        type = 0,
        start = startRank,
        finish = finishRank,
    }
    local msgBuf = protobuf.encode("cs.C2S_CrossWaitFlowerRank", buffer)
    self:sendMsg(NetMsg_ID.ID_C2S_CrossWaitFlowerRank, msgBuf)
    --__LogTag(TAG, "----拉取投注榜")
end

function CrossPVPHandler:_onGetBetRank(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossWaitFlowerRank", msg, len)
    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        --__LogTag(TAG, "----拉取投注榜完成")
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_RANK, nil, false, decodeBuffer)
    end
end
--------------------------------------------------------------------

function CrossPVPHandler:sendGetCrossPvpRole()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossPvpRole", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpRole, msgBuffer)
    --__LogTag(TAG, "----拉取房间号")
end

function CrossPVPHandler:_recvGetCrossPvpRole(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpRole", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        --__LogTag(TAG, "----拉取房间号成功")
        G_Me.crossPVPData:updateRoomInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_ROLE_SUCC, nil, false, true)
    else
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_ROLE_SUCC, nil, false, false)
    end
end

function CrossPVPHandler:sendApplyAtcAndDefCrossPvp(nInspireType)
    local tMsg = {
        apply_type = nInspireType
    }
    local msgBuffer = protobuf.encode("cs.C2S_ApplyAtcAndDefCrossPvp", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ApplyAtcAndDefCrossPvp, msgBuffer)
end

function CrossPVPHandler:_recvApplyAtcAndDefCrossPvp(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ApplyAtcAndDefCrossPvp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        -- 更新鼓舞次数
        G_Me.crossPVPData:storeInspireInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_INSPIRE_SUCC, nil, false, decodeBuffer)    
    end
end

-- 进入到战斗状态界面
-- nStage 战场（中，初，高，至尊）
-- nRoom 
function CrossPVPHandler:sendGetCrossPvpArena(nStage, nRoom)
    local tMsg = {
        stage = nStage,
        room = nRoom,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossPvpArena", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpArena, msgBuffer)
end

function CrossPVPHandler:_recvGetCrossPvpArena(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpArena", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_ENTER_FIGHT_MAIN_LAYER, nil, false, decodeBuffer.flags)    
    end
end

-- 更新每个坑位
function CrossPVPHandler:_recvFlushCrossPvpArena(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCrossPvpArena", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_ARENA, nil, false, decodeBuffer)    
end

-- 更新每个坑位，特殊情况（占坑时间到、被别人T下来了）
function CrossPVPHandler:_recvFlushCrossPvpSpecific(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCrossPvpSpecific", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_ARENA_SPECIAL, nil, false, decodeBuffer)    
end

-- 打架时，左上角自己的积分变化
function CrossPVPHandler:_recvFlushCrossPvpScore(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCrossPvpScore", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_SELF_SCORE, nil, false, decodeBuffer)    
end

-- 真正的打一场架
function CrossPVPHandler:sendCrossPvpBattle(nStage, nRoom, nFlag)
    local tMsg = {
        stage = nStage,
        room = nRoom,
        flag = nFlag,
    }
    local msgBuffer = protobuf.encode("cs.C2S_CrossPvpBattle", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_CrossPvpBattle, msgBuffer)
end

function CrossPVPHandler:_recvCrossPvpBattle(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossPvpBattle", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_FIGHT_SOMEONE_SUCC, nil, false, decodeBuffer)    
    end
end

function CrossPVPHandler:sendGetCrossPvpRank(nStage, nRoom)
    local tMsg = {
        stage = nStage,
        room = nRoom,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossPvpRank", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpRank, msgBuffer)
end

function CrossPVPHandler:_recvGetCrossPvpRank(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_SCORE_RANK_SUCC, nil, false, decodeBuffer)    
    end
end

function CrossPVPHandler:sendGetCrossPvpOb()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossPvpOb", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossPvpOb, msgBuffer)
end

function CrossPVPHandler:_recvGetCrossPvpOb(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossPvpOb", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_OB_RIGHT_SUCC, nil, false, decodeBuffer)    
    end
end

function CrossPVPHandler:sendCrossPvpGetAward()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_CrossPvpGetAward", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_CrossPvpGetAward, msgBuffer)
    --__LogTag("----请求领取比赛奖励")
end

function CrossPVPHandler:_recvCrossPvpGetAward(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossPvpGetAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        --__LogTag("----领取比赛奖励成功")
        G_Me.crossPVPData:onGetMatchAward()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_PROMOTED_AWARD_SUCC, nil, false, decodeBuffer)    
    end
end

--------------------------------------------------------------------------------------------
function CrossPVPHandler:sendGetBulletScreenInfo(nId)
    local tMsg = {
        id = nId
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetBulletScreenInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetBulletScreenInfo, msgBuffer)
end

function CrossPVPHandler:_recvGetBulletScreenInfo(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetBulletScreenInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.crossPVPData:setLastSendBSTime(decodeBuffer.last_send_time)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BULLET_SCREEN_INFO_SUCC, nil, false, decodeBuffer)    
    end
end

function CrossPVPHandler:sendSendBulletScreenInfo(nId, szContent, nBsType, nBattlefield)
    local tMsg = {
        id = nId,
        content = szContent,
        bs_type = nBsType,
        sp1 = nBattlefield
    }
    local msgBuffer = protobuf.encode("cs.C2S_SendBulletScreenInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_SendBulletScreenInfo, msgBuffer)
end

function CrossPVPHandler:_recvSendBulletScreenInfo(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_SendBulletScreenInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return  
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then   
        G_Me.crossPVPData:setLastSendBSTime(decodeBuffer.last_send_time)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_SEND_BULLET_SCREEN_SUCC, nil, false, decodeBuffer)    
    end
end

function CrossPVPHandler:_recvFlushBulletScreen(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushBulletScreen", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BULLET_SCREEN_CONTENT_SUCC, nil, false, decodeBuffer)    
end


return CrossPVPHandler