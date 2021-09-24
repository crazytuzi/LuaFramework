acYrjVoApi={
	name        = nil,
	rewardLog   = nil,
	rechargeLog = nil,
	rcLog       = nil,
	poolAwardTb = nil,
	hasNewRechargeTip = false,
}
function acYrjVoApi:clearAll()
	self.name        = nil
	self.rewardLog   = nil
	self.rechargeLog = nil
	self.rcLog       = nil
	self.poolAwardTb = nil
	self.hasNewRechargeTip = false
end
function acYrjVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acYrjVoApi:getVersion( ... )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.version then
		return vo.activeCfg.version
	else
		return 1
	end
end
function acYrjVoApi:getSpecialProp()
	local version = self:getVersion()
	if version == 1 then
		return getlocal("activity_yrj_clownStr")
	elseif version == 2 then
		return getlocal("activity_yrj_specialPropV2")
	else
		return getlocal("activity_yrj_clownStr")
	end
end
function acYrjVoApi:setActiveName(name)
	self.name=name
end

function acYrjVoApi:getActiveName()
	return self.name or "yrj"
end

function acYrjVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end
function acYrjVoApi:getLimit( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg.levelLimit then
		return vo.activeCfg.levelLimit
	end
	return 100
end
function acYrjVoApi:canReward( )
	if self:getFirstFree() == 0 or self:isToday() == false then
		return true
	end
	return false
end

function acYrjVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acYrjVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end

function acYrjVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acYrjVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end
function acYrjVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acYrjVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acYrjVoApi:setRechargeTip(hasNew,newLog)
	local vo = self:getAcVo()
	if hasNew == true then
		acYrjVoApi:formatRechargeLog(newLog,true )
	end
	-- print("hasNew------>>>>>>",hasNew)
	self.hasNewRechargeTip = hasNew
	vo.hasNewRechargeTip = hasNew
end
function acYrjVoApi:getRechargeTip( )
	local vo = self:getAcVo()
	return self.hasNewRechargeTip
end

------------------- t a b 1 -------------------
function acYrjVoApi:getRechargeSendShown( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.rechargeReward and vo.activeCfg.rechargeReward.ac and vo.activeCfg.rechargeReward.ac[self:getSpecialPropId()] then
		return vo.activeCfg.rechargeReward.ac[self:getSpecialPropId()]
	end
	return 1 
end
function acYrjVoApi:getRechargeNum( )
	local vo = self:getAcVo()
	if vo and vo.rechargeNeed then
		return tonumber(vo.rechargeNeed)
	end
	return 100000
end

function acYrjVoApi:needRechargeNum( )--再充值金币数
	local vo = self:getAcVo()
	if vo and vo.needRechargeNum then
		return tonumber(vo.needRechargeNum)
	end
	return 100000
end

function acYrjVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg and acVo.activeCfg.hxcfg then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

function acYrjVoApi:getLotteryCost()
	local cost1,cost2=0,0
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		cost1=vo.activeCfg.cost
		cost2=vo.activeCfg.cost5
	end
	return cost1,cost2
end

function acYrjVoApi:getMultiNum()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.mul or 5
	end
	return 5
end

function acYrjVoApi:getRewardPool()
	local acVo=self:getAcVo()
	local awardFormatTb = {}
	if self.poolAwardTb == nil or SizeOfTable(self.poolAwardTb) == 0 then
		if acVo and acVo.activeCfg and acVo.activeCfg.reward then
				self.poolAwardTb = FormatItem(acVo.activeCfg.reward[1],nil,true)
		end
	end

	return self.poolAwardTb
end

function acYrjVoApi:acYrjRequest(sockStr,args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				local awardTime = base.serverTime
				if sData.data.yrj then
                    self:updateSpecialData(sData.data.yrj)

					if sData.ts then
						awardTime = sData.ts
					end
				end
				local rewardlist={}
				local num=1
				local hxReward
				local curAddScore = 0--当前抽奖获得小丑数量
				if sData.data.reward then --奖励
					num= SizeOfTable(sData.data.reward)
					local rewards=sData.data.reward
					
					for k,v in pairs(rewards) do
						if v.ac then
							reward = {}
							reward.name,reward.desc,reward.num,reward.type,reward.etype,reward.pic = self:getSpecialProp(),getlocal("activity_yrj_clownDes"),v.ac[self:getSpecialPropId()],"ac","ac",self:getSpecialPropPic()
							curAddScore = curAddScore + v.ac[self:getSpecialPropId()]
							-- print("当前抽奖获得小丑数量====>>>curAddScore:",curAddScore)
							table.insert(rewardlist,reward)
						else
							local reward=FormatItem(v,nil,true)[1]
							table.insert(rewardlist,reward)
							G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
						end
					end
					hxReward=self:getHexieReward()
					if hxReward then
						hxReward.num=hxReward.num*num
						G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
					end
					if self.rewardLog then
						local awardInfoTb = {}
						awardInfoTb[1] = num
						awardInfoTb[2] = sData.data.reward
						-- awardInfoTb[3] = point 
						awardInfoTb[4] = awardTime
						self:formatLog(awardInfoTb,true,curAddScore)
					end
				end
				
				if sData.data.log then --日志
					self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end
				end

				if sData.data.rlog then
					self.rechargeLog = {}
					for i=1,SizeOfTable(sData.data.rlog) do
						local aLog = sData.data.rlog[i]
						self:formatRechargeLog(aLog)
					end
				end
				if sockStr == "draw" then
					callback(curAddScore,rewardlist,hxReward)				
				elseif callback then
					callback()
				end
			end
		end
	end
	socketHelper:acYrjRequest(sockStr,args,requestHandler)
end

function acYrjVoApi:formatRechargeLog(data,addFlag )--activity_yrj_tab1_logTab2_Tip
	local formatTb = {}
	formatTb[1] = G_getDataTimeStr(data[3])
	formatTb[2] = data[2] == 0 and getlocal("activity_yrj_tab1_logTab3_Tip",{data[1]}) or getlocal("activity_yrj_tab1_logTab2_Tip",{data[1],data[2],acYrjVoApi:getSpecialProp()})
	if not self.rechargeLog then
		self.rechargeLog = {}
	end
	local lcount=SizeOfTable(self.rechargeLog)
	if lcount>=10 then
		for i=10,lcount do
			table.remove(self.rechargeLog,i)
		end
	end
	if addFlag then
		table.insert(self.rechargeLog,1,formatTb)
	else
		table.insert(self.rechargeLog,formatTb)
	end
end
--格式化抽奖记录
function acYrjVoApi:formatLog(data,addFlag,curAddScore)
	local num=data[1]
	local rewards=data[2]
	local rewardlist={}
	for k,v in pairs(rewards) do
		local reward = {}
		if v.ac then
			reward[1] = {}
            reward[1].num = v.ac[self:getSpecialPropId()]
            reward[1].type = "ac"
        else
			reward=FormatItem(v,nil,true)
		end
		table.insert(rewardlist,reward[1])
	end
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

function acYrjVoApi:getRewardLog()
	return self.rewardLog
end

function acYrjVoApi:getReLog( )
	return self.rechargeLog
end

function acYrjVoApi:getSpecialPropPic( ... )
	local version = self:getVersion()
	if version == 1 then
		return "clownIcon.png"
	elseif version == 2 then
		return "lucky_star.png"
	else
		return "clownIcon.png"
	end
end

-----------------------------------------------
------------------- t a b 2 -------------------
function acYrjVoApi:getScoreItem(iconSize,bgSize,awardNum)
	local scoreItem = {}
	scoreItem.num = awardNum or self:getCurScoreNum()
	scoreItem.name = self:getSpecialProp()
	scoreItem.desc = "activity_yrj_clownDes"
	scoreItem.icon = self:getSpecialPropPic()
	scoreItem.iconBg = "Icon_BG.png"
	scoreItem.iconSize = iconSize or 65
	scoreItem.bgSize   = bgSize or 60
	scoreItem.universal = true
	return scoreItem
end


function acYrjVoApi:getCurScoreNum( )
	local vo = self:getAcVo()
	if vo and vo.curScoreNum then
		return vo.curScoreNum 
	end
	return 0
end

function acYrjVoApi:getExchangeTb( )--后台配置
	local vo = self:getAcVo()
	if vo and vo.exchangeTb then
		return vo.exchangeTb
	end
	return {}
end

function acYrjVoApi:getExchangedTb( )--已兑换
	local vo = self:getAcVo()
	if vo and vo.exchangedTb then
		return vo.exchangedTb
	end
	return {}
end
function acYrjVoApi:getVersion( ... )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.version then
		return vo.activeCfg.version
	else
		return 1
	end
end
function acYrjVoApi:CanExrechargeBigAward( )

	local curScoreNum,excTb = self:getCurScoreNum(),self:getExchangeTb()
	for i=1,4 do
		if excTb[i].price[self:getSpecialPropId()] <= curScoreNum and (excTb[i].state and excTb[i].state == 0) then
			return true
		end
	end
	return false
end

function acYrjVoApi:getSpecialPropId( ... )
	if self:getVersion() == 1 then
		return "m4"
	elseif self:getVersion() == 2 then
		return "m5"
	else
		return "m4"
	end
end

function acYrjVoApi:getFormatExTb( )
	local curScoreNum,excTb = self:getCurScoreNum(),self:getExchangeTb()
	local exchangedTb = self:getExchangedTb()
	local formatTb = {}
	local canExTb,cannotExTb,hadExTb = {},{},{}
	local exTbNum = SizeOfTable(excTb)
	for i=1,exTbNum do
		-- print("excTb[i].price.m4----->>>>>>>>",excTb[i].price.m4,curScoreNum)
		excTb[i].exchangedNum = exchangedTb["i"..i] or 0
		excTb[i].oldNum = i
		if exchangedTb["i"..i] and exchangedTb["i"..i] >= excTb[i].maxLimit then--已兑换
			excTb[i].state = 2
			table.insert(hadExTb,excTb[i])
		elseif curScoreNum >= excTb[i].price[self:getSpecialPropId()] then--可兑换
			excTb[i].state = 0
			table.insert(canExTb,excTb[i])
		else--未兑换
			excTb[i].state = 1
			table.insert(cannotExTb,excTb[i])
		end
	end
	for k,v in pairs(canExTb) do
		table.insert(formatTb,canExTb[k])
	end
	for k,v in pairs(cannotExTb) do
		table.insert(formatTb,cannotExTb[k])
	end
	for k,v in pairs(hadExTb) do
		table.insert(formatTb,hadExTb[k])
	end

	return formatTb,SizeOfTable(formatTb)
end

-------------------- e n d --------------------