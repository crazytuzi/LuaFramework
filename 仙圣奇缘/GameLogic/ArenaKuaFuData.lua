--------------------------------------------------------------------------------------
-- 文件名:	ArenaKuaFuData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用: 
---------------------------------------------------------------------------------------

ArenaKuaFuData = class("ArenaKuaFuData")
ArenaKuaFuData.__index = ArenaKuaFuData

local lastRank = 0

function ArenaKuaFuData:ctor()

	self.leavelTimes_ = 0; --竞技场剩余挑战次数
	self.rankList_ = {}; --被挑战者列表

	self.kuaFuCardBuZhen_ = {	
        zhen_fa_id = 1,		-- 阵型ID
	    card_list = {}      -- 上阵卡牌的格子信息，（ZhenXinInfo_Cell）
    }
	
	self.selfRank_ = 0 --个人名次, 值0==无排名，值1==第一名
	self.wins_ = 0--胜利次数
	self.loses_ = 0 --失败次数
	self.loseTime_ = 0 --上次失败的时间，用这个去算是否冷却，胜利，清空这个值
	self.winTimeToday_ = 0 --yymmdd(日期) xx(今天购买挑战次数) x (废弃)
	self.officialRank_ = 0--官阶
	self.challengeTimes_ = 0 --挑战次数
	self.hsRank_ = 0--历史最高排名 值0==无排名，值1==第一名
	self.challengeRankOld_ = false --true表示 challenge_rank 过期，需要刷新
	self.challengeRank_ = 0 --最近刷新的可挑战排名
	self.isTodayReward_ = false --true表示今天领过奖励, 新加，不做升级版本了。 缺省就是false
	self.arenaReport_ = {} --跨服战报
	self.playerList_ = {} --跨服排行榜
	self.rankTopFive_ = {} --保存最新的前5名玩家
		
	self.maxRankNum_ = 0	-- 竞技场排名信息最大数量
	
	self.recvStatus_ = false
	
	self.exitBattleFlag_ = false --在战斗中途退出标志
	self.viewPlayerKuaFuFalg_ = true --跨服查看排行玩家信息标识
	
	
	self.flagOpenTime_ = false
	
	
	--注册消息
	--客户端请求自己的跨服挑战信息返回
	local order = msgid_pb.MSGID_CROSS_SELF_RANK_INFO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.selfCrossRankResponse)) 	

	--请求跨服竞技场挑战返回
	local order = msgid_pb.MSGID_CROSS_CHALLEGE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.challegeResponse)) 
	
	--客户端跨服布阵结果响应
	local order = msgid_pb.MSGID_CROSS_BUZHEN_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.crossBuZhenResponse)) 	
	
	-- 请求领取跨服竞技场奖励
	local order = msgid_pb.MSGID_CROSS_RECV_REWARD_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.csCrossRecvRankRewardResponse)) 
	
	--请求跨服站排名列表返回
	local order = msgid_pb.MSGID_CROSS_RANK_LIST_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.CrossRankListResponse)) 
	
	--客户端请求刷出挑战返回
	local order = msgid_pb.MSGID_CROSS_REFRESH_CHALLEGE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.crossRefreshChallegeResponse)) 

	--客户端查看玩家详细信息响应
	local order = msgid_pb.MSGID_CROSS_VIEW_PLAYER_DETAIL_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.CrossViewPlayerDetailRespResponse)) 
	
	--客户端查看玩家简要信息响应
	local order = msgid_pb.MSGID_CROSS_VIEW_PLAYER_BRIEF_RSP
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.CrossViewPlayerBriefRspResponse)) 
	
end
	
--客户端请求自己的跨服挑战信息
function ArenaKuaFuData:requestSelfCrossRank()
	cclog("======requestSelfCrossRank========客户端请求自己的跨服挑战信息============")
	self.flagOpenTime_ = true
	
	if not next( g_ArenaKuaFuData:getRankTopFive() ) then
		g_ArenaKuaFuData:requestCrossRankList(1, 20)
	end
	
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_SELF_RANK_INFO_REQUEST)
end

-- 客户端请求自己的跨服挑战信息返回
function ArenaKuaFuData:selfCrossRankResponse(tbMsg)
	cclog("---selfCrossRankResponse------客户端请求自己的跨服挑战信息返回-----------")
	local msgDetail = zone_pb.CrossRankInfoNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog("跨服挑战信息"..tostring(msgDetail))
	local leavelTimes = msgDetail.leavel_times; --竞技场剩余挑战次数
	self:setLeavelTimes(leavelTimes)
	-- local updatePrestige = msgDetail.update_prestige; --更新威望 战斗胜利的时候有加威望
--	g_Hero:setPrestige(updatePrestige)
	
	local arenaInfo = msgDetail.arena_info --竞技场信息 RoleCrossArenaInfo
	
	
	lastRank = self:getSelfRank()
	
	local selfRank = arenaInfo.self_rank
	self:setSelfRank(selfRank)--个人名次, 值0==无排名，值1==第一名
	-- self:setWins(arenaInfo.wins)--胜利次数
	-- self:setLoses(arenaInfo.loses)--失败次数
	
	self:setLoseTime(arenaInfo.lose_time)--上次失败的时间，用这个去算是否冷却，胜利，清空这个值
	
	-- self:setWinTimeToday(arenaInfo.win_time_today)--yymmdd(日期) xx(今天购买挑战次数) x (废弃)
	-- self:setOfficialRank(arenaInfo.official_rank)--官阶
	
	self:setChallengeTimes(arenaInfo.challenge_times)--挑战次数
	self:setHsRank(arenaInfo.hs_rank)--历史最高排名 值0==无排名，值1==第一名
	self:setChallengeRankOld(arenaInfo.is_challenge_rank_old)--true表示 challenge_rank 过期，需要刷新
	self:setChallengeRank(arenaInfo.challenge_rank)--最近刷新的可挑战排名
	self:setIsTodayReward(arenaInfo.is_today_reward) --true表示今天领过奖励, 新加，不做升级版本了。 缺省就是false
	
	local arenaReports = arenaInfo.arena_reports --战斗记录列表
	self:setArenaReport(arenaReports)

	-- local arrayInfo = arenaInfo.arrayinfo--卡牌竞技场阵型 

	local buzhenInfo = arenaInfo.buzhen_info --竞技场阵型信息
	local zhenFaId = buzhenInfo.zhen_fa_id --阵型ID
	local cardList = buzhenInfo.card_list --卡牌ID, 格子顺序客户端订，服务器只做存储和发送
	self.kuaFuCardBuZhen_.zhen_fa_id = zhenFaId
	self.kuaFuCardBuZhen_.card_list = {}
	for i = 1, #cardList  do
		table.insert(self.kuaFuCardBuZhen_.card_list, 
		{Cell_index = cardList[i].zhenxin_id, 
		 Card_index = cardList[i].card_index+1})
	end
	-- msgDetail.max_rank_info --竞技场排名信息最大数量
	self:setMaxRankNum(msgDetail.max_rank_info)
	
	local rankList = msgDetail.rank_list	
	self:setRankList(rankList)
	local userCarData = g_Hero:getBattleCardByIndex(1)
	if selfRank <= 200 then 
		if next(self.playerList_) ~= nil and #self.playerList_ >= selfRank then 
			local t = {}
			t.star_level = userCarData:getStarLevel()
			t.branch_level = userCarData:getEvoluteLevel()
			t.vip_level = g_VIPBase:getCvsVipLevel() - 1
			t.fight_point = userCarData.fight_point
			t.rank = selfRank
			t.uin = g_MsgMgr:getUin()
			t.name = g_Hero:getMasterName()
			t.world_id = CCUserDefault:sharedUserDefault():getStringForKey("Serverid")
			t.card_id = userCarData:getCardCsvID()
			t.level = userCarData:getLevel()
			local selfPlayerRankInfo = self.playerList_[selfRank]
			self.playerList_[selfRank] = t
			self.playerList_[lastRank] = selfPlayerRankInfo
		end
	end
	
	if self.flagOpenTime_ then 
		g_WndMgr:openWnd("Game_ArenaKuaFu")
		self.flagOpenTime_ = false
	else
		g_FormMsgSystem:SendFormMsg(FormMsg_ArenaKuaFuaOpenWnd, nil)
	end
	
end

--客户端请求刷出挑战列表
function ArenaKuaFuData:requestRefreshChallege()
	cclog("=======requestRefreshChallege=======客户端请求刷出挑战列表=====返回 msgid==1095=======")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_REFRESH_CHALLEGE_REQUEST)
end

--客户端请求刷出挑战返回
function ArenaKuaFuData:crossRefreshChallegeResponse(tbMsg)
	cclog("=======crossRefreshChallegeResponse=======客户端请求刷出挑战返回============")
	local msgDetail = zone_pb.CrossRefreshChallegeResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local gold = msgDetail.gold --剩余的元宝数
	
	local yuanBao = g_Hero:getYuanBao() - gold
	if yuanBao > 0 then
		gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_KUA_FU_UPADTE_CHALLENGE, 1, yuanBao)
	end
	g_Hero:setYuanBao(gold)
end

--请求跨服竞技场挑战
function ArenaKuaFuData:requestChallege(challenRank)
	cclog("=======requestChallege=======请求跨服竞技场挑战============")
	local msg = zone_pb.CrossChallengeRequest()
	msg.challen_rank = challenRank --竞技场挑战的玩家名次. 1开始
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_CHALLEGE_REQUEST, msg)	
end

--请求跨服竞技场挑战返回
function ArenaKuaFuData:challegeResponse(tbMsg)
	cclog("=======challegeResponse=======请求跨服竞技场挑战返回============")
	local msgDetail = zone_pb.CrossChallengeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	-- local leftTimes = msgDetail.left_times --竞技场挑战剩余次数
	-- self:setLeavelTimes(leftTimes)
end

--客户端跨服布阵请求
function ArenaKuaFuData:requestCrossBuzhen(ZFInfo)
	cclog("=======requestCrossBuzhen=======客户端跨服布阵请求============")
	local msg = zone_pb.CrossBuZhenRequest()
	msg.buzhen_info.zhen_fa_id = ZFInfo.zhen_fa_id 
    for key, value in pairs(ZFInfo.card_list)  do
		local tmpInfo = common_pb.GeneralZhenXinInfo()
		tmpInfo.zhenxin_id = value.Cell_index
		tmpInfo.card_index = value.Card_index - 1
		table.insert(msg.buzhen_info.card_list, tmpInfo)
    end
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_BUZHEN_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText(true)
end

--客户端跨服布阵结果响应
function ArenaKuaFuData:crossBuZhenResponse(tbMsg)
	cclog("=======crossBuZhenResponse=======客户端跨服布阵结果响应============")
	local msgDetail = zone_pb.CrossBuZhenResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local buZhenInfo = msgDetail.buzhen_info --如果服务器校验客户端布阵信息异常，把服务器存的布阵信息同步给客户端
    self.kuaFuCardBuZhen_.zhen_fa_id = buZhenInfo.zhen_fa_id
    self.kuaFuCardBuZhen_.card_list = {}
    for i = 1, #msgDetail.buzhen_info.card_list  do
        table.insert(self.kuaFuCardBuZhen_.card_list, 
        {Cell_index = buZhenInfo.card_list[i].zhenxin_id, 
         Card_index = buZhenInfo.card_list[i].card_index+1})
    end
    g_WndMgr:closeWnd("Game_PublicBuZhen")
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

		
--请求领取跨服竞技场奖励
function ArenaKuaFuData:requestCrossRecvReward()
	cclog("=======requestCrossRecvReward=======请求领取跨服竞技场奖励============")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_RECV_REWARD_REQUEST)	
end

--请求领取跨服竞技场奖励
function ArenaKuaFuData:csCrossRecvRankRewardResponse(tbMsg)
	cclog("=======csCrossRecvRankRewardResponse=======请求领取跨服竞技场奖励返回============")
	local msgDetail = zone_pb.CsCrossRecvRankRewardRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	self:setIsTodayReward(msgDetail.recv_state)
	-- 2 表示已经领取
	self:setWorldRankRewardRecvStatus(2)
end	

--请求跨服站排名列表
function ArenaKuaFuData:requestCrossRankList(begRank, endRank)
	cclog("=======requestCrossRankList=======请求跨服站排名列表============")
	local msg = zone_pb.CrossRankListReq()
	msg.beg_rank = begRank;
	msg.end_rank = endRank;
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_RANK_LIST_REQUEST, msg)	
end

--请求跨服站排名列表返回
function ArenaKuaFuData:CrossRankListResponse(tbMsg)
	cclog("=======CrossRankListResponse=======请求跨服站排名列表返回============")
	local msgDetail = zone_pb.CrossRankListResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local begRank = msgDetail.beg_rank 
	local endRank = msgDetail.end_rank 
	local playerList = msgDetail.player_list --跨服玩家信息列表
	
	local function tableRankList(playerData)
		local t = {}
		t.star_level = playerData.star_level
		t.branch_level = playerData.branch_level
		t.vip_level = playerData.vip_level
		t.fight_point = playerData.fight_point
		t.rank = playerData.rank
		t.uin = playerData.uin
		t.name = playerData.name
		t.world_id = playerData.world_id
		t.card_id = playerData.card_id
		t.level = playerData.level
		return t
	end
	
	if endRank == 20 and next(self.playerList_) ~= nil then 
		for key, value in ipairs(playerList) do 
			self.playerList_[key] = tableRankList(value)
		end
	else	
		for key, value in ipairs(playerList) do 
			table.insert(self.playerList_, tableRankList(value))
		end
	end

	 self:setRankTopFive(self.playerList_)
	
	g_FormMsgSystem:SendFormMsg(FormMsg_ArenaKuaFuaRankListUpdate, nil)
end	
 
 --客户端查看玩家简要信息请求 跨服
function ArenaKuaFuData:requestCrossViewPlayerBriefReq(targetUin)
	cclog("=======requestCrossViewPlayerBriefReq=======客户端查看玩家简要信息请求============")
	local msg = zone_pb.CrossViewPlayerBriefReq()
	msg.target_uin = targetUin;
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_VIEW_PLAYER_BRIEF_REQ, msg)	
end
-- 客户端查看玩家简要信息响应  跨服
function ArenaKuaFuData:CrossViewPlayerBriefRspResponse(tbMsg)
	cclog("=======CrossViewPlayerBriefRspResponse=======客户端查看玩家简要信息响应============")
	local msgDetail = zone_pb.CrossViewPlayerBriefRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	onKuaFuViewPlayer(msgDetail)

end	

--客户端查看玩家详细信息请求
function ArenaKuaFuData:requestCrossViewPlayerDetail(destUin)
	cclog("=======requestCrossViewPlayerDetail=======客户端查看玩家详细信息请求============")
	local msg = zone_pb.CrossViewPlayerDetailReq()
	msg.dest_uin = destUin;
	g_MsgMgr:sendMsg(msgid_pb.MSGID_CROSS_VIEW_PLAYER_DETAIL_REQUEST, msg)	
end
-- 客户端查看玩家详细信息响应  
function ArenaKuaFuData:CrossViewPlayerDetailRespResponse(tbMsg)
	cclog("=======CrossViewPlayerDetailRespResponse=======客户端查看玩家详细信息响应============")
	local msgDetail = zone_pb.CrossViewPlayerDetailResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	g_WndMgr:openWnd("Game_ViewPlayer", {msgDetail, true})
end	

 
 
--跨服挑战剩余次数
function ArenaKuaFuData:setLeavelTimes(leavelNum)
	self.leavelTimes_ = leavelNum
end

function ArenaKuaFuData:getLeavelTimes()
	return self.leavelTimes_
end

--被挑战者列表
function ArenaKuaFuData:setRankList(rankListData)
	local flagRank = 6
	self.rankList_ = {}
	local t = {}
	for key = 1, #rankListData do 
		t = {}
		t.vip_lev = rankListData[key].vip_lev					--vip等级
		t.rank = rankListData[key].rank							--名次
		flagRank = rankListData[key].rank	
		t.role_lv = rankListData[key].role_lv					--人物等级
		t.breach_lv = rankListData[key].breach_lv				--突破等级
		t.world_id = rankListData[key].world_id					--服务器区ID
		t.role_uin = rankListData[key].role_uin					--玩家id
		t.role_name = rankListData[key].role_name				--名字
		t.fighting_point = rankListData[key].fighting_point		--战斗力
		t.main_card_cfg_id = rankListData[key].main_card_cfg_id	--主卡牌的配置id
		t.main_card_star = rankListData[key].main_card_star		--主卡牌的星级
		table.insert(self.rankList_, t)
	end	
	--再战斗结束后名次刷新 就保存前5名
	if flagRank <= 5 then --前五名玩家
		local top5Table = {}
		local t = {}
		for index = 1, 5 do 
			local top5Info = self.rankList_[index]
			t = {}
			t.star_level = top5Info.main_card_star
			t.branch_level = top5Info.breach_lv
			t.vip_level = top5Info.vip_lev
			t.fight_point = top5Info.fighting_point
			t.rank = top5Info.rank
			t.uin = top5Info.role_uin
			t.name = top5Info.role_name
			t.world_id = top5Info.world_id
			t.card_id = top5Info.main_card_cfg_id
			t.level = top5Info.role_lv
			table.insert(top5Table, t)
		end
		self:setRankTopFive(top5Table)
	end
end

function ArenaKuaFuData:getRankList()
	return self.rankList_
end

--拼接星级
function ArenaKuaFuData:getStarAtlasLable(star)
	return string.rep("1", star)
end

--个人名次, 值0==无排名，值1==第一名
function ArenaKuaFuData:setSelfRank(selfRank)
	self.selfRank_ = selfRank
end
function ArenaKuaFuData:getSelfRank()
	return self.selfRank_
end

--胜利次数
function ArenaKuaFuData:setWins(wins)
	self.wins_ = wins
end
function ArenaKuaFuData:getWins()
	return self.wins_
end

--失败次数
function ArenaKuaFuData:setLoses(loses)
	self.loses_ = loses
end
function ArenaKuaFuData:getLoses()
	return self.loses_
end
	
---上次失败的时间，用这个去算是否冷却，胜利，清空这个值
function ArenaKuaFuData:setLoseTime(loseTime)
	self.loseTime_ = loseTime
end
function ArenaKuaFuData:getLoseTime()
	return self.loseTime_
end	

---yymmdd(日期) xx(今天购买挑战次数) x (废弃)
-- function ArenaKuaFuData:setWinTimeToday(winTimeToday)
	-- self.winTimeToday_ = winTimeToday
-- end
-- function ArenaKuaFuData:getWinTimeToday()
	-- return self.winTimeToday_
-- end

-----官阶
-- function ArenaKuaFuData:setOfficialRank(officialRank)
	-- self.officialRank_ = officialRank
-- end
-- function ArenaKuaFuData:getOfficialRank()
	-- return self.officialRank_
-- end
	
--挑战次数
function ArenaKuaFuData:setChallengeTimes(challengeTimes)
	self.challengeTimes_ = challengeTimes
end
function ArenaKuaFuData:getChallengeTimes()
	return self.challengeTimes_
end
		
--历史最高排名 值0==无排名，值1==第一名
function ArenaKuaFuData:setHsRank(hsRank)
	self.hsRank_ = hsRank
end
function ArenaKuaFuData:getHsRank()
	return self.hsRank_
end
	
--true表示 challenge_rank 过期，需要刷新
function ArenaKuaFuData:setChallengeRankOld(challengeRankOld)
	self.challengeRankOld_ = challengeRankOld
end
function ArenaKuaFuData:getChallengeRankOld()
	return self.challengeRankOld_
end
	
--最近刷新的可挑战排名
function ArenaKuaFuData:setChallengeRank(challengeRank)
	self.challengeRank_ = challengeRank
end
function ArenaKuaFuData:getChallengeRank()
	return self.challengeRank_
end
	
--true表示今天领过奖励, 新加，不做升级版本了。 缺省就是false
function ArenaKuaFuData:setIsTodayReward(isTodayReward)
	self.isTodayReward_ = isTodayReward
end
function ArenaKuaFuData:getIsTodayReward()
	return self.isTodayReward_
end

--跨服战报
function ArenaKuaFuData:setArenaReport(arenaReports)
	self.arenaReport_ = {}
	if not arenaReports then return end 
	for key ,value in ipairs(arenaReports) do
		local result = value.result	-- 结果，胜利或者失败
		local arenaReport1 = value.arena_report1
		local arenaReport2 = value.arena_report2
		
		local tb_ArenaReport1 = {}
		tb_ArenaReport1.role_name = arenaReport1.role_name --玩家名称
		tb_ArenaReport1.fightpoint =  arenaReport1.fightpoint --战斗力
		tb_ArenaReport1.rank_old = arenaReport1.rank_old --战斗前排名
		tb_ArenaReport1.rank_new = arenaReport1.rank_new --战斗后排名
		
		local tb_ArenaReport2 = {}
		tb_ArenaReport2.role_name = arenaReport2.role_name --玩家名称
		tb_ArenaReport2.fightpoint = arenaReport2.fightpoint --战斗力
		tb_ArenaReport2.rank_old = arenaReport2.rank_old --战斗前排名
		tb_ArenaReport2.rank_new = arenaReport2.rank_new --战斗后排名
		
		local tb_ArenaReport = {} 
		tb_ArenaReport.tb_ArenaReport1 = tb_ArenaReport1
		tb_ArenaReport.tb_ArenaReport2 = tb_ArenaReport2
		tb_ArenaReport.result = result
		
		table.insert(self.arenaReport_, tb_ArenaReport)
	end
end

function ArenaKuaFuData:getArenaReport()
	return self.arenaReport_
end

--跨服排名信息
function ArenaKuaFuData:setPlayerList(data)
	self.playerList_ = data
end

function ArenaKuaFuData:getPlayerList()
	return self.playerList_
end

--排名区间 用于获取排名标识图案
local rankArea = {1,2,3,10,50,100,200,500,1000,2000,3000,1000000}
function ArenaKuaFuData:returnRankArea(rank)
	for i = 1, #rankArea do
		if rankArea[i] >= rank then 
			return rankArea[i]
		end
	end
end

--排名前五的玩家
function ArenaKuaFuData:setRankTopFive(rankInfo)
	self.rankTopFive_ = {}
	for i = 1, 5 do 
		table.insert(self.rankTopFive_, rankInfo[i])
	end
end
function ArenaKuaFuData:getRankTopFive(key)
	if not key then 
		return self.rankTopFive_
	end
	return self.rankTopFive_[key]
end

-- 竞技场排名信息最大数量
function ArenaKuaFuData:setMaxRankNum(num)
	self.maxRankNum_ = num
end
function ArenaKuaFuData:getMaxRankNum()
	return self.maxRankNum_ 
end

--(0:无奖励 1:有奖励但未领取 2:已领取)
function ArenaKuaFuData:setWorldRankRewardRecvStatus(status)
	local flag = true
	if status <= 1 then flag = false end
	self.recvStatus_ = flag
end
function ArenaKuaFuData:getWorldRankRewardRecvStatus()
	return self.recvStatus_
end

function ArenaKuaFuData:getExitBalttleFlag()
	return self.exitBattleFlag_
end

function ArenaKuaFuData:setExitBalttleFlag(flag)
	self.exitBattleFlag_ = flag
end



function ArenaKuaFuData:getViewPlayerKuaFuFlag()
	return self.viewPlayerKuaFuFalg_
end

function ArenaKuaFuData:setViewPlayerKuaFuFlag(flag)
	self.viewPlayerKuaFuFalg_ = flag
end

---------------------------------------------------
g_ArenaKuaFuData = ArenaKuaFuData.new()
	