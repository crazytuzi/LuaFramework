-- CrossWarHandler.lua
-- This class handles the message communicated between client and server, and dispatch events

local CrossWarHandler = class("CrossWarHandler", require("app.network.message.HandlerBase"))

local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

function CrossWarHandler:initHandler(...)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleTime, self._onGetBattleTime, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleInfo, self._onGetBattleInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SelectCrossBattleGroup, self._onSelectGroup, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_EnterScoreBattle, self._onEnterScoreBattle, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleEnemy, self._onGetEnemy, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChallengeCrossBattleEnemy, self._onChallengeScoreEnemy, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetWinsAwardInfo, self._onGetWinsAwardInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishWinsAward, self._onFinishWinsAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleRank, self._onGetBattleRank, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossCountReset, self._onCountReset, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCrossContestScore, self._onFlushScore, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCrossContestRank, self._onFlushScoreMatchRank, self)

	-- 争霸赛相关
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaInfo, self._onGetChampionshipInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaInvitation, self._onGetInvitation, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaBetsInfo, self._onGetBetInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaBetsList, self._onGetBetList, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossArenaPlayBets, self._onBetSomeone, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossArenaAddBets, self._onAddBets, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaRankTop, self._onGetTopRanks, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaRankUser, self._onGetCloseRanks, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossArenaRankChallenge, self._onChallengeChampion, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossArenaCountReset, self._onBuyChallenge, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossArenaServerAwardInfo, self._onGetServerAwardInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishCrossArenaServerAward, self._onFinishServerAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossArenaBetsAward, self._onGetBetAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FinishCrossArenaBetsAward, self._onFinishBetAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossUserDetail, self._onGetPlayerTeam, self)
end

-- 拉取跨服战各阶段的开始结束时间
function CrossWarHandler:sendGetBattleTime()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossBattleTime", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleTime, msgBuf)
end

function CrossWarHandler:_onGetBattleTime(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleTime", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateWarTimes(decodeBuffer.times)
		self:sendGetBattleInfo()
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_TIME, nil, false)
	end
end

-- 拉取当前跨服比赛的状态信息
function CrossWarHandler:sendGetBattleInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossBattleInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleInfo, msgBuf)
end

function CrossWarHandler:_onGetBattleInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateWarState(rawget(decodeBuffer, "state"), rawget(decodeBuffer, "group"), rawget(decodeBuffer, "has_arena"))
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_INFO, nil, false)
	end
end

-- 选择分组
function CrossWarHandler:sendSelectGroup(group_)
	local buffer = { group = group_ }
	local msgBuf = protobuf.encode("cs.C2S_SelectCrossBattleGroup", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_SelectCrossBattleGroup, msgBuf)
end

function CrossWarHandler:_onSelectGroup(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_SelectCrossBattleGroup", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:selectGroup(decodeBuffer.group)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_SELECT_GROUP, nil, false)
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_USER_CROSS_PK_STATE_ERROR then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_OPERATION_TOO_EARLY"))
	end
end

-- 进入积分赛界面
function CrossWarHandler:sendEnterScoreBattle()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_EnterScoreBattle", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_EnterScoreBattle, msgBuf)
end

function CrossWarHandler:_onEnterScoreBattle(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_EnterScoreBattle", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateScoreMatchInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_ENTER_SCORE_MATCH, nil, false)
	end
end

-- 拉取积分赛中3个对手的信息
function CrossWarHandler:sendGetEnemy(isRefresh_)
	local buffer = { is_refresh = isRefresh_ }
	local msgBuf = protobuf.encode("cs.C2S_GetCrossBattleEnemy", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleEnemy, msgBuf)
end

function CrossWarHandler:_onGetEnemy(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleEnemy", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateOpponents(decodeBuffer.refresh_count, decodeBuffer.users)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_ENEMY, nil, false)
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_USER_CROSS_PK_STATE_ERROR then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_SCORE_MATCH_IS_OVER"))
		self:sendGetBattleInfo()
	end
end

-- 积分赛:挑战对手
function CrossWarHandler:sendChallengeScoreEnemy(serverId, userId)
	local buffer = 
	{
		sid = serverId,
		user_id = userId
	}
	local msgBuf = protobuf.encode("cs.C2S_ChallengeCrossBattleEnemy", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_ChallengeCrossBattleEnemy, msgBuf)
end

function CrossWarHandler:_onChallengeScoreEnemy(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_ChallengeCrossBattleEnemy", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateChallengeResult(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_CHALLENGE_SCORE_ENEMY, nil, false, decodeBuffer.info)
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_USER_CROSS_PK_STATE_ERROR then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_SCORE_MATCH_IS_OVER"))
		self:sendGetBattleInfo()
	end
end

-- 拉取连胜奖励信息
function CrossWarHandler:sendGetWinsAwardInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetWinsAwardInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetWinsAwardInfo, msgBuf)
end

function CrossWarHandler:_onGetWinsAwardInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetWinsAwardInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateGotAwardIDs(decodeBuffer.ids)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_WINS_AWARD_INFO, nil, false, decodeBuffer.ids)
	end
end

-- 领取连胜奖励
function CrossWarHandler:sendFinishWinsAward(awardId)
	local buffer = { id = awardId }
	local msgBuf = protobuf.encode("cs.C2S_FinishWinsAward", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_FinishWinsAward, msgBuf)
end

function CrossWarHandler:_onFinishWinsAward(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_FinishWinsAward", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateFinishAward(decodeBuffer.id)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_WINS_AWARD, nil, false, decodeBuffer.id, decodeBuffer.awards)
	end
end

-- 拉取积分赛排行榜
function CrossWarHandler:sendGetBattleRank(group_)
	local buffer = { group = group_ }
	local msgBuf = protobuf.encode("cs.C2S_GetCrossBattleRank", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleRank, msgBuf)
end

function CrossWarHandler:_onGetBattleRank(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleRank", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateScoreRankList(decodeBuffer.group, decodeBuffer.ranks)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BATTLE_RANK, nil, false, decodeBuffer.group, decodeBuffer.ranks)
	end
end

-- 购买积分赛挑战次数或刷新次数
function CrossWarHandler:sendCountReset(type_, count_)
	local buffer = 
	{ 
		reset_type = type_,
		count = count_
	}
	local msgBuf = protobuf.encode("cs.C2S_CrossCountReset", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossCountReset, msgBuf)
end

function CrossWarHandler:_onCountReset(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossCountReset", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		if decodeBuffer.reset_type == 1 then
			G_Me.crossWarData:updateRefreshStatus(rawget(decodeBuffer, "refresh_count"),
												  rawget(decodeBuffer, "refresh_cost"))
		elseif decodeBuffer.reset_type == 2 then
			G_Me.crossWarData:updateChallengeStatus(rawget(decodeBuffer, "battle_count"),
													rawget(decodeBuffer, "battle_cost"),
													rawget(decodeBuffer, "buy_battle"))
		end

		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_COUNT_RESET, nil, false, decodeBuffer.reset_type)
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_USER_CROSS_PK_STATE_ERROR then
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_SCORE_MATCH_IS_OVER"))
		self:sendGetBattleInfo()
	end
end

-- 刷新积分赛积分
function CrossWarHandler:_onFlushScore(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCrossContestScore", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.user_id == G_Me.userData.id then
		G_Me.crossWarData:updateScore(decodeBuffer.score)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_FLUSH_SCORE, nil, false)
	end
end

-- 刷新积分赛（自己的）排名
function CrossWarHandler:_onFlushScoreMatchRank(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCrossContestRank", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.user_id == G_Me.userData.id then
		G_Me.crossWarData:updateScoreRank(decodeBuffer.rank)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_FLUSH_SCORE_MATCH_RANK, nil, false)
	end
end

-- 拉取争霸赛基本信息
function CrossWarHandler:sendGetChampionshipInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaInfo, msgBuf)
end

function CrossWarHandler:_onGetChampionshipInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateChampionshipInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO, nil, false, true)
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_USER_CROSS_PK_STATE_ERROR then
		-- 由于服务器状态切换比客户端慢，这里可能需要反复拉取多次(最后一个参数传回true表示失败)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_ARENA_INFO, nil, false, false)
	end
end

-- 拉取争霸赛邀请函
function CrossWarHandler:sendGetInvitation()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaInvitation", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaInvitation, msgBuf)
end

function CrossWarHandler:_onGetInvitation(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaInvitation", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateInvitation(rawget(decodeBuffer, "invite_type"), rawget(decodeBuffer, "rank"), rawget(decodeBuffer, "time"))
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_INVITATION, nil, false)
	end
end

-- 拉取押注信息
function CrossWarHandler:sendGetBetInfo()
	-- 如果已经拉到了最终的押注信息，直接派发事件
	if G_Me.crossWarData:hasFinalBetInfo() then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_INFO, nil, false)
	else
		local buffer = {}
		local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaBetsInfo", buffer)
		self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaBetsInfo, msgBuf)
	end
end

function CrossWarHandler:_onGetBetInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaBetsInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateBetInfo(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_INFO, nil, false)
	end
end

-- 拉取可押注列表
function CrossWarHandler:sendGetBetList()
	-- 如果已经拉到了最终的押注列表，直接派发事件
	if G_Me.crossWarData:hasFinalBetList() then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_LIST, nil, false)
	else
		local buffer = {}
		local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaBetsList", buffer)
		self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaBetsList, msgBuf)
	end
end

function CrossWarHandler:_onGetBetList(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaBetsList", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateBetList(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_LIST, nil, false)
	end
end

-- 选择某人为押注对象
function CrossWarHandler:sendBetSomeone(serverId, userId, betIndex)
	local buffer = 
	{
		sid = serverId,
		user_id = userId,
		bet_rank = betIndex,
	}
	local msgBuf = protobuf.encode("cs.C2S_CrossArenaPlayBets", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossArenaPlayBets, msgBuf)
end

function CrossWarHandler:_onBetSomeone(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossArenaPlayBets", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateBetSomeone(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_BET_SOMEONE, nil, false)
	end
end

-- 添加押注筹码
function CrossWarHandler:sendAddBets(num)
	local buffer = 
	{
		size = num,
	}

	local msgBuf = protobuf.encode("cs.C2S_CrossArenaAddBets", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossArenaAddBets, msgBuf)
end

function CrossWarHandler:_onAddBets(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossArenaAddBets", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateAddBets(decodeBuffer.size)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_ADD_BETS, nil, false, decodeBuffer.size)
	end
end

-- 拉取争霸赛排行
function CrossWarHandler:sendGetTopRanks()
	--__LogTag(TAG, "----拉取争霸赛排行")
	-- 如果已经拉到了最终排行，就直接派发事件，不要再拉
	if G_Me.crossWarData:hasFinalTopRanks() then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_TOP_RANKS, nil, false)
	else
		local buffer = {}
		local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaRankTop", buffer)
		self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaRankTop, msgBuf)
	end
end

function CrossWarHandler:_onGetTopRanks(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaRankTop", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----拉取争霸赛排行成功")
		G_Me.crossWarData:updateTopRanks(decodeBuffer.users)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_TOP_RANKS, nil, false)
	end
end

-- 拉取自己排名附近的玩家列表
function CrossWarHandler:sendGetCloseRanks()
	--__LogTag(TAG, "----拉取争霸赛自己附近的玩家")
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaRankUser", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaRankUser, msgBuf)
end

function CrossWarHandler:_onGetCloseRanks(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaRankUser", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----拉取争霸赛自己附近的玩家成功")
		G_Me.crossWarData:updateCloseRanks(decodeBuffer.rank, decodeBuffer.users)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_CLOSE_RANKS, nil, false)
	end
end

-- 挑战争霸赛对手
function CrossWarHandler:sendChallengeChampion(rank_)
	--__LogTag(TAG, "----挑战对手：" .. rank_)
	local buffer = { challenge_rank = rank_ }
	local msgBuf = protobuf.encode("cs.C2S_CrossArenaRankChallenge", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossArenaRankChallenge, msgBuf)
end

function CrossWarHandler:_onChallengeChampion(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossArenaRankChallenge", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		--__LogTag(TAG, "----挑战完毕")
		G_Me.crossWarData:updateChallengeChampion(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_CHALLENGE_CHAMPION, nil, false, decodeBuffer.battle_report, decodeBuffer.awards)
	end
end

-- 购买争霸赛挑战次数
function CrossWarHandler:sendBuyChallenge(count_)
	local buffer = { count = count_ }
	local msgBuf = protobuf.encode("cs.C2S_CrossArenaCountReset", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_CrossArenaCountReset, msgBuf)
end

function CrossWarHandler:_onBuyChallenge(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossArenaCountReset", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateChallengeStatus(rawget(decodeBuffer, "challenge_count"),
												rawget(decodeBuffer, "buy_cost"),
												rawget(decodeBuffer, "buy_count"))
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_BUY_CHALLENGE, nil, false)
	end
end

-- 拉取押注奖励信息
function CrossWarHandler:sendGetBetAward()
	-- 只有在争霸赛结束后才需要拉取此协议，并且只需拉一次
	if G_Me.crossWarData:isChampionshipEnd() and not G_Me.crossWarData:hasPulledBetAward() then
		local buffer = {}
		local msgBuf = protobuf.encode("cs.C2S_GetCrossArenaBetsAward", buffer)
		self:sendMsg(NetMsg_ID.ID_C2S_GetCrossArenaBetsAward, msgBuf)
	else
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, nil, false)
	end
end

function CrossWarHandler:_onGetBetAward(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossArenaBetsAward", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateBetAward(rawget(decodeBuffer, "award_id"),
										 rawget(decodeBuffer, "award_size"),
										 rawget(decodeBuffer, "award"),
										 rawget(decodeBuffer, "bet"))
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, nil, false, true)
	elseif decodeBuffer.ret == NetMsg_ERROR.RET_USER_CROSS_PK_STATE_ERROR then
		-- 由于服务器状态切换比客户端慢，这里可能需要反复拉取多次(最后一个参数传回true表示失败)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_BET_AWARD, nil, false, false)
	end
end

-- 领取押注奖励
function CrossWarHandler:sendFinishBetAward()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_FinishCrossArenaBetsAward",buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_FinishCrossArenaBetsAward, msgBuf)
end

function CrossWarHandler:_onFinishBetAward(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_FinishCrossArenaBetsAward", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateFinishBetAward(rawget(decodeBuffer, "award"))
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_BET_AWARD, nil, false, decodeBuffer.awards)
	end
end

-- 拉取已领取的全服奖励ID
function CrossWarHandler:sendGetServerAwardInfo()
	-- 只有在争霸赛结束后才需要拉取此协议，并且只需拉一次
	if G_Me.crossWarData:isChampionshipEnd() and not G_Me.crossWarData:hasPulledServerAward() then
		local buffer = {}
		local msgBuf = protobuf.encode("cs.C2S_CrossArenaServerAwardInfo", buffer)
		self:sendMsg(NetMsg_ID.ID_C2S_CrossArenaServerAwardInfo, msgBuf)
	else
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_SERVER_AWARD_INFO, nil, false)
	end
end

function CrossWarHandler:_onGetServerAwardInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_CrossArenaServerAwardInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateGotServerAwardIDs(decodeBuffer.ids)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_SERVER_AWARD_INFO, nil, false)
	end
end

-- 领取全服奖励
function CrossWarHandler:sendFinishServerAward(awardId)
	local buffer = { id = awardId }
	local msgBuf = protobuf.encode("cs.C2S_FinishCrossArenaServerAward", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_FinishCrossArenaServerAward, msgBuf)
end

function CrossWarHandler:_onFinishServerAward(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_FinishCrossArenaServerAward", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.crossWarData:updateFinishServerAward(decodeBuffer.id)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_SERVER_AWARD, nil, false, decodeBuffer.awards)
	end
end

-- 获取跨服战玩家阵容
function CrossWarHandler:sendGetPlayerTeam(serverId, userId)
	local buffer =
	{
		user_id = userId,
		sid     = serverId,
	}
	local msgBuf = protobuf.encode("cs.C2S_GetCrossUserDetail", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCrossUserDetail, msgBuf)
end

function CrossWarHandler:_onGetPlayerTeam(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossUserDetail", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, nil, false, decodeBuffer)
	end
end

return CrossWarHandler