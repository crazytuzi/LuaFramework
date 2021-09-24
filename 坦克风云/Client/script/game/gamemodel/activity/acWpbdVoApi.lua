acWpbdVoApi={
	name=nil,
	rewardLog={}
}
function acWpbdVoApi:clearAll()
	self.name = nil
	self.rewardLog=nil
end
function acWpbdVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acWpbdVoApi:setActiveName(name)
	self.name=name
end

function acWpbdVoApi:getActiveName()
	return self.name or "wpbd"
end

function acWpbdVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acWpbdVoApi:canReward( )
	if self:getFirstFree() == 0 or self:isToday() == false then
		return true
	end
	if self:canExchange() then
		return true
	end
	return false
end

function acWpbdVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acWpbdVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		if vo.firstFree == 1 then
			if not self:isToday() then
				return 0 
			end
		end
		return vo.firstFree
	end
	return 1
end
function acWpbdVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acWpbdVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acWpbdVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end

function acWpbdVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acWpbdVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1
end

---------------------------------------- t a b 1 ----------------------------------------
function acWpbdVoApi:warningShow(idx)--警告飘板 1 免费
	local showStr = getlocal("curStatus")

	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,28)
end
function acWpbdVoApi:setMultiNum(newMulti)--跨天 强制 改为默认选项(无参数调用)
	local vo = self:getAcVo()
	vo.multiNum = newMulti or 1
end

function acWpbdVoApi:getMultiNum( )
	local vo = self:getAcVo()
	return vo.multiNum or 1
end

function acWpbdVoApi:setNowChecked(newCheck)
	local vo = self:getAcVo()
	vo.nowChecked = newCheck or nil
end

function acWpbdVoApi:getNowChecked( )---勾选哪一组
	local vo = self:getAcVo()
	return vo.nowChecked or nil
end

function acWpbdVoApi:getRewardTb( )

	local vo = self:getAcVo()
	if vo.isFirstReward then
		local rewardPool=FormatItem(vo.rewardTb[1],nil,true) or {}
		return rewardPool
	else
		local showAwardData = vo.rewardTb
		local newRewardPool = {}
		newRewardPool.o={}
		for k,v in pairs(showAwardData) do
			local tankaId = Split(v[1],"_")[2]
			newRewardPool.o[k]          = {}
			newRewardPool.o[k][tankaId] = v[2]
			newRewardPool.o[k].index    = k
		end
		local rewardPool=FormatItem(newRewardPool,nil,true) or {}
		return rewardPool
	end
end

function acWpbdVoApi:getBeiShuTb()
	local vo = self:getAcVo()
	local mNum = self:getMultiNum()

	if vo.rateShow  and vo.rateShow[mNum] then
		return vo.rateShow[mNum]
	else
		print "error in getBeiShuTb()~~~~~~~~~~~~~!!!!!!!"
		return {}
	end
end

function acWpbdVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg and acVo.activeCfg.hxcfg then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

function acWpbdVoApi:getAwardScore(idx )--抽奖返回的积分，只对应 普通 高级 两种，没有乘积
	local acVo = self:getAcVo()
	if acVo and acVo.awardScoreTb and idx then
		return acVo.awardScoreTb[idx]
	end
	print(" in getAwardScore~~~~~~~~~ idx is nil??",idx)
	return 0
end
function acWpbdVoApi:getLockCostTb(idx)-- 锁定区域需要添加的金币数
	local acVo = self:getAcVo()
	if acVo and acVo.lockCostTb and idx then
		return acVo.lockCostTb[idx]
	end
	print("in getLockCostTb~~~~~~~~ idx is nil???",idx)
end
function acWpbdVoApi:getCostGems(isFree)
	if not isFree then
		local acVo = self:getAcVo()
		local multiNum = self:getMultiNum()
		local nowChecked = self:getNowChecked()
		local costNum = acVo.costTb[multiNum] or 0
		if nowChecked then
			costNum = costNum + self:getLockCostTb(nowChecked)
		end
		return costNum,multiNum,nowChecked or 0
	else
		return nil
	end
end


function acWpbdVoApi:acWpbdAwardRequest(sockStr,args,callback)
	local useNum = args.num or 1
	local oldAllScore = self:getAllScore()
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				local awardTime = base.serverTime
				local getRate,getScore = sData.data.rate or 0,0
				local getPool = sData.data.pool
				if sData.data.wpbd then
					getScore = sData.data.wpbd.v - oldAllScore
                    self:updateSpecialData(sData.data.wpbd)
					if sData.ts then
						awardTime = sData.ts
					end
				end
				local rewardlist={}
				local num=useNum
				local hxReward
				local rewardId = 0
				if sData.data.reward then --奖励
					local rewards=sData.data.reward
				
					local reward=FormatItem(rewards,nil,true)[1]
					rewardId =reward.id
					table.insert(rewardlist,reward)
					G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
						
					hxReward=self:getHexieReward()
					if hxReward then
						hxReward.num=hxReward.num*num
						table.insert(rewardlist,1,hxReward)
						G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
					end
					if self.rewardLog then
						local awardInfoTb = {}
						awardInfoTb[1] = useNum
						awardInfoTb[2] = sData.data.reward
						-- awardInfoTb[3] = point 
						awardInfoTb[3] = awardTime
						self:formatLog(awardInfoTb,true)
					end
				end
				
				if sData.data.log then --日志
					self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end
				end

				if sockStr == "reward" then
					callback(rewardlist,hxReward,getRate,getScore,rewardId,getPool)				
				elseif callback then
					callback()
				end
			end
		end
	end
	socketHelper:acWpbdRequest(sockStr,args,requestHandler)
end

--格式化抽奖记录
function acWpbdVoApi:formatLog(data,addFlag,curAddScore)
	local num=data[1]--倍数
	local rewards=data[2]
	local rewardlist={}

	table.insert(rewardlist,FormatItem(rewards,nil,true)[1])

	local hxReward=self:getHexieReward()
	if hxReward then
		hxReward.num=hxReward.num*num
		table.insert(rewardlist,1,hxReward)
	end
	local time=data[3] or base.serverTime
	-- local point=data[3] or 0
	local lcount=SizeOfTable(self.rewardLog)
	if lcount>=10 then
		for i=10,lcount do
			table.remove(self.rewardLog,i)
		end
	end
	if addFlag and addFlag==true then
    	table.insert(self.rewardLog,1,{num=num,reward=rewardlist,time=time})
	else
	    table.insert(self.rewardLog,{num=num,reward=rewardlist,time=time})
	end
end

function acWpbdVoApi:getRewardLog()
	return self.rewardLog
end

function acWpbdVoApi:showRewardSmallPanel(layerNum,showTb,getRate,getScore,callback)
	local titleStr = getlocal("activity_wheelFortune4_reward")--activity_qmcj_RewardStr
	local titleStr2= getlocal("rateAward",{getRate}).." "..getlocal("scoreAdd",{getScore})
	-- local addStrTb = 
    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
    rewardShowSmallDialog:showNewReward(layerNum+1,true,true,showTb,callback,titleStr,titleStr2,nil,nil,"wpbd",G_ColorYellow)
end

function acWpbdVoApi:getCurRateInLog(reward)
	local acVo = self:getAcVo()
	if reward and reward.type == "o" then
		local reId,reNum = reward.id,reward.num
		local poolTb = acVo.poolRewardTb or {}
		for i=1,(SizeOfTable(poolTb)-1) do--因为多了一个firstpool 所以需要减1
			if poolTb["pool"..i] then
				local oTb = poolTb["pool"..i].o or {}
				for k,v in pairs(oTb) do
					for m,n in pairs(v) do
						if "a"..reId == m then
							return math.floor(reNum/n)
						end
					end
				end
			end
		end
	else
		print "error ~~~~~~~~~~ in getCurRateInLog!!!!!!! "
	end
end
---------------------------------------- t a b 2 ----------------------------------------

function acWpbdVoApi:getAllScore( )--总积分
	local vo = self:getAcVo()
	if vo and vo.allScore then
		return vo.allScore
	end
	return 0
end
function acWpbdVoApi:getCurCostNum( )--tab1 当前抽奖的次数
	local vo = self:getAcVo()
	if vo and vo.costNum then
		return vo.costNum
	end
	return 0 
end
function acWpbdVoApi:setSelfCurExchangeData(newScore,newCostNum,newExchangeTb)
	local vo = self:getAcVo()
	if vo then	
		vo.allScore,vo.costNum,vo.exchangeTb = newScore,newCostNum,newExchangeTb
	end
end
function acWpbdVoApi:getSelfCurExchangeData()--自己当前兑换的条件信息 积分，转盘的次数，已购买的表
	local vo = self:getAcVo()
	if vo then
		return vo.allScore or 0,vo.costNum or 0,vo.exchangeTb or {}
	end
	return 0,0,{}
end
function acWpbdVoApi:getNeedAwardAndFactorTb()--兑换 奖励表，所有条件的表--积分，转盘的次数，购买上限
	local vo = self:getAcVo()
	if vo and vo.factorTb then
		return G_clone(vo.factorTb)
	end
	return nil
end

function acWpbdVoApi:arrayShowTb( )--排列 需要再次确认
	local allScore,costNum,curExchangeTb = self:getSelfCurExchangeData()
	local AwardAndFatorTb = self:getNeedAwardAndFactorTb()
	local newTb = {}
	local unScoreTb,unBuyTimeTb,exchangeLimitTb = {},{},{}
	local lastTb = {}
	local isHasExchange = false
	local oidIdBigger4 = false
	for k,v in pairs(AwardAndFatorTb) do-- state : 0 可兑换 1 : 积分不足 2 ：达到上限 3 ： 抽奖次数不足
		v.oldId = k
		v.curExchangeNum = curExchangeTb["i"..v.oldId] or 0
		if v.curExchangeNum >= v.limitNum then
			v.state = 2
			table.insert(exchangeLimitTb,v)
		elseif allScore >= v.p and costNum >= v.costNum and v.curExchangeNum < v.limitNum then
			isHasExchange = true
			v.state = 0
			if v.oldId < 5 then
				oidIdBigger4 =true
			end
			table.insert(newTb,v)
		elseif allScore < v.p then
			v.state = 1
			table.insert(unScoreTb,v)
		elseif costNum < v.costNum then
			v.state = 3 
			table.insert(unBuyTimeTb,v)
		end
	end
	for k,v in pairs(unBuyTimeTb) do
		table.insert(newTb,v)
	end

	for k,v in pairs(unScoreTb) do
		table.insert(newTb,v)
	end
	
	for k,v in pairs(exchangeLimitTb) do
		table.insert(newTb,v)
	end
	for k,v in pairs(lastTb) do
		table.insert(newTb,v)
	end
	return newTb,SizeOfTable(newTb),isHasExchange,oidIdBigger4
end

function acWpbdVoApi:canExchange( )
	local nilData,nilData,nilData,oidIdBigger4 = self:arrayShowTb()
	return oidIdBigger4 
end

function acWpbdVoApi:showTipDia(tabNum,layerNum)
	require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
	if tabNum == 1 then
		local tabStr = {}
        table.insert(tabStr,getlocal("activity_wpbd_tab1_tip1"))
        table.insert(tabStr,getlocal("activity_wpbd_tab1_tip2"))
        table.insert(tabStr,getlocal("activity_wpbd_tab1_tip3"))
        table.insert(tabStr,getlocal("activity_wpbd_tab1_tip4"))
        table.insert(tabStr,getlocal("activity_wpbd_tab1_tip5"))
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        local textSize = 25
        tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,textSize)
	elseif tabNum == 2 then
		local tabStr = {}
        table.insert(tabStr,getlocal("activity_wpbd_tab2_tip1"))
        table.insert(tabStr,getlocal("activity_wpbd_tab2_tip2"))
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        local textSize = 25
        tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,textSize)
	else

	end
end


------------------------------ 自 身 车 库 坦 克 兑 换 积 分 ------------------------------

function acWpbdVoApi:getSelfAllTank( )
	local vo = self:getAcVo()
	local allTankTb=tankVoApi:getAllTanks()
	local canExTb = {}
	local unExTb = {}
	local selfIsZeroTb = {}
	-- print("vo.exchangedSelfTankTb=====>>>Num:",SizeOfTable(vo.exchangedSelfTankTb))
	local canExchangeSelfTankTb = G_clone(vo.canExchangeSelfTankTb)
	if canExchangeSelfTankTb then
		for k,v in pairs(canExchangeSelfTankTb) do
			v.curExNum = vo.exchangedSelfTankTb["e"..v.id] or 0
			local canExTankId = v.tid	
			if v.curExNum >= v.limitNum then
				if allTankTb[canExTankId] and allTankTb[canExTankId][1] ~= 0 then
					v.tankCurNum = allTankTb[canExTankId][1]
				else
					v.tankCurNum = 0
				end
				v.unEx = true
				table.insert(unExTb,v)
			elseif allTankTb[canExTankId] and allTankTb[canExTankId][1] ~= 0 then
				v.tankCurNum = allTankTb[canExTankId][1]
				table.insert(canExTb,v)
			elseif v.curExNum > 0 then
				v.tankCurNum = 0
				v.unEx = true
				table.insert(selfIsZeroTb,v)
			end
		end
		for k,v in pairs(selfIsZeroTb) do
			table.insert(canExTb,v)
		end
		for k,v in pairs(unExTb) do
			table.insert(canExTb,v)
		end
	else
		print " error~~~~~~~~ in getSelfAllTank hasn't tankTb!!!!!"
	end
	return canExTb
end

function acWpbdVoApi:exchangeSelfTankSocket(socketSuccCall,choseId,choseExNum,itemId)
	local function requestHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                if sData.data.wpbd then
                	tankVoApi:addTank(itemId,-choseExNum,true)
                    self:updateSpecialData(sData.data.wpbd)

                    if socketSuccCall then
                    	socketSuccCall()
                    end
                end
            end
        end
    end
    local params = {id=choseId,num=choseExNum}
    socketHelper:acWpbdRequest("exchange",params,requestHandler)
end