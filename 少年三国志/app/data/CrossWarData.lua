local CrossWarData = class("CrossWarData")

require("app.cfg.contest_points_winning_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

function CrossWarData:ctor()
	self._stageTimes		= nil	-- 跨服战各阶段的开始结束时间
	self._warState 			= 0		-- 当前跨服战的状态(阶段)
	self._medal				= 0		-- 玩家的勋章数
	self._challengeCount 	= 0 	-- 剩余免费的挑战次数
	self._buyChallengeCount	= 0		-- 可以购买的挑战次数
	self._challengeCost		= 0		-- 下次购买一次挑战的元宝花费

-- ### 积分赛相关 ###
	self._group				= 0		-- 玩家选择的分组
	self._score				= 0		-- 玩家的当前积分
	self._rankInScore		= 0		-- 玩家的积分赛排名
	self._curWinStreak		= 0		-- 玩家当前最大连胜
	self._maxWinStreak		= 0		-- 玩家今日最大连胜
	self._refreshCount		= 0		-- 剩余免费刷新次数
	self._refreshCost		= 0		-- 下次购买一次刷新的元宝花费
	self._opponents			= nil	-- 积分赛对手信息数组
	self._gotAwardIDs		= nil	-- 已经领取的连胜奖励的ID列表

	self._scoreRankList		= {nil, nil, nil, nil}			-- 积分赛四个分组的排名列表
	self._hasFinalScoreRank	= {false, false, false, false}	-- 积分赛四个分组的最终排行（比赛结束后的排行）是否已经拉到

-- ### 争霸赛相关 ###
	self._isChampionshipEnabled	= false 	-- 本轮比赛，争霸赛是否开启
	self._hasLastChampionship	= false 	-- 上一轮比赛，争霸赛是否进行过
	self._isQualify				= false 	-- 是否有资格进入争霸赛
	self._qualifyType			= 0			-- 进入争霸赛的方式（1.积分赛前25， 2.竞技场前50）
	self._qualifyRank			= 0			-- 进入争霸赛时的资格排名
	self._qualifyTime			= 0			-- 争霸赛参赛者的结算时间
	self._rankInChampionship	= 0			-- 玩家的争霸赛排名
	self._bonusPool				= 0			-- 争霸赛总奖池
	self._betNum				= 0			-- 玩家押注数量
	self._betUsers				= nil		-- 押注的玩家列表
	self._betList				= nil		-- 可押注的玩家列表
	self._topRanks				= nil		-- 争霸赛前N名（目前 N = 20）
	self._closeRanks			= nil		-- 自己排名附近的玩家
	self._betAwardID			= 0			-- 所获得的押注奖励ID
	self._betAwardNum			= 0			-- 所获得的押注奖励数量
	self._gotServerAwardIDs		= {}		-- 已经领取过的全服奖励的ID列表

	self._hasGetBetAward		= false		-- 是否已领取过押注奖励
	self._hasPulledBetAward		= false 	-- 是否已拉取了押注奖励信息
	self._hasPulledServerAward	= false 	-- 是否已拉取了全服奖励信息
	self._hasFinalTopRanks		= false 	-- 是否已拉取到最终的前N名
	self._hasFinalBetInfo		= false 	-- 是否已拉取到最终的押注信息（争霸赛开始后停止押注，所以之后不必每次拉）
	self._hasFinalBetList		= false 	-- 是否已拉取到最终的押注列表（争霸赛开始后停止押注，所以之后不必每次拉）

	self._hasClickedInvite		= false 	-- 这个变量用于标记，mainscene里的邀请函是否被打开过
end

function CrossWarData:updateWarTimes(times)
	self._stageTimes = {}
	for i = 1, #times do
		local stage = times[i]
		self._stageTimes[stage.state] = { start = stage.start, close = stage.close}
	end

	-- TEMP
	--[[local t = G_ServerTime:getTime()
	self._stageTimes[1] = { start = t, close = t + 20}
	self._stageTimes[2] = { start = t + 20, close = t + 40}
	self._stageTimes[3] = { start = t + 40, close = t + 60}
	self._stageTimes[4] = { start = t + 60, close = t + 6000}
	self._stageTimes[5] = { start = t + 6000, close = t + 6040}]]
end

function CrossWarData:updateWarState(state, group, isChampionshipEnabled)
	self._warState				= state or CrossWarCommon.STATE_UNOPEN
	self._group					= group or 0
	self._isChampionshipEnabled	= isChampionshipEnabled or false

	-- 比赛状态是0表示一轮比赛已经结束，清空一些数据
	if self._warState == CrossWarCommon.STATE_UNOPEN or
	   self._warState == CrossWarCommon.STATE_BEFORE_SCORE_MATCH then
		for i = 1, #self._hasFinalScoreRank do
			self._hasFinalScoreRank[i] = false
		end

		self._isChampionshipEnabled	= false
		self._isQualify				= false
		self._qualifyType			= 0
		self._hasFinalTopRanks		= false
		self._hasFinalBetInfo 		= false
		self._hasFinalBetList		= false
		self._hasPulledBetAward		= false
		self._hasPulledServerAward	= false
	end

	__LogTag(TAG, "----拉取到的当前阶段:".. self._warState)
	-- TEMP
	--self._warState = 4
	--self._isChampionshipEnabled = true
end

function CrossWarData:selectGroup(group)
	self._group = group or 0
end

function CrossWarData:updateScoreMatchInfo(info)
	self._score 			= info.score or 0
	self._rankInScore		= info.rank or 0
	self._refreshCost		= info.refresh_cost or 0
	self._challengeCost		= info.battle_cost or 0
	self._curWinStreak		= info.wins or 0
	self._maxWinStreak		= info.max_wins or 0
	self._refreshCount		= info.refresh_count or 0
	self._challengeCount 	= info.battle_count or 0
	self._buyChallengeCount	= info.buy_battle or 0
end

function CrossWarData:updateOpponents(refreshCount, opponents)
	self._refreshCount = refreshCount
	self._opponents = {}
	for i = 1, #opponents do
		local inData = opponents[i]

		self._opponents[i] = 
		{
			id 			= inData.id,
			name 		= inData.name,
			main_role 	= inData.main_role,
			dress_id 	= inData.dress_id,
			fight_value	= inData.fight_value,
			sid 		= inData.sid,
			sname 		= inData.sname,
			group 		= inData.group,
			medalNum	= inData.c_type,
			isBeaten 	= inData.has_fight,
			clid		= inData.clid,
			cltm		= inData.cltm,
			clop		= inData.clop,
		}
	end

	-- sort by medal num
	local sortFunc = function(a, b)
		if a.medalNum == b.medalNum then
			return a.fight_value > b.fight_value
		end
		return a.medalNum > b.medalNum
	end

	table.sort(self._opponents, sortFunc)
end

function CrossWarData:updateRefreshStatus(refreshNum, refreshCost)
	self._refreshCount = refreshNum or self._refreshCount
	self._refreshCost = refreshCost or self._refreshCost
end

function CrossWarData:updateChallengeStatus(challengeNum, challengeCost, buyChallengeNum)
	self._challengeCount = challengeNum or self._challengeCount
	self._challengeCost = challengeCost or self._challengeCost
	self._buyChallengeCount = buyChallengeNum or self._buyChallengeCount
end

function CrossWarData:updateChallengeResult(result)
	-- update some numbers
	self._challengeCount = rawget(result, "battle_count") or self._challengeCount
	self._curWinStreak = rawget(result, "wins") or self._curWinStreak
	self._maxWinStreak = rawget(result, "max_wins") or self._maxWinStreak
	self._score = rawget(result, "score") or self._score
	self._rankInScore = rawget(result, "rank") or self._rankInScore

	-- set the opponent's "beaten" flag if win
	if result.info.is_win == true then
		for _, v in ipairs(self._opponents) do
			if v.id == result.user_id and v.sid == result.sid then
				v.isBeaten = true
				break
			end
		end
	end
end

function CrossWarData:updateGotAwardIDs(ids)
	self._gotAwardIDs = {}
	for _, v in ipairs(ids) do
		self._gotAwardIDs[v] = true
	end
end

-- 领取连胜奖励的回包
function CrossWarData:updateFinishAward(id)
	self._gotAwardIDs[id] = true
end

function CrossWarData:updateScore(score)
	self._score = score or self._score
end

-- 我自己的积分赛排名
function CrossWarData:updateScoreRank(rank)
	self._rankInScore = rank or self._rankInScore
end

-- 积分赛排行榜
function CrossWarData:updateScoreRankList(group, ranks)
	self._scoreRankList[group] = {}
	for i,v in ipairs(ranks) do
		self._scoreRankList[group][i] = {}
		local data = self._scoreRankList[group][i]
		data.user_id 	= v.user_id
		data.sid		= v.sid
		data.name 		= v.name
		data.sname		= v.sname
		data.main_role	= v.main_role
		data.dress_id	= v.dress_id
		data.score 		= v.score
		data.rank 		= v.rank
		data.fight_value= v.fight_value
		data.max_wins	= v.max_wins
		data.clid		= v.clid
		data.cltm		= v.cltm
		data.clop		= v.clop

		-- 如果排行榜里有我，并且与当前排名不一致，则同步一下
		if v.sid == G_PlatformProxy:getLoginServer().id then
			if v.user_id == G_Me.userData.id and v.rank ~= self._rankInScore then
				self._rankInScore = v.rank
				uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_WAR_FLUSH_SCORE_MATCH_RANK, nil, false)
			end
		end
	end

	self._hasFinalScoreRank[group] = self:isScoreMatchEnd()
end

-- 争霸赛基本信息
function CrossWarData:updateChampionshipInfo(info)
	self._isQualify 			= info.invited or false
	self._challengeCount 		= info.challenge_count or 0
	self._buyChallengeCount		= info.buy_count or 0
	self._challengeCost			= info.buy_cost or 0

	
	--__LogTag(TAG, "----争霸赛是否有资格：" .. tostring(self._isQualify) .. " 免费挑战次数：" .. self._challengeCount)
	--__LogTag(TAG, "----剩余购买挑战次数：" .. tostring(self._buyChallengeCount) .. " 下次购买花费：" .. self._challengeCost)
end

-- 邀请函信息
function CrossWarData:updateInvitation(qualifyType, qualifyRank, qualifyTime)
	self._qualifyType = qualifyType or 0
	self._qualifyRank = qualifyRank or 0
	self._qualifyTime = qualifyTime or 0
end

-- 押注信息
function CrossWarData:updateBetInfo(info)
	self._bonusPool		= info.total_bet or 0
	self._betNum		= info.bet or 0
	self._betUsers 		= {}

	for i, v in ipairs(info.bet_users) do
		self._betUsers[v.sp1] = { user_id	= v.id,
							  	  sid 		= v.sid,
							  	  name 		= v.name,
							  	  sname 	= v.sname,
							  	  dress_id 	= v.dress_id,
							  	  main_role = v.main_role,
							  	  clid		= v.clid,
								  cltm		= v.cltm,
								  clop		= v.clop,
							  	   }
	end

	self:syncBetUsers()

	self._hasFinalBetInfo = self._warState >= CrossWarCommon.STATE_IN_CHAMPIONSHIP
end

-- 押注列表
function CrossWarData:updateBetList(list)
	self._betList = {}
	for i, v in ipairs(list.users) do
		self._betList[i] = { user_id	= v.id,
							 sid		= v.sid,
							 name		= v.name,
							 sname		= v.sname,
							 dress_id 	= v.dress_id,
							 main_role	= v.main_role,
							 fight_value= v.fight_value,
							 follow		= v.sp1, 
							 betIndex	= 0, 
							 clid		= v.clid,
							 cltm		= v.cltm,
							 clop		= v.clop,
								}
	end

	self:syncBetUsers()

	self._hasFinalBetList = self._warState >= CrossWarCommon.STATE_IN_CHAMPIONSHIP
end

-- 同步一下已押注的玩家
function CrossWarData:syncBetUsers()
	if self._betUsers and self._betList then
	for i1, v1 in ipairs(self._betList) do
		for k, v2 in pairs(self._betUsers) do
				if v1.user_id == v2.user_id and v1.sid == v2.sid then
					v1.betIndex = k
					break
				end
				v1.betIndex = 0
			end
		end
	end
end

-- 押了某个玩家
function CrossWarData:updateBetSomeone(result)
	-- 减少之前被押的玩家的关注度
	local prevBet = self._betUsers[result.bet_rank]
	if prevBet then
		prevUser = self:getBetUserByID(prevBet.sid, prevBet.user_id)
		if prevUser then
			prevUser.follow = prevUser.follow - (11 - result.bet_rank)
		end
	end

	-- 设置新押注的人
	local user = self:getBetUserByID(result.sid, result.user_id)
	self._betUsers[result.bet_rank] = { user_id = user.user_id, sid = user.sid,
										name = user.name, sname = user.sname,
										dress_id = user.dress_id, main_role = user.main_role,
										clid		= user.clid,
								  		cltm		= user.cltm,
								  		clop		= user.clop,
									  }
	user.follow = user.follow + (11 - result.bet_rank)

	-- 如果此人之前被押为别的名次，删之
	for k, v in pairs(self._betUsers) do
		if k ~= result.bet_rank and v.user_id == result.user_id and v.sid == result.sid then
			self._betUsers[k] = nil
			user.follow = user.follow - (11 - k)
		end
	end

	-- 将押注信息同步到betlist
	self:syncBetUsers()
end

-- 添加押注筹码
function CrossWarData:updateAddBets(addNum)
	self._betNum = self._betNum + addNum
	__LogTag(TAG, "----总押注数：" .. self._betNum)
end

-- 拉取争霸赛前N名
function CrossWarData:updateTopRanks(list)
	self._topRanks = {}
	for i, v in ipairs(list) do
		self._topRanks[i] = { user_id		= v.id,
							  sid 			= v.sid,
							  name 			= v.name,
							  sname 		= v.sname,
							  dress_id 		= v.dress_id,
							  main_role 	= v.main_role,
							  fight_value 	= v.fight_value,
							  follow 		= v.sp1,
							  rank 			= v.sp2,
							  clid			= v.clid,
							  cltm			= v.cltm,
							  clop			= v.clop,
						 	}
	end

	-- 如果比赛已经结束，那么标记已拉到最终的前十
	self._hasFinalTopRanks = (self._warState == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP)
end

-- 拉取自己排名附近的玩家
function CrossWarData:updateCloseRanks(myRank, list)
	self._rankInChampionship = myRank
	self._closeRanks = {}

	-- 如果列表是空的，或者比赛已结束，取完排名就返回
	if not list or self:isChampionshipEnd() then
		return
	end

	-- 这里剔除前10名的人，前10名的从排行榜topRanks中取
	for i, v in ipairs(list) do
		if v.sp1 > CrossWarCommon.CHAMPIONSHIP_TOP_RANKS then
			self._closeRanks[i] = { user_id		= v.id,
							  		sid 		= v.sid,
							  		name 		= v.name,
							  		sname 		= v.sname,
							  		dress_id 	= v.dress_id,
							  		main_role 	= v.main_role,
							  		fight_value = v.fight_value,
							  		rank 		= v.sp1,							  
							  		clid		= v.clid,
							  		cltm		= v.cltm,
							  		clop		= v.clop,

						 		}
		end
	end

	-- 把自己放进列表
	if myRank > CrossWarCommon.CHAMPIONSHIP_TOP_RANKS then
		local dress = G_Me.dressData:getDressed()
		self._closeRanks[#self._closeRanks + 1] = { user_id 	= G_Me.userData.id,
													sid 		= G_PlatformProxy:getLoginServer().id,
													name		= G_Me.userData.name,
													sname		= G_PlatformProxy:getLoginServer().name,
													dress_id	= dress and dress.base_id or 0,
													main_role	= select(2, G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)),
													fight_value	= G_Me.userData.fight_value,
													rank 		= myRank,
													clid		= G_Me.userData.cloth_id,
							  						cltm		= G_Me.userData.cloth_time,
							  						clop		= G_Me.userData.cloth_open,
												  }
	end

	-- 按排名排序
	if #self._closeRanks > 0 then
		table.sort(self._closeRanks, function(a, b) return a.rank < b.rank end)
	end
end

-- 挑战争霸赛对手
function CrossWarData:updateChallengeChampion(result)
	self._challengeCount = rawget(result, "challenge_count") or self._challengeCount
end

-- 拉取押注奖励信息
function CrossWarData:updateBetAward(id, num, hasGet, betNum)
	self._betAwardID = id or 0
	self._betAwardNum = num or 0
	self._hasGetBetAward = hasGet
	self._betNum = betNum or self._betNum

	self._hasPulledBetAward = self:isChampionshipEnd()
end

-- 领取押注奖励
function CrossWarData:updateFinishBetAward(hasGet)
	self._hasGetBetAward = hasGet
end

-- 拉取已领取过的全服奖励ID
function CrossWarData:updateGotServerAwardIDs(ids)
	self._gotServerAwardIDs = {}
	for _, v in ipairs(ids) do
		self._gotServerAwardIDs[v] = true
	end

	self._hasPulledServerAward = self:isChampionshipEnd()
end

-- 领取了全服奖励
function CrossWarData:updateFinishServerAward(id)
	self._gotServerAwardIDs[id] = true
end

function CrossWarData:isBattleTimePulled()
	return self._stageTimes and #self._stageTimes > 0
end

function CrossWarData:getCurState()
	return self._warState
end

function CrossWarData:stepToNextState()
	self._warState = self._warState + 1
end

function CrossWarData:getTime(state)
	return self._stageTimes[state]
end

function CrossWarData:isGroupChoosed()
	return self._group > 0 and self._group <= 4
end

function CrossWarData:isChampionshipEnabled()
	return self._isChampionshipEnabled
end

function CrossWarData:hasLastChampionship()
	return self._hasLastChampionship
end

function CrossWarData:isQualify()
	return self._isQualify
end

function CrossWarData:isInScoreMatch()
	return self._warState == CrossWarCommon.STATE_IN_SCORE_MATCH
end

function CrossWarData:isScoreMatchEnd()
	return self._warState >= CrossWarCommon.STATE_AFTER_SCORE_MATCH
end

function CrossWarData:isInChampionship()
	return self._warState == CrossWarCommon.STATE_IN_CHAMPIONSHIP
end

function CrossWarData:isChampionshipEnd()
	return self._warState == CrossWarCommon.STATE_AFTER_CHAMPIONSHIP
end

function CrossWarData:getGroup()
	return self._group
end

function CrossWarData:getScore()
	return self._score
end

function CrossWarData:getRank()
	return self._rankInScore
end

function CrossWarData:getRankInChampionship()
	return self._rankInChampionship
end

function CrossWarData:getChallengeCount()
	return self._challengeCount
end

function CrossWarData:getRefreshCount()
	return self._refreshCount
end

function CrossWarData:getChallengeCost()
	return self._challengeCost
end

function CrossWarData:getRefreshCost()
	return self._refreshCost
end

function CrossWarData:getRemainBuyChallengeCount()
	return self._buyChallengeCount
end

function CrossWarData:getCurWinStreak()
	return self._curWinStreak
end

function CrossWarData:getMaxWinStreak()
	return self._maxWinStreak
end

function CrossWarData:gotAwardIDs()
	return self._gotAwardIDs
end

function CrossWarData:getScoreRankItem(group, rank)
	if not self._scoreRankList[group] or not self._scoreRankList[group][rank] then
		return nil
	end

	return self._scoreRankList[group][rank]
end

function CrossWarData:getScoreRankNum(group)
	if not self._scoreRankList[group] then
		return 0
	end

	return #self._scoreRankList[group]
end

function CrossWarData:getQualifyType()
	return self._qualifyType
end

function CrossWarData:getQualifyRank()
	return self._qualifyRank
end

function CrossWarData:getQualifyTime()
	return self._qualifyTime
end

function CrossWarData:setClickedInvite(clicked)
	self._hasClickedInvite = clicked
end

function CrossWarData:hasClickedInvite()
	return self._hasClickedInvite
end

function CrossWarData:getBonusPool()
	return self._bonusPool
end

function CrossWarData:addBonusPool(addNum)
	self._bonusPool = self._bonusPool + addNum
	return self._bonusPool
end

function CrossWarData:getBetNum()
	return self._betNum
end

function CrossWarData:getBetUserNum()
	local n = 0
	if self._betUsers then
		for _, _ in pairs(self._betUsers) do
			n = n + 1
		end
	end
	return n
end

function CrossWarData:getBetUser(index)
	return self._betUsers and self._betUsers[index]
end

function CrossWarData:getBetListNum()
	return self._betList and #self._betList or 0
end

function CrossWarData:getBetUserInList(index)
	return self._betList and self._betList[index]
end

function CrossWarData:getBetUserByID(serverId, userId)
	if self._betList and #self._betList > 0 then
		for i, v in ipairs(self._betList) do
			if v.sid == serverId and v.user_id == userId then
				return v
			end
		end
	end

	return nil
end

function CrossWarData:sortBetListByFollow()
	local sortFunc = function(a, b)
		return a.follow > b.follow
	end
	table.sort(self._betList, sortFunc)
end

function CrossWarData:sortBetListByFight()
	local sortFunc = function(a, b)
		return a.fight_value > b.fight_value
	end
	table.sort(self._betList, sortFunc)
end

function CrossWarData:hasFinalBetInfo()
	return self._hasFinalBetInfo
end

function CrossWarData:hasFinalBetList()
	return self._hasFinalBetList
end

function CrossWarData:getTopRankNum()
	return self._topRanks and #self._topRanks or 0
end

function CrossWarData:getTopRankUser(rank)
	return self._topRanks and self._topRanks[rank]
end

function CrossWarData:getCloseRankNum()
	return self._closeRanks and #self._closeRanks or 0
end

-- 我在争霸赛战斗列表中的位置
function CrossWarData:getMyPosInRanks()
	if self._rankInChampionship <= CrossWarCommon.CHAMPIONSHIP_TOP_RANKS then
		return self._rankInChampionship
	else
		for i, v in ipairs(self._closeRanks) do
			if v.rank == self._rankInChampionship then
				return i + CrossWarCommon.CHAMPIONSHIP_TOP_RANKS
			end
		end
	end

	return 0
end

-- 获取在争霸赛挑战列表中的玩家信息
function CrossWarData:getUserInChampionList(index)
	if index <= CrossWarCommon.CHAMPIONSHIP_TOP_RANKS then
		return self:getTopRankUser(index)
	else
		return self._closeRanks and self._closeRanks[index - CrossWarCommon.CHAMPIONSHIP_TOP_RANKS]
	end
end

function CrossWarData:getBetAwardID()
	return self._betAwardID
end

function CrossWarData:getBetAwardNum()
	return self._betAwardNum
end

function CrossWarData:hasGetBetAward()
	return self._hasGetBetAward
end

function CrossWarData:hasPulledBetAward()
	return self._hasPulledBetAward
end

function CrossWarData:hasPulledServerAward()
	return self._hasPulledServerAward
end

function CrossWarData:hasFinalTopRanks()
	return self._hasFinalTopRanks
end

function CrossWarData:isServerAwardGet(id)
	return self._gotServerAwardIDs and self._gotServerAwardIDs[id]
end

function CrossWarData:canEnterScoreMatch()
	return self._warState >= CrossWarCommon.STATE_IN_SCORE_MATCH and self._group ~= 0
end

function CrossWarData:canChooseGroup()
	return self._warState == CrossWarCommon.STATE_IN_SCORE_MATCH and self._group == 0
end

function CrossWarData:canFreeRefresh()
	return self._refreshCount > 0
end

function CrossWarData:canBuyRefresh()
	return self._refreshCost > 0
end

function CrossWarData:canChallenge()
	return self._warState == CrossWarCommon.STATE_IN_SCORE_MATCH and self._group ~= 0 and self._challengeCount > 0
end

function CrossWarData:canBuyChallenge()
	return self._challengeCost > 0
end

function CrossWarData:canBet()
	return self:isChampionshipEnabled() and self._warState == CrossWarCommon.STATE_AFTER_SCORE_MATCH
end

function CrossWarData:needInvitation()
	return (self._warState == CrossWarCommon.STATE_AFTER_SCORE_MATCH or 
		    self._warState == CrossWarCommon.STATE_IN_CHAMPIONSHIP) and
	 	   self._isQualify == true and
	 	   self._qualifyType == 0
end

function CrossWarData:getOpponentInfo(i)
	return self._opponents and self._opponents[i]
end

function CrossWarData:isOpponentBeaten(index)
	return self._opponents[index].isBeaten
end

function CrossWarData:isAllOpponentsBeaten()
	for _, v in ipairs(self._opponents) do
		if not v.isBeaten then
			return false
		end
	end

	return true
end

-- 检查是否有连胜奖励可以拿
function CrossWarData:checkCanGetAward()
	-- 现在进不了积分赛，返回false
	if not self:canEnterScoreMatch() then
		return false
	end

	-- 没有连胜，当然不可能有奖
	if self._maxWinStreak <= 0 then
		return false
	end

	-- 遍历连胜奖励表
	for i = 1, contest_points_winning_info.getLength() do
		local info = contest_points_winning_info.get(i)
		local isGot = self._gotAwardIDs and self._gotAwardIDs[info.id]

		-- 没有领过，并且连胜条件达到
		if not isGot and self._maxWinStreak >= info.winning_number then
			return true
		end
	end

	return false
end

-- 检查是否有押注奖励可以拿
-- 条件：争霸赛结束 & 已拉到奖励信息 & 押中了人 & 押过筹码 & 没有领过
function CrossWarData:checkCanGetBetAward()
	--__LogTag(TAG, "----检查押注奖励, 比赛是否结束：" .. tostring(self:isChampionshipEnd()) .. " 是否拉到数据:" .. tostring(self:hasPulledBetAward()) .. " 几等奖：" .. self._betAwardID .. " 押注数：" .. self._betNum)
	return 	self:isChampionshipEnabled() and
			self:isChampionshipEnd() and
			self:hasPulledBetAward() and
			self._betAwardID > 0	 and
			self._betNum > 0		 and
			not self:hasGetBetAward()
end

-- 检查是否有全服奖励可以拿
-- 条件：争霸赛结束 & 你服务器中的某些青年进了争霸赛前10 & 你还没拿奖励
function CrossWarData:checkCanGetServerAward()
	if self:isChampionshipEnabled() and self:isChampionshipEnd() and self._topRanks then
		local myServer = G_PlatformProxy:getLoginServer().id
		for i, v in ipairs(self._topRanks) do
			if tostring(v.sid) == tostring(myServer) and 			-- 本服的青年
			   v.rank <= CrossWarCommon.CHAMPIONSHIP_TOP_RANKS and  -- 进了排行
			   not self._gotServerAwardIDs[v.rank]					-- 没领奖
			then
				return true
			end
		end
	end

	return false
end

-- 检查是否能在争霸赛中挑战
-- 条件：争霸赛进行中 & 有参赛资格 & 还有挑战次数
function CrossWarData:checkCanChallengeChampion()
	return 	self:isChampionshipEnabled() and
			self:isInChampionship() and
			self:isQualify()		and
			self._challengeCount > 0
end

-- 本轮积分赛的最终排行榜是否已经拉到
function CrossWarData:hasFinalScoreRank(group)
	-- 比赛结束，且结束后拉过排名，就算最终排名已拉过
	return self:isScoreMatchEnd() and self._hasFinalScoreRank[group] and self._scoreRankList[group]
end

return CrossWarData