acLuckyCatVoApi={}

function acLuckyCatVoApi:canReward()
	local acVo = self:getAcVo()
	local nextLotteryTimes = acLuckyCatVoApi:getLocalLotteryTimes()
	local largeTimesLoc,largestTimes = self:getlargeTimes( )
	if acVo ~= nil then
		if nextLotteryTimes and largestTimes and nextLotteryTimes == largestTimes then
			return false
		elseif playerVoApi:getPlayerLevel() >=5 then
			return true
		else
			return false
		end
	end
	return false
end
function acLuckyCatVoApi:getAcVo()
	return activityVoApi:getActivityVo("xinfulaba")
end


function acLuckyCatVoApi:getLastResultByLine(line)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.lastResult[line]
	end
	return 0
end

function acLuckyCatVoApi:updateLastResult(result)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.lastResult = result
	end
end
function acLuckyCatVoApi:getSelfVipLevel( )--拿到当前玩家的VIP等级
	if self:getAcVo() then
		local vipLevel = playerVoApi:getVipLevel()
		if vipLevel then
			return vipLevel
		end
	end
	return 0
end
function acLuckyCatVoApi:getLocalLotteryTimes( )--当前抽奖次数
	local acVo = self:getAcVo()
	if acVo and acVo.loclotteryTimes then
		return acVo.loclotteryTimes
	end
	return 0
end
function acLuckyCatVoApi:setLocalLotteryTimes( num )--设置当前抽奖次数
	local acVo = self:getAcVo()
	if acVo and acVo.loclotteryTimes then
		acVo.loclotteryTimes = num
	end
end
function acLuckyCatVoApi:getLotteryTimes()--拿到下一次抽奖的次数
	local acVo = self:getAcVo()
	if acVo and acVo.numTime then
		return acVo.numTime
	end
	return acVo.numTime
end
function acLuckyCatVoApi:setLotteryTimes( )--设置下一次抽奖的次数
	local acVo = self:getAcVo()
	local currTimes = self:getLocalLotteryTimes( )
	local largeTime,largestTimes = self:getlargeTimes( )
	if acVo and acVo.numTime and largeTime and currTimes then
		if acVo.numTime <largeTime+1 and largeTime <=largestTimes and currTimes ~= 9 then
			acVo.numTime =currTimes+1
		end
	end
end

function acLuckyCatVoApi:getlargeTimes( )
	local acVo = self:getAcVo()
	local rewardPool = self:getRewardPool()
	local viplevel = playerVoApi:getVipLevel() --self:getSelfVipLevel()
	local largestTimes=nil
	if rewardPool and acVo and acVo.currLargeTimes then 
		for k,v in pairs(rewardPool) do
			if viplevel >=v.vip then
				acVo.currLargeTimes =k
			end
			largestTimes=k
		end
		
	end
	return acVo.currLargeTimes,largestTimes
end

function acLuckyCatVoApi:getRewardPool( )
	local acVo = self:getAcVo()
	if acVo and acVo.rewardPool then
		return acVo.rewardPool
	end
	return nil
end
function acLuckyCatVoApi:getNextSingleReward( )
	local lotteryTimes = self:getLotteryTimes()
	local viplevel = playerVoApi:getVipLevel() --self:getSelfVipLevel()
	local rewardPool = self:getRewardPool()
	local acVo = self:getAcVo()
	local singleRewardPool = nil
	if acVo and rewardPool and lotteryTimes then
		for k,v in pairs(rewardPool) do
			if k ==lotteryTimes then
					singleRewardPool =v
			end
		end
		if singleRewardPool ==nil then
			print("singleRewardPool--------->NULL!!!!!!!")
		end
	end
	return singleRewardPool
end
function acLuckyCatVoApi:getNeedGold( )--拿到抽奖需要的支付的金币数
	local singleRewardPool = self:getNextSingleReward()
	if singleRewardPool and singleRewardPool.need then
		return singleRewardPool.need
	end
	return nil
end
function acLuckyCatVoApi:getWillGetGold( )--拿到抽奖得奖的上下金币限制	
	local singleRewardPool = self:getNextSingleReward()
	if singleRewardPool and singleRewardPool.get then
		return singleRewardPool.get
	end
	return nil
end
function acLuckyCatVoApi:getShowRecGold( )--拿到中奖的广播的下限金币数量
	local singleRewardPool = self:getNextSingleReward()
	if singleRewardPool and singleRewardPool.report then
		return singleRewardPool.report
	end
	return nil
end
function acLuckyCatVoApi:getNeedVip( )--拿到抽奖需要的VIP等级限制
	local singleRewardPool = self:getNextSingleReward()
	if  singleRewardPool and singleRewardPool.vip then
		return singleRewardPool.vip
	end
	return nil
end


function acLuckyCatVoApi:getTimesAndMoney( )----------------拿到下一次抽奖的次数 和相应得到的金币数
	local acVo = self:getAcVo()
	local lotteryTimes = self:getLotteryTimes()
	local largeGold = self:getWillGetGold()
	if lotteryTimes and largeGold then
		return lotteryTimes,largeGold[2]
	end
	return nil
end

function acLuckyCatVoApi:setRecordList( recordList)
	local acVo =self:getAcVo()
	if acVo then
		acVo.recordList =recordList
	end
end
function acLuckyCatVoApi:getRecordList()
	local acVo = self:getAcVo()
	if acVo then
		return acVo.recordList
	end
	return nil
end

function acLuckyCatVoApi:setShowNow( isShow)
	local acVo =self:getAcVo()
	if acVo then
		acVo.isShow =isShow
	end
end
function acLuckyCatVoApi:getShowNow( )
	local acVo =self:getAcVo()
	if acVo and acVo.isShow then
		return acVo.isShow
	end
	return nil
end
function acLuckyCatVoApi:setNewShowData(name,point)
	if name and point then
		local acVo =self:getAcVo()
		if acVo then
			acVo.Player =name
			acVo.PlayerGold =point
			self:setNewDataInRecordList(acVo.Player,acVo.PlayerGold)
		end
	end
end
function acLuckyCatVoApi:setNewDataInRecordList(name,point)
	local recordList =self:getRecordList()
	local newRecordList ={}
	newRecordList = G_clone(recordList)
	if recordList and name and point then
		if SizeOfTable(newRecordList) ~=0 then
			if name and point then
				newRecordList[1][1]=name
				newRecordList[1][2]=point
			end
		else
			table.insert(newRecordList,{name,point})
		end

		for i=2,6 do
			if recordList[i-1]then
				if recordList[i] ==nil and i<7 then
					table.insert(newRecordList,{recordList[i-1][1],recordList[i-1][2]})
				else
					newRecordList[i][1]=recordList[i-1][1]
					newRecordList[i][2]=recordList[i-1][2]
				end
			end
		end
		self:setRecordList(newRecordList)
		self:setShowNow(true)
	end

	
end
function acLuckyCatVoApi:getNewShowData( )
	local acVo = self:getAcVo()
	if acVo and acVo.Player and acVo.PlayerGold then
		return acVo.Player,acVo.PlayerGold
	end
	return nil,nil
end