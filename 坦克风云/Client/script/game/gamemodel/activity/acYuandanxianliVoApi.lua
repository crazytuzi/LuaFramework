acYuandanxianliVoApi={}

function acYuandanxianliVoApi:getAcVo( )
	return activityVoApi:getActivityVo("yuandanxianli")
end

function acYuandanxianliVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end

function acYuandanxianliVoApi:updateStrengTime()
	local vo = self:getAcVo()
	if vo then
		vo.strengTime = G_getWeeTs(base.serverTime)
	end
end
--后台的反的上次刷新的0点时间戳和今天0点的时间戳作比较 如果为true 则两个时间戳是同一天不需要刷新 如果为false则需要刷新
function acYuandanxianliVoApi:isStrengToday()
	local isToday=false
	local vo = self:getAcVo()

	if G_getWeeTs(base.serverTime)==vo.strengTime then
		isToday=true
	end

	return isToday
end

function acYuandanxianliVoApi:updateLastTime()
	local vo = self:getAcVo()
	if vo then
		vo.lastTime = G_getWeeTs(base.serverTime)
	end
end

-- function acYuandanxianliVoApi:isToday()
-- 	local isToday=false
-- 	local vo = self:getAcVo()
-- 	if vo and vo.lastTime then
-- 		isToday=G_isToday(vo.lastTime)
-- 	end
-- 	return isToday
-- end

function acYuandanxianliVoApi:canReward()
	local isfree=true							--是否是第一次免费
	if self:isToday()==true then
		isfree=false
	end
	return isfree
end

function acYuandanxianliVoApi:isToday( )
	local isToday = false
	local acVo = self:getAcVo()
	if acVo and acVo.lastTime then
		isToday=G_isToday(acVo.lastTime)
	end
	return isToday
end

function acYuandanxianliVoApi:getGems( )--拿到玩家当前拥有的（RMB）金币数量
	local acVo = self:getAcVo()
	if acVo and acVo.gems then
		return acVo.gems 	
	end
end
-- function acYuandanxianliVoApi:getCircleListCfg()-----wrong
-- 	local vo = self:getAcVo()
-- 	if vo and vo.circleList then
-- 		return vo.circleList
-- 	end
-- 	return {}
-- end


function acYuandanxianliVoApi:getRouletteCfg()--拿到后端数据(显示的数据)
	local vo=self:getAcVo()
	if vo and vo.rewardlist then
		return vo.rewardlist
	end
	return {}
end
function acYuandanxianliVoApi:getOneDrawGold()--拿到单抽 金币限制
	local vo = self:getAcVo()
	if vo and vo.oneDraw then
		return vo.oneDraw
	end
	return 0
end
function acYuandanxianliVoApi:getTenDrawGold( )--拿到十连抽 金币限制
	local vo = self:getAcVo()
	if vo and vo.tenDraw then
		return vo.tenDraw
	end 
	return 0
end

function acYuandanxianliVoApi:checkCanOnePlay( )--判断是否可以单抽
	local isCan = false

	if self:getGems() > self:getOneDrawGold() or self:canReward() then
		isCan = true
	end
	--缺当天是否 免抽 的条件

	return isCan
end

function acYuandanxianliVoApi:checkCanTenPlay( )--判断是否可以十连抽
	local isCan = false
	if self:getGems() > self:getTenDrawGold() then
		isCan = true
	end
	return isCan
end

function acYuandanxianliVoApi:getReportList( )
	local vo = self:getAcVo()
	if vo and vo.reportList then
		return vo.reportList
	end
end

function acYuandanxianliVoApi:isReportReward( index,beiShu )
	local vo = self:getAcVo()
	local reportList = self:getReportList()
	local allNum = reportList[index]*beiShu
	if allNum >= vo.reportNum then
		return true
	end
	return false
end
function acYuandanxianliVoApi:getAccessFreeTime( ) --拿强化的次数限制
	local vo = self:getAcVo()
	if vo and vo.freeTime then
		return vo.freeTime
	end
	return 0
end

function acYuandanxianliVoApi:getAccessStreng() --拿到基础强化的倍率值
	local vo = self:getAcVo()

	if vo and vo.successUp then
		return vo.successUp
	end
	return 0
end

function acYuandanxianliVoApi:refreshCurStreng( )  --零时重置当前已强化的次数
	local vo = self:getAcVo()

	if vo and vo.curStrengTime then
		--if self:isToday() ==true then
			vo.curStrengTime =0
		--end
	end

end

function acYuandanxianliVoApi:getCurStreng( )  --拿到当前已强化的次数
	local vo = self:getAcVo()
	if vo and vo.curStrengTime then

		return vo.curStrengTime
	else
		return 0
	end
end

function acYuandanxianliVoApi:setCurStreng( )
	local vo = self:getAcVo()
	if vo then
		if vo.curStrengTime == nil then
			vo.curStrengTime = 0
		end
		vo.curStrengTime=vo.curStrengTime+1
	end
end
function acYuandanxianliVoApi:isCanStreng( )
	local vo = self:getAcVo()
	local isCan = false
	if self:getCurStreng() < self:getAccessFreeTime() then
		isCan = true
	end
	return isCan

end

function acYuandanxianliVoApi:getBigReward( )--拿到最终大奖的信息（不是按钮的逻辑）
	local vo = self:getAcVo()
	if vo and vo.bigReward then
		return vo.bigReward
	end
	return {}
end

function acYuandanxianliVoApi:setHadBigReward()
	local vo = self:getAcVo()
	if vo then
		vo.isBigReward =1 
	end
end

function acYuandanxianliVoApi:getHadBigReward()
	local vo = self:getAcVo()
	if vo and vo.isBigReward then
		return vo.isBigReward
	end
	return 0
end

function acYuandanxianliVoApi:checkIsCanBigReward()
	local hadIsRewaard = self:getHadBigReward()
	if self:getAllReward()==true then
		if hadIsRewaard and hadIsRewaard>=1 then
			return false
		else
			return true
		end
	end
	return false
end

function acYuandanxianliVoApi:getDailyReward( )
	local vo = self:getAcVo()
	if vo and vo.dailyReward then
		return vo.dailyReward
	end
end

function acYuandanxianliVoApi:setDefaulSevenReward( ) --设置7天默认判断值
	local vo = self:getAcVo()
	if vo then
		if vo.sevenRe ==nil then
			vo.sevenRe={0,0,0,0,0,0,0}
		end
	end
end

function acYuandanxianliVoApi:getAllReward( )--拿到7天充值的判断（table)
	local vo = self:getAcVo()
	self:setDefaulSevenReward()
	if vo and vo.sevenRe then
		return vo.sevenRe
	end
	return {}
end
function acYuandanxianliVoApi:isAllReward( )--后端第一次给得7天数据，判断是否达到领取大奖的条件
	local sevenRe = self:getAllReward()
	local isAll = false
	for k,v in pairs(sevenRe) do
		if v ==0 then
			isAll = false
			do return end
		end
		isAll = true
	end
	return isAll
end

function acYuandanxianliVoApi:setWhichDay(day) ----改变当天是否充值的判断，需强更
	local allRe = self:getAllReward()
	local acVo = self:getAcVo()
	if acVo then 
		if acVo.sevenRe==nil then
			acVo.sevenRe = {}
		end
		acVo.sevenRe[day]=1
	end
end
-- 得到活动总天数
function acYuandanxianliVoApi:getTotalDays()
	-- return 7 -- todo 测试使用
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return math.floor((acVo.et - acVo.st)/86400) + 1
	end
	return 0
end

-- 获得第day天修改记录需要的充值数
function acYuandanxianliVoApi:getReviseNeedMoneyByDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.reviseCfg
	end
	return 999999
end
-- 得到当前时间是第几天
function acYuandanxianliVoApi:getCurrentDay()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		local day = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(acVo.st))/86400) + 1 -- 当前是活动的第几天
		return day
	end
	return 0
end
function acYuandanxianliVoApi:reFreAllday( )--当天充值完改变当天的判断值
	local acVo = self:getAcVo()
	local day = self:getCurrentDay()
	if acVo and day >0 then
		self:setWhichDay(day)
	end
end

function acYuandanxianliVoApi:setSuppleDay( day )--设置补签后的 判断值(未领取状态)
	local allRe = self:getAllReward()
	local acVo = self:getAcVo()
	if acVo then
		if acVo.sevenRe==nil then
			acVo.sevenRe = {}
		end 
		acVo.sevenRe[day]=1
	end
end
function acYuandanxianliVoApi:afterSuppleSet(suppleDay)--补签后，修改判断值
	local acVo = self:getAcVo()
	if acVo and suppleDay >0 then
		self:setSuppleDay(suppleDay)
	end
end

function acYuandanxianliVoApi:setRece( day ) --设置领取判断值
	local acVo = self:getAcVo()
	local allRe = self:getAllReward()
	if acVo and acVo.sevenRe and acVo.sevenRe[day]==1 then
		acVo.sevenRe[day]=2
	end
end