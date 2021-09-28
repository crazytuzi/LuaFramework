-- 竞技场争粮战相关数据

local ArenaRobRiceData = class("ArenaRobRiceData")

require("app.cfg.rice_time_info")

function ArenaRobRiceData:ctor( ... )
	
	self.rice_rank = 0 				--粮草排名
  	self.init_rice = 0 				--可抢夺粮草
  	self.growth_rice = 0 			--不可夺粮草
  	self.rice_refresh_time = 0 		--粮草自增刷新时间
  	self.rivals = {} 				--对手列表
  	self.rival_flush_time = 0 		--对手匹配时间
  	self.revenge_token = 0 			--复仇令数量
  	self.buy_revtoken_times = 0 	--购买复仇令次数
  	self.rob_token = 0 				--抢粮令数量
  	self.rob_token_refresh_time = 0 --抢粮令刷新时间戳
  	self.last_rob_time = 0 		    --上次抢粮时间戳
  	self.buy_robtoken_times = 0 	--抢粮令购买次数
  	self.achievement_list = {} 		--已完成成就
  	self.rank_award = 0 			--排行榜奖励领取时间戳(0:未领取/大于0:已领取)

  	self.hasAttended = true  		--玩家是否参与过本轮的粮草抢夺
  	self.crit = 0 					--暴击粮草

  	self.enemies = {}
  	self.enemiesToRevenge = {} --可以复仇的玩家列表 
  	self.achievement_state_list = {}  -- 所有成就奖励的状态(0:未领取、1:已领取、2:未达成)

  	self.old_init_rice = 0 			-- 本次更新前的可抢夺粮草
  	self.old_growth_rice = 0		-- 本次更新前的不可抢夺粮草
  	self.old_rivals = {}			-- 上一次协议返回的对手信息
  	self.rivals_copy = {} 			-- 当前对手副本，更具user_id排序

end

-- 获取配置中夺粮结束的时间戳
function ArenaRobRiceData:getRobEndTime(  )
	local dateObj = G_ServerTime:getDateObject()
	local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

	local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))
	-- 根据表中时间算出活动结束的时间戳
	local endTime = G_ServerTime:getTime() - secTillNow  + timeInfo.end_time

	return endTime
end

-- 获取配置中领奖结束的时间戳
function ArenaRobRiceData:getPrizeEndTime(  )
	local dateObj = G_ServerTime:getDateObject()
	local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

	local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))
	-- 根据表中时间算出活动结束的时间戳
	local prizeEndTime = G_ServerTime:getTime() - secTillNow  + timeInfo.prize_end

	return prizeEndTime
end

-- 是否处于争粮战领奖时间当中
function ArenaRobRiceData:isInRewardTime( ... )
	-- body
end

function ArenaRobRiceData:updateUserRiceInfo( data )
	-- __Log("===========================ArenaRobRiceData:updateUserRiceInfo=======================")
	self.old_init_rice 				 = self.init_rice
	self.old_growth_rice 			 = self.growth_rice

	self:updateOldRivalsInfo()

	self.rice_rank					 = data.rice_rank
  	self.init_rice					 = data.init_rice
  	self.growth_rice				 = data.growth_rice + self:_grownRice()
  	self.rice_refresh_time			 = self:_calRiceRefreshTime() + data.rice_refresh_time
  	self.rival_flush_time			 = data.rival_flush_time
  	self.revenge_token				 = data.revenge_token
  	self.buy_revtoken_times			 = data.buy_revtoken_times
  	self.rob_token 					 = data.rob_token
  	self.rob_token_refresh_time		 = data.rob_token_refresh_time
  	self.last_rob_time				 = data.last_rob_time
  	self.buy_robtoken_times			 = data.buy_robtoken_times
  	self.achievement_list			 = data.achievement_list
  	self.rank_award					 = data.rank_award

	local oppList = data.rivals
	for i = 1, #oppList do
		local oppData = oppList[i]

		self.rivals[i] = {
			name		 = oppData.name,
			fightValue	 = oppData.fight_value,
			userId		 = oppData.user_id,
			initRice 	 = oppData.init_rice,
			growthRice 	 = oppData.growth_rice + self:_grownRice(), 
			baseId		 = oppData.base_id,
			corpId		 = oppData.corp_id,
		}
	end

	local sortFunc = function ( a, b )
		if a.initRice == b.initRice then
			return a.fightValue > b.fightValue
		end

		return (a.initRice + a.growthRice) > (b.initRice + b.growthRice)
	end

	table.sort( self.rivals, sortFunc )

	
	-- 旧的对手信息按userId排序
	local sortFuncForOld = function ( a, b )
		return a.userId > b.userId
	end
	self.rivals_copy = clone(self.rivals)
	table.sort( self.rivals_copy, sortFuncForOld )

	self:updateAchievementState()

end

function ArenaRobRiceData:updateOppList( oppList )
	
end

-- 攻打过我的玩家
function ArenaRobRiceData:updateRiceEnemyInfo( enemies )
	self.enemies = {}
	-- 过滤复仇失败的玩家
	for i=1, #enemies do
		if not (enemies[i].revenge == 2 and enemies[i].rob_result <= 0) then
			-- enemies[i].
			table.insert(self.enemies, enemies[i])			
		end
	end

	-- 更新可复仇玩家列表
	self.enemiesToRevenge = {}
	for i = 1, #self.enemies do
		if self.enemies[i].revenge == 0 and self.enemies[i].rob_result > 0 then
			table.insert(self.enemiesToRevenge, self.enemies[i])
		end 
	end

	local sortFunc = function ( a, b )
		return a.id > b.id 
	end
	table.sort(self.enemies, sortFunc)
	table.sort(self.enemiesToRevenge, sortFunc)
end

-- 争粮战排行榜
function ArenaRobRiceData:updateRankList( rankList )
	for i=1,#rankList do
		rankList[i].rice = rankList[i].rice + self:_grownRice()
	end
	self.rankList = rankList
end

function ArenaRobRiceData:hasEnemyToRevenge( ... )
	return #self.enemiesToRevenge > 0
end

-- 活动是否可进入
function ArenaRobRiceData:isRobRiceOpen( ... )
    local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

    local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))

	if timeInfo == nil then
		return false
	end

    -- 根据表中时间算出活动结束的时间戳
    local endTime = G_ServerTime:getTime() - secTillNow  + timeInfo.end_time
    local startTime = timeInfo.start_time
    local prizeEnd = timeInfo.prize_end
    if secTillNow >= startTime and secTillNow <= prizeEnd then
    	return true
    else
    	return false
    end
end

-- 当前是否可以夺粮草
function ArenaRobRiceData:isRobNowOpen( ... )
    local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

    local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))

	if timeInfo == nil then
		return false
	end

    -- 根据表中时间算出活动结束的时间戳
    local endTime = G_ServerTime:getTime() - secTillNow  + timeInfo.end_time
    local startTime = timeInfo.start_time
    local robEndTime = timeInfo.end_time
    local prizeEnd = timeInfo.prize_end
    if secTillNow >= startTime and secTillNow <= robEndTime then
    	return true
    else
    	return false
    end
end

-- 是否处于领奖开放时间 price = prize ....
function ArenaRobRiceData:isGetPriceOpen( ... )
    local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

    local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))

	if timeInfo == nil then
		return false
	end

    -- 根据表中时间算出活动结束的时间戳
    local endTime = G_ServerTime:getTime() - secTillNow  + timeInfo.end_time
    local startTime = timeInfo.start_time
    local robEndTime = timeInfo.end_time
    local prizeEnd = timeInfo.prize_end
    if secTillNow >= robEndTime and secTillNow <= prizeEnd then
    	return true
    else
    	return false
    end
end

-- 今天是否会开放
function ArenaRobRiceData:willOpenToday( ... )
    local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

	local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))

	if timeInfo == nil then
		return false
	end

    -- 根据表中时间算出活动结束的时间戳
    local endTime = G_ServerTime:getTime() - secTillNow  + timeInfo.end_time
    local startTime = timeInfo.start_time
    local prizeEnd = timeInfo.prize_end
    if secTillNow < prizeEnd then
    	return true
    else
    	return false
    end
end

-- 获取开放时间相关信息
function ArenaRobRiceData:getOpenTimeInfo( ... )
    local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec

	local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))

	if timeInfo == nil then
		return nil
	end

	return timeInfo
end

-- 令牌剩余购买次数
function ArenaRobRiceData:getTokenRemainBuyTimes( tokenType )
	local myVip = G_Me.userData.vip
	__Log("============myVip = %d", myVip)

	local vipType =  require("app.const.VipConst").ROBRICE	-- 26 挑战次数VIP类型
	local buyType = 16
	local boughtTimes = self:getBuyRobTokenTimes()

	if tokenType == 1 then
		vipType = require("app.const.VipConst").ROBRICEREVENGE
		buyType = 18
		boughtTimes = self:getBuyRevTokenTimes()
	end

	local totalCanBuy = G_Me.vipData:getData(vipType).value
	-- __Log("==========totalCanBuy = %d", self._totalCanBuy)

	local remainBuyCount = totalCanBuy - boughtTimes

	return remainBuyCount
end

function ArenaRobRiceData:getEnemies( ... )
	return self.enemies
end

function ArenaRobRiceData:getEnemiesToRevenge( ... )
	return self.enemiesToRevenge
end

function ArenaRobRiceData:removeEnemyToRevenge( revengeId )
	for i=1, #self.enemiesToRevenge do
		if revengeId == self.enemiesToRevenge[i].id then
			table.remove(self.enemiesToRevenge, i)
			break
		end
	end

	-- 更新整体仇人列表
	for i = 1, #self.enemies do
		if revengeId == self.enemies[i].id then
			self.enemies[i].revenge = 1
			break
		end
	end
end

function ArenaRobRiceData:getRankList( ... )
	return self.rankList
end

function ArenaRobRiceData:getRiceRank( ... )
	return self.rice_rank
end

function ArenaRobRiceData:updateRiceRank( rank )
	self.rice_rank = rank
end

function ArenaRobRiceData:getInitRice( ... )
	return self.init_rice
end

function ArenaRobRiceData:getGrowthRice( ... )
	return self.growth_rice
end

function ArenaRobRiceData:setGrowthRice( growthRice )
	self.growth_rice = growthRice
end

function ArenaRobRiceData:getTotalRice( ... )
	return self.growth_rice + self.init_rice
end

function ArenaRobRiceData:setAchievementId( achievement_id )
	self.achievement_id = achievement_id
end

function ArenaRobRiceData:getAchievementId( ... )
	return self.achievement_id
end

function ArenaRobRiceData:getBuyRobTokenTimes( ... )
	return self.buy_robtoken_times
end

function ArenaRobRiceData:getRobToken( ... )
	return self.rob_token
end

function ArenaRobRiceData:setRobToken( robToken )
	self.rob_token = robToken
end

function ArenaRobRiceData:getRevengeToken( ... )
	return self.revenge_token
end

function ArenaRobRiceData:getBuyRevTokenTimes()
	return self.buy_revtoken_times
end

function ArenaRobRiceData:getOppList( ... )
	return self.rivals
end

function ArenaRobRiceData:getOppInfo( i )
	-- dump(self.rivals[1])
	return self.rivals and self.rivals[i]
end

function ArenaRobRiceData:getRiceRefreshTime( ... )
	return self.rice_refresh_time
end

function ArenaRobRiceData:setRiceRefreshTime( t )
	self.rice_refresh_time = t
end

function ArenaRobRiceData:getRobTokenRefreshTime( ... )
	return self.rob_token_refresh_time
end

function ArenaRobRiceData:setRobTokenRefreshTime( t )
	self.rob_token_refresh_time = t
end

function ArenaRobRiceData:getRankAward( ... )
	return self.rank_award
end

function ArenaRobRiceData:setRankAward( status )
	self.rank_award = status
end

function ArenaRobRiceData:setAttendInfo( hasAttended )
	self.hasAttended = hasAttended
end

function ArenaRobRiceData:hasAttendedRobRice( ... )
	return self.hasAttended
end

-- 将星期几转换成
function ArenaRobRiceData:_changeWeekFormat( wday )
	local wdayReal = wday - 1
	if wdayReal == 0 then wdayReal = 7 end
	return wdayReal
end

-- 计算从活动开始到现在增加的粮草数量
function ArenaRobRiceData:_grownRice( ... )
	local basicFigureInfo = basic_figure_info.get(4)
	local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec
    local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))
    if secTillNow > timeInfo.end_time then
    	secTillNow = timeInfo.end_time
	end
    local rice = math.floor(((secTillNow - timeInfo.start_time) / basicFigureInfo.unit_time)) * basicFigureInfo.unit_recover

    return rice
end

-- 就算粮草增长的时间
function ArenaRobRiceData:_calRiceRefreshTime( ... )
	local basicFigureInfo = basic_figure_info.get(4)
	local dateObj = G_ServerTime:getDateObject()
    local secTillNow = dateObj.hour * 3600 + dateObj.min * 60 + dateObj.sec
    local timeInfo = rice_time_info.get(self:_changeWeekFormat(dateObj.wday))
    local t = (math.floor((secTillNow - timeInfo.start_time) / basicFigureInfo.unit_time) + 1) * basicFigureInfo.unit_time + timeInfo.start_time

    -- __Log("---------------t----------------" .. t)
    return t
end

-- 是否有排名奖励可领取
function ArenaRobRiceData:hasRankAwardToRecieve( ... )

	local ret = true
	if not self.hasAttended or self.rice_rank <= 0 or self.rank_award > 0 then
		ret = false
	end

	return ret
end

-- 更新已领取成就列表（这里在领取成就成功之后，调用）
function ArenaRobRiceData:updateAchievementList( achievementId )
	table.insert(self.achievement_list, achievementId)

	-- 再更新一下成就状态
	self:updateAchievementState()
end

-- 计算各个成就奖励的状态
function ArenaRobRiceData:updateAchievementState(  )
	require("app.cfg.rice_achievement")

	self.achievement_state_list = {}

	local totalRice = self:getTotalRice()
	for i = 1, rice_achievement.getLength() do
		local achievementInfo = rice_achievement.get(i)

		if achievementInfo.num <= totalRice then
			-- __Log("achievementInfo.num %d", achievementInfo.num)
			-- __Log("totalRice %d", totalRice)
			-- 未领取
			local achieveState = {state = 0}
			for i = 1, #self.achievement_list do
				if self.achievement_list[i] == achievementInfo.id then
					-- 已经领取过
					achieveState = {state = 1}
					break
				end
			end
			table.insert(self.achievement_state_list, achieveState)
		else
			-- 为达成
			local achieveState = {state = 2}
			for i = 1, #self.achievement_list do
				if self.achievement_list[i] == achievementInfo.id then
					-- 已经领取过
					achieveState = {state = 1}
					break
				end
			end
			table.insert(self.achievement_state_list, achieveState)
		end

	end

end

function ArenaRobRiceData:hasAchievementToRecieve(  )
	local ret = false

	for i = 1, #self.achievement_state_list do
		if self.achievement_state_list[i].state == 0 then
			ret = true
			break
		end
	end

	return ret
end

-- 还差多少粮草可达成下一个奖励
function ArenaRobRiceData:getLackRiceToNextAchievement( ... )
	local num = -1

	for i = 1, #self.achievement_state_list do
		if self.achievement_state_list[i].state == 2 then
			require("app.cfg.rice_achievement")
			local achievementInfo = rice_achievement.get(i)
			if achievementInfo == nil then
				
			else
				num = achievementInfo.num - self:getTotalRice()
			end

			break
		end
	end

	return num
end

function ArenaRobRiceData:getAchievementStateList(  )
	return self.achievement_state_list
end

function ArenaRobRiceData:setCritRice( num )
	self.crit = num
end

function ArenaRobRiceData:getCritRice(  )
	return self.crit
end

function ArenaRobRiceData:getOldInitRice(  )
	return self.old_init_rice
end

function ArenaRobRiceData:setOldInitRice( num )
	self.old_init_rice = num
end

function ArenaRobRiceData:getOldGrowthRice(  )
	return self.old_growth_rice
end

function ArenaRobRiceData:setOldGrowthRice( num )
	self.old_growth_rice = num
end

function ArenaRobRiceData:getOldTotalRice(  )
	return self.old_init_rice + self.old_growth_rice
end

-- 后端返回协议可能对手信息是不变的
function ArenaRobRiceData:hasRivalsChanged(  )
	if #self.rivals_copy ~= 4 or #self.old_rivals ~= 4 then
		return true
	end

	local ret = false
	for i= 1, #self.rivals_copy do
		if self.rivals_copy[i].userId ~= self.old_rivals[i].userId then
			ret = true
			break
		end
	end
	return ret
end

-- 更行旧的对手信息
function ArenaRobRiceData:updateOldRivalsInfo(  )
	self.old_rivals = {}
	for i = 1, #self.rivals do
		self.old_rivals[i] = self.rivals[i]
	end
	-- 旧的对手信息按userId排序
	local sortFuncForOld = function ( a, b )
		return a.userId > b.userId
	end
	table.sort( self.old_rivals, sortFuncForOld )
end

-- 清除旧的对手信息
function ArenaRobRiceData:resetOldRivalsInfo(  )
	if self.old_rivals then
		self.old_rivals = {}
	end
end

return ArenaRobRiceData

