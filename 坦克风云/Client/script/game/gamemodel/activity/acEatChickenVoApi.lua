acEatChickenVoApi={
	name=nil,
	pScoresTb = {},
	aScoresTb = {},
	aAwardsTb = {},
	pAwardsTb = {},
	top6InAllianceScoresTb = {},
	upDataState = false,
	upDataState1 = false,
	aScoresStateTb = {},
	curStateTb = {},
	aRankListlastTime=nil,
	lotteryLog = {},
	aRankList = {},
	eatingNums = 1,
}

function acEatChickenVoApi:clearAll()
	self.pScoresTb = {}
	self.aScoresTb = {}
	self.aAwardsTb = {}
	self.pAwardsTb = {}
	self.name=nil
	self.upDataState = nil
	self.upDataState1 = nil
	self.aScoresStateTb = {}
	self.curStateTb = {}
	self.aRankListlastTime = nil
	self.lotteryLog = {}
	self.aRankList = {}
	self.eatingNums = nil
	self.top6InAllianceScoresTb = {}
end

function acEatChickenVoApi:getCost(choseIdx)
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		local cfg = vo.activeCfg
		if choseIdx ==1 then
			return vo.activeCfg.cost
		else
			return vo.activeCfg.cost5
		end
	end
	return 999999
end

function acEatChickenVoApi:getFirst( )--
	local vo = self:getAcVo()
	if vo and vo.first then
		return vo.first
	end
	return 0
end

function acEatChickenVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acEatChickenVoApi:updateInServer(state,data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		self.upDataState = state
	end
end

function acEatChickenVoApi:setUpDataState1(state)--只用于第一个签
	self.upDataState1 = state
end
function acEatChickenVoApi:getUpDataState1()--只用于第一个签
	return self.upDataState1
end

function acEatChickenVoApi:setNewAllianceScores(newAllianceScores )
	local vo  = self:getAcVo()
	if vo and vo.legionMembersScores then
		-- print("newAllianceScores=====vo.legionMembersScores======>>>>",newAllianceScores,vo.legionMembersScores)
		vo.legionMembersScores = newAllianceScores
		-- print("change vo.legionMembersScores======>>>>",vo.legionMembersScores)
	end
end
function acEatChickenVoApi:getNewAllianceScores( )
	local vo = self:getAcVo()
	if vo and vo.legionMembersScores then
		return vo.legionMembersScores
	end
	return 0
end
------------------------------------------------------------------------------------------------
function acEatChickenVoApi:getRechargeNums( )--充值金币数
	local vo = self:getAcVo()
	if vo and vo.rechargeNums then
		return vo.rechargeNums
	end
	return 0
end
function acEatChickenVoApi:getSixKillProbability( )--拿到六杀倍数相关数据：返回值依次是：当前6杀倍数，当前充值金币数，当前档位，下一级倍数，下一级充值档位
	local vo = self:getAcVo()
	local curRechargeNums = self:getRechargeNums()
	local curProbability = 0
	if vo and vo.activeCfg then
		local MaxtTims = vo.activeCfg.MaxtTims or nil
		local maxKill = vo.activeCfg.maxKill or nil
		if MaxtTims and maxKill then
			local rechargeTb = maxKill[2]

			for i=1,SizeOfTable(rechargeTb) do
				if curRechargeNums <= rechargeTb[i][2] then
					curProbability = MaxtTims[i]
					local lowerLimit = rechargeTb[i][1]
					if i < SizeOfTable(rechargeTb) then
						local nextProbability = MaxtTims[i + 1]
						local nextRchargeNums = rechargeTb[i + 1][1]
						return curProbability,curRechargeNums,lowerLimit,nextProbability,nextRchargeNums
					else
						return curProbability,curRechargeNums,lowerLimit
					end
				end
			end
		end
	end
	return curRechargeNums
end

function acEatChickenVoApi:getBigAwardProbability( )--大奖获得概率 :
	local vo = self:getAcVo()
	local curSingleScores = self:getSingleScores()
	local bigAwardProbability = 0
	if vo and vo.activeCfg then
		local pNeedScoresTb = vo.activeCfg.persionPoint or nil
		local proTb = vo.activeCfg.times or nil
		if pNeedScoresTb and proTb then
			for i=1,SizeOfTable(pNeedScoresTb) do
				if curSingleScores <= pNeedScoresTb[i][2] then
					bigAwardProbability = proTb[i]
					local lowerLimit = pNeedScoresTb[i][1]
					if i < SizeOfTable(pNeedScoresTb) then
						local nextProbability = proTb[i + 1]
						local nextScores = pNeedScoresTb[i + 1][1]
						return bigAwardProbability,curSingleScores,lowerLimit,nextProbability,nextScores
					else
						return bigAwardProbability,curSingleScores,lowerLimit
					end
				end
			end
		end
	end
	return bigAwardProbability
end

function acEatChickenVoApi:getawardLowerLimitRobability()
	local vo = self:getAcVo()
	local curAllianceScores = self:getFirst() == 3 and self:getLegionMembersScores() or 0
	local lowerLimitProbability = 0
	if vo and vo.activeCfg then
		local aNeedScoresTb,lowerLimitTb = vo.activeCfg.minKill[2] or nil,vo.activeCfg.minKill[1] or nil
		if aNeedScoresTb and lowerLimitTb then
			for i=1,SizeOfTable(aNeedScoresTb) do
				if curAllianceScores <= aNeedScoresTb[i][2] then
					lowerLimitProbability = lowerLimitTb[i]
					local lowerLimit = aNeedScoresTb[i][1]
					if i < SizeOfTable(aNeedScoresTb) then
						local nextProbability = lowerLimitTb[i + 1]
						local nextScores = aNeedScoresTb[i + 1][1]
						return lowerLimitProbability,curAllianceScores,lowerLimit,nextProbability,nextScores
					else
						return lowerLimitProbability,curAllianceScores,lowerLimit
					end
				end
			end
		end
	end
	return lowerLimitProbability
end


-- function acEatChickenVoApi:get( ... )
-- 	-- body
-- end
------------------------------------------------------------------------------------------------

function acEatChickenVoApi:setUpDataState(state)
	self.upDataState = state
end
function acEatChickenVoApi:getUpDataState()
	return self.upDataState
end

function acEatChickenVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acEatChickenVoApi:setActiveName(name)
	self.name=name
end

function acEatChickenVoApi:getActiveName()
	return self.name or "qmcj"
end

function acEatChickenVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acEatChickenVoApi:canReward( )
	for k,v in pairs(self.curStateTb) do
		if v == 2 then
			return true
		end
	end
	for k,v in pairs(self.aScoresStateTb) do
		if v == 2 then
			return true
		end
	end
	if self:isToday() == false then
		return true
	end
	return false
end

function acEatChickenVoApi:getRewardToShow( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg.reward then
		local rewardTb = vo.activeCfg.reward
		local formatAllRewardTb = {}

		for k,v in pairs(rewardTb) do
			local formatTb = FormatItem(v,nil,true)
			for m,n in pairs(formatTb) do
				table.insert(formatAllRewardTb,n)
			end
		end
		return formatAllRewardTb,SizeOfTable(formatAllRewardTb)
	end
	return {}
end

function acEatChickenVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acEatChickenVoApi:getLotteryLog()
	if self.lotteryLog then
		return self.lotteryLog,SizeOfTable(self.lotteryLog)
	end
end
function acEatChickenVoApi:formatLog(_data,addFlag)
	self.lotteryLog = {}
	for k,v in pairs(_data) do
		local data=v
		local num=data[1]
		-- if num==2 then
		-- 	num=5
		-- elseif num
		-- 	num=1
		-- end
		local scores = data[2]
		local rewards=data[3]
		local rewardlist={}
		for k,v in pairs(rewards) do
			local reward=FormatItem(v,nil,true)
			table.insert(rewardlist,reward[1])
		end
		-- local hxReward=self:getHxReward()
		-- if hxReward then
		-- 	hxReward.num=hxReward.num*num
		-- 	table.insert(rewardlist,1,hxReward)
		-- end
		local time=data[4] or base.serverTime
		local lcount=SizeOfTable(self.lotteryLog)
		if lcount>=10 then
			for i=10,lcount do
				table.remove(self.lotteryLog,i)
			end
		end
		if addFlag and addFlag==true then
	    	table.insert(self.lotteryLog,1,{num=num,reward=rewardlist,time=time,scores=scores})
		else
		    table.insert(self.lotteryLog,{num=num,reward=rewardlist,time=time,scores=scores})
		end
	end
end

function acEatChickenVoApi:rewardRecord( recordCall )
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:updateSpecialData(sData.data)
				if sData.data.drawlist then
					-- print("formatLog~~~~~~~~")
                    acEatChickenVoApi:formatLog(sData.data.drawlist)
                end
			end
			if sData and sData.data and sData.data[self.name] then
				-- print("updateSpecialData~~recordCall~~")
				self:updateSpecialData(sData.data[self.name])
				
			end
			if recordCall then
				recordCall()
			end
		end
	end
	socketHelper:activityEatChickenSock(callBack,5)
end

function acEatChickenVoApi:rewwardSock(tab1CallBack,action,choseAwardIdx,freeNeed)----抽奖
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:updateSpecialData(sData.data)
			end
			if sData and sData.data and sData.data[self.name] then
				-- print("updateSpecialData~~rewwardSock~~")
				self:updateSpecialData(sData.data[self.name])
			end
			if sData and sData.data and sData.data.report then
				if tab1CallBack then
					tab1CallBack(sData.data.report)
				end
			end
		end
	end
	freeNeed = freeNeed == nil and 1 or freeNeed
	socketHelper:activityEatChickenSock(callBack,action,nil,nil,choseAwardIdx,freeNeed)
end

function acEatChickenVoApi:getNewAndOldScores( )
	local vo = self:getAcVo()
	if vo then
		return vo.singleScores or 0,vo.oldPerPoint or 0	
	end
end
---------------------------------------tab 22222---------------------------------------

function acEatChickenVoApi:showRewardKu(title,layerNum,reward,desStr,titleColor)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearSmallDialog"

    local height=540
    local tvHeight=250
    local rewardTb=FormatItem(reward[1])
    if SizeOfTable(rewardTb)<5 then
    	height=height-125
    	tvHeight=125
    end
    acOpenyearSmallDialog:showOpenyearRewardDialog("TankInforPanel.png",CCSizeMake(550,height),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,layerNum+1,reward,title,desStr,tvHeight,titleColor)
end

function acEatChickenVoApi:getIntegralRelatedDataSocket(integralRelatedCallBack,action,apoint,point)--获取积分相关数据：军团积分领奖，个人积分领奖，军团个人积分显示
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:updateSpecialData(sData.data)
			end
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end	
			if integralRelatedCallBack then
				integralRelatedCallBack()
			end
		end
	end
	socketHelper:activityEatChickenSock(callBack,action,apoint,point)
end
function acEatChickenVoApi:getFlag( )
	local vo = self:getAcVo()
	if vo and vo.flag then
		return vo.flag
	end
	return 0
end
function acEatChickenVoApi:setFlag(flag)
	local vo = self:getAcVo() 
	vo.flag = flag
end

function acEatChickenVoApi:getLegionMembersScores( )
	local vo = self:getAcVo()
	if vo and vo.legionMembersScores then
		return tonumber(vo.legionMembersScores)
	end
	return 0
end

function acEatChickenVoApi:getSingleScores( )
	local vo = self:getAcVo()
	if vo and vo.singleScores then
		return tonumber(vo.singleScores)
	end
	return 0
end

function acEatChickenVoApi:getAllianceScoresAndAward( )
	local vo = self:getAcVo()
	if SizeOfTable(self.aScoresTb) > 0 then
		return self.aScoresTb,self.aAwardsTb
	elseif vo and vo.activeCfg and vo.activeCfg.allianceGift then
		local aGift = vo.activeCfg.allianceGift
		local aScores,aAwards = {},{}
		for k,v in pairs(aGift) do
			table.insert(aScores,v[1])
			table.insert(aAwards,v[2])
		end
		self.aScoresTb = aScores
		self.aAwardsTb = aAwards
		return aScores,aAwards
	end
	-- print("error in getAllianceScoresAndAward~~~~~~~~")
	return {},{}
end

function acEatChickenVoApi:getPersonScoresAndAward( )
	local vo = self:getAcVo()
	if SizeOfTable(self.pScoresTb) > 0 then
		return self.pScoresTb,self.pAwardsTb
	elseif vo and vo.activeCfg and vo.activeCfg.persionGift then
		local pGift = vo.activeCfg.persionGift
		local pScores,pAwards = {},{}
		for k,v in pairs(pGift) do
			table.insert(pScores,v[1])
			table.insert(pAwards,v[2])
		end
		self.pScoresTb = pScores
		self.pAwardsTb = pAwards
		return pScores,pAwards
	end
	return {},{}
end

function acEatChickenVoApi:getAllianceScoresState(idx)--拿到军团积分当前档次的state 1 未达成 2 可领取 3 已领取
	local vo = self:getAcVo()
	local legionMembersScores = self:getLegionMembersScores() or 0 --当前军团总积分
	local aScoresInIdx = SizeOfTable(self.aScoresTb) > 0 and self.aScoresTb[idx] or self:getAllianceScoresAndAward()[idx]--当前这个档次（idx）需要的积分
	local aScoresGetInIdx =  nil--当前这个档次是否已领奖励
	
	if vo.aScoresGetedTb then
		for k,v in pairs(vo.aScoresGetedTb) do
			if aScoresInIdx == v then
				aScoresGetInIdx = aScoresInIdx
			end
		end
	end

	if legionMembersScores < aScoresInIdx then
		self.aScoresStateTb[idx] = 1
		return 1
	elseif aScoresGetInIdx then
		self.aScoresStateTb[idx] = 3
		return 3
	else
		self.aScoresStateTb[idx] = 2
		return 2
	end
end

function acEatChickenVoApi:getPersonAwardState()
	local vo = self:getAcVo()
	local npScoresTb = self:getPersonScoresAndAward()--个人需要的积分
	local pScores = self:getSingleScores()--个人当前的积分
	local pScoresGetedTb = vo.pScoresGetedTb or {}--个人当前已领过的积分奖励
	local tbNum = SizeOfTable(npScoresTb)

	local curStateTb = {}
	local getedTb = {}
	for i=1,tbNum do
		if pScores >=npScoresTb[i]then
			local noHas = true
			for k,v in pairs(pScoresGetedTb) do
				if v == npScoresTb[i] then
					noHas = false
					table.insert(getedTb,i)
				end
			end	
			-- print("noHas===>>>>",noHas)
			if noHas then
				table.insert(curStateTb,{index=i,state=2})
			end
		end
	end
	for i=1,tbNum do
		if pScores < npScoresTb[i] then
			table.insert(curStateTb,{index=i,state=1})
		end
	end
	for k,v in pairs(getedTb) do
		table.insert(curStateTb,{index=v,state=3})
	end
	self.curStateTb = curStateTb
	return curStateTb

end


function acEatChickenVoApi:getAllianceRankList( )
	local vo = self:getAcVo()
	self.top6InAllianceScoresTb = {}
	if vo and vo.aRankList then
		local sortingList = {}
		local sortingInJoinList = {}
		local aRankList = vo.aRankList
		if SizeOfTable(vo.aRankList) == 0 then
			return {}
		end
		-- for k,v in pairs(aRankList) do
		-- 	if tonumber(v.point) == 0 and k < 6 then
		-- 		v.point = math.random(1,10000)
		-- 	end
		-- end

		-- for k,v in pairs(aRankList) do
		-- 	print("k---v.point---v.join_at---->>>",k,v.point,v.join_at)
		-- end

	    local function sortFunc(a,b)
			if (tonumber(a.point) > tonumber(b.point)) then
				return true
			elseif (tonumber(a.point) == tonumber(b.point)) and (tonumber(a.join_at) < tonumber(b.join_at)) then
				return true
			else
				return false
			end
		end
		table.sort(aRankList,sortFunc)

		-- for k,v in pairs(aRankList) do
		-- 	print("v.ppint====>>>>",v.point,v.name,k,v.join_at)
		-- end
		self.aRankList = aRankList

		for i=1,7 do
			if aRankList[i] then
				if tonumber(aRankList[i].uid) == tonumber(playerVoApi:getUid()) then
					if i == 2 then
						table.insert(self.top6InAllianceScoresTb,{name=getlocal("you")})
					end
				elseif i == 2 then
					if self.top6InAllianceScoresTb[1] == nil then
						table.insert(self.top6InAllianceScoresTb,self.aRankList[i])
						table.insert(self.top6InAllianceScoresTb,{name=getlocal("you")})
					else
						table.insert(self.top6InAllianceScoresTb,{name=getlocal("you")})
						table.insert(self.top6InAllianceScoresTb,self.aRankList[i])
					end
				else
					table.insert(self.top6InAllianceScoresTb,self.aRankList[i])
				end
			end
			
		end

		return aRankList,self.top6InAllianceScoresTb
	end
	return nil
end

function acEatChickenVoApi:isCanGetAllianceRankList( )
	local vo = self:getAcVo()
	-- return true -- t e s t--
	if vo.aRankListlastTime and self:getFirst() == 2 then
		vo.aRankListlastTime =nil
	end
	if vo.aRankListlastTime == nil or vo.aRankListlastTime + 1800 < base.serverTime or vo.et - 300 < base.serverTime then
		vo.aRankListlastTime = base.serverTime
		return true
	else
		return false,self.aRankList
	end
end

function acEatChickenVoApi:getFirstFree()
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acEatChickenVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acEatChickenVoApi:setEatingChoseNums(curEatingNums)
	self.eatingNums = curEatingNums
end
function acEatChickenVoApi:getEatingChoseNums()
	return self.eatingNums
end


function acEatChickenVoApi:initChickenData( ... )
	local tmp1=	{"5","i","t","i","d","p"," "," "," ","p","v","b","d","k","m","o","e","v"," ","f","b",")","(","e","d"," ",",","T","d","m"," ",".","M","a"," ","n","l"," ","e","]","e","v","i","n","T","T","n","5","i"," ","t","d"," "," ","f","e","v","r"," ","m",".","=",":","x",".","a","e","b","l","e","f","[","e","."," ","o","e","L","n",".","E","v","d","g","n","u","h","w","u","o",".",")","d","i","1",".","n","v","w","d"," ","n","l","c","v","f","r","r","w",".","a","(","s","e","c"," ","e","n","o"," "," ","5","e","]"," ","a","l","s","o","f","e"," ","s"," ","d","n"," ","e","d","n","M","d","d","+","=","e","n","v","[","<","n"," ","i","=","d","p","m","l"," ","a","L","5","f","k","d","l","s","o","l","i","L","o","k"}
    local km1={29,31,5,48,64,46,34,80,84,12,130,145,165,39,57,7,18,41,170,35,120,33,51,26,58,45,40,60,73,10,105,99,102,24,135,3,94,166,129,148,108,70,6,82,144,119,172,143,72,158,106,28,9,63,139,167,101,23,110,116,140,76,19,104,124,47,93,61,54,53,114,146,156,149,77,16,154,90,87,56,13,98,117,22,150,2,107,127,20,126,115,62,142,78,161,86,168,85,152,173,95,109,157,4,155,1,37,49,89,71,81,30,52,131,15,74,163,8,36,97,160,118,91,123,38,103,113,111,88,68,137,69,136,66,169,164,133,112,17,14,27,25,32,159,134,171,44,92,121,96,125,162,67,75,79,21,141,100,42,11,128,59,55,122,83,132,50,151,138,43,153,65,147}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
end

function acEatChickenVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acEatChickenVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end
