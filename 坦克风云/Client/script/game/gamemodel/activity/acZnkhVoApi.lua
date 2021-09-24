acZnkhVoApi={}

function acZnkhVoApi:getAcVo()
	return activityVoApi:getActivityVo("znkh")
end

function acZnkhVoApi:getVersion()
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

function acZnkhVoApi:canReward()
	if self:isToday() == false then
		self:updateFree()
	end
	if self:isRewardTime()==false and self:isFree() then
		return true
	end
	if self:isShowNumRewardRedPoint() then
		return true
	end
	if self:isCanGetRankReward() then
    	return true
    end

	return false
end

function acZnkhVoApi:isToday()
	local vo = self:getAcVo()
	local isToday = false
	if vo and vo.todayTimer then
		-- isToday = vo.todayTimer-base.serverTime<24*60*60
		isToday = G_isToday(vo.todayTimer)
	end
	return isToday
end

function acZnkhVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = vo.et - 86400 - base.serverTime > 0 and G_formatActiveDate(vo.et - 86400 - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activityCountdown")..":"..activeTime
	end
	return str
end

function acZnkhVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = G_formatActiveDate(vo.et - base.serverTime)
		if self:isRewardTime()==false then
			activeTime=getlocal("notYetStr")
		end
		return getlocal("onlinePackage_next_title")..activeTime
	end
	return str
end

--监测是否有排名
function acZnkhVoApi:checkIsHaveRnak()
	if self.isHaveRank==nil and self:isGetRankReward() == false and self:isRewardTime() and self:getLotteryScore()>=self:getRankLimit() then
		socketHelper:acZnkhRankList(function(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				local rankList = sData.data.ranklist
	        	table.sort(rankList, function(a,b)
	        		if a[3] and b[3] and tonumber(a[3]) > tonumber(b[3]) then
	        			return true
	        		end
	        	end)
	        	local _isUnRnak=true
	        	for k,v in pairs(rankList) do
	        		if v[1]==playerVoApi:getUid() then
	        			-- local tb = G_clone(v)
	        			-- tb.rank=k
	        			-- table.insert(rankList,1,tb)
	        			_isUnRnak=false
	        			break
	        		end
	        	end
	        	self.isHaveRank=(not _isUnRnak)
	        	-- if _isUnRnak then --未上榜
	        	-- else
	        	-- 	self.isHaveRank=true
	        	-- end
			end
		end)
	end
end

--是否可以领取排行榜奖励
function acZnkhVoApi:isCanGetRankReward()
	if self:isGetRankReward() == false and self:isRewardTime() and self:getLotteryScore()>=self:getRankLimit() then
    	if self.isHaveRank==true then
    		return true
    	else
    		self:checkIsHaveRnak()
    	end
    end
    return false
end

--是否已领取排行榜奖励
function acZnkhVoApi:isGetRankReward()
	local vo = self:getAcVo()
	if vo then
		if vo.isGetRankReward==1 then
			return true
		end
	end
	return false
end

--是否处于领奖时间
function acZnkhVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo then
		if base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt then
			return true
		end
	end
	return false
end

function acZnkhVoApi:isFree()
	local vo = self:getAcVo()
	if vo then
		if vo.isUseFree==1 then
			return false
		end
	end
	return true
end

function acZnkhVoApi:updateFree()
	local vo = self:getAcVo()
	if vo and vo.isUseFree then
		vo.isUseFree=0
	end
end

--获取累计抽奖次数
function acZnkhVoApi:getTotalLotteryNum()
	local vo = self:getAcVo()
	if vo and vo.totalLotteryNum then
		return vo.totalLotteryNum
	end
	return 0
end

function acZnkhVoApi:getRankLimit()
	local vo = self:getAcVo()
	if vo and vo.rankLimit then
		return vo.rankLimit
	end
	return 0
end

--是否次数红点显示
function acZnkhVoApi:isShowNumRewardRedPoint()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		for k,v in pairs(vo.rndNumReward) do
			local _num=v[1]
			if self:getTotalLotteryNum()>=_num and (not self:isGetNumReward(v[1])) then
				return true
			end
		end
	end
	return false
end

--获取次数奖励
function acZnkhVoApi:getNumReward()
	local vo = self:getAcVo()
	if vo and vo.rndNumReward then
		return vo.rndNumReward
	end
end

--是否已领取次数奖励 _num:次数
function acZnkhVoApi:isGetNumReward(_num)
	local vo = self:getAcVo()
	if vo and vo.fr then
		for k,v in pairs(vo.fr) do
			if v==_num then
				return true
			end
		end
	end
	return false
end

function acZnkhVoApi:getOpenLevel()
	local vo = self:getAcVo()
	if vo and vo.openLevel then
		return vo.openLevel
	end
	return 0
end

function acZnkhVoApi:getRewardPoint(_key)
	local vo = self:getAcVo()
	if vo and vo.point then
		for k,v in pairs(vo.point) do
			local tb = FormatItem(v)
			for m, n in pairs(tb) do
				if n.key==_key then
					return n.num
				end
			end
		end
	end
	return 0
end

--获取抽奖奖池 1:普通抽奖,2:连号奖,3:年份奖
function acZnkhVoApi:getRewardPool(_index)
	local vo = self:getAcVo()
	if vo and vo.reward then
		if _index then
			return FormatItem(vo.reward[_index],nil,true)
		else
			local awardTb = {}
			for k, v in pairs(vo.reward) do
				local formatTb = FormatItem(v,nil,true)
				table.insert(awardTb,formatTb)
			end
			return awardTb
		end
	end
end

--获取大奖
function acZnkhVoApi:getBigReward()
	local vo = self:getAcVo()
	if vo and vo.reward then
		--大奖是索引 3
		local bigRewardTb = FormatItem(vo.reward[3],nil,true)
		local size = SizeOfTable(bigRewardTb)
		if size < 3 then --如果不满足3个，就从索引2中取
			local formatTb = FormatItem(vo.reward[2],nil,true)
			for k, v in pairs(formatTb) do
				table.insert(bigRewardTb,v)
				size=size+1
				if size>=3 then
					break
				end
			end
		end
		return bigRewardTb
	end
end

--获取抽奖积分
function acZnkhVoApi:getLotteryScore()
	local vo = self:getAcVo()
	if vo and vo.lotteryScore then
		return vo.lotteryScore
	end
	return 0
end

--获取单抽所消耗的金币数
function acZnkhVoApi:getOneLotteryCost()
	local vo = self:getAcVo()
	if vo and vo.oneLotteryCost then
		return vo.oneLotteryCost
	end
	return 0
end

--获取五抽所消耗的金币数
function acZnkhVoApi:getFiveLotteryCost()
	local vo = self:getAcVo()
	if vo and vo.fiveLotteryCost then
		return vo.fiveLotteryCost
	end
	return 0
end

--排行榜奖励
function acZnkhVoApi:getRankReward(_rank)
	local vo = self:getAcVo()
	if vo and vo.rankReward and _rank then
		for k,v in pairs(vo.rankReward) do
			if _rank>=tonumber(v[1][1]) and _rank<=tonumber(v[1][2]) then
				return FormatItem(v[2],nil,true)
			end
		end
	end
end

function acZnkhVoApi:getRankRewardDesc()
	local vo = self:getAcVo()
	if vo and vo.rankReward then
		local strTb={}
		for k,v in pairs(vo.rankReward) do
			-- rankOne="第%s名",
 		-- 	rankTwo="第%s-%s名",
			local _str=""
			if tonumber(v[1][1]) == tonumber(v[1][2]) then
				_str=getlocal("rankOne",{tostring(v[1][1])})
			else
				_str=getlocal("rankTwo",{tostring(v[1][1]),tostring(v[1][2])})
			end
			_str=_str.."："
			local tb = FormatItem(v[2],nil,true)
			local _size=SizeOfTable(tb)
			for i,j in pairs(tb) do
				_str=_str..j.name.."x"..j.num
				if i~=_size then
					_str=_str..","
				end
			end
			table.insert(strTb,_str)
		end
		return strTb
	end
end

--格式化抽奖记录
function acZnkhVoApi:formatLog(_data,addFlag)
	self.lotteryLog={}
	for k,v in pairs(_data) do
		local data=v[1]
		local num=data[1]
		-- if num==2 then
		-- 	num=10
		-- else
		-- 	num=1
		-- end
		local rewards=data[2]
		local rewardlist={}
		for k,v in pairs(rewards) do
			local reward=FormatItem(v,nil,true)
			table.insert(rewardlist,reward[1])
		end
		local hxReward=self:getHxReward()
		if hxReward then
			hxReward.num=hxReward.num*num
			table.insert(rewardlist,1,hxReward)
		end
		local time=data[3] or base.serverTime
		local lcount=SizeOfTable(self.lotteryLog)
		if lcount>=10 then
			for i=10,lcount do
				table.remove(self.lotteryLog,i)
			end
		end
		if addFlag and addFlag==true then
	    	table.insert(self.lotteryLog,1,{num=num,reward=rewardlist,time=time})
		else
		    table.insert(self.lotteryLog,{num=num,reward=rewardlist,time=time})
		end
	end
end

--获取抽奖记录
function acZnkhVoApi:getLotteryLog()
	if self.lotteryLog then
		return self.lotteryLog
	end
end

--获取和谐版奖励
function acZnkhVoApi:getHxReward()
	local vo = self:getAcVo()
	if vo and vo.hxReward then
		return FormatItem(vo.hxReward)[1]
	end
end

function acZnkhVoApi:updateData(data)
	if data then
		local vo=self:getAcVo()
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acZnkhVoApi:clearAll()
	self.isHaveRank=nil
	self.lotteryLog=nil
end