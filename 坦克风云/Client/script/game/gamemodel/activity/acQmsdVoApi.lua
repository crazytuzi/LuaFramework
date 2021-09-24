acQmsdVoApi={
	name=nil,
	allRechargeRewardNeedGemsTb={},
	allRechargeRewardTb={},
	singleRechargeRewardTb = {},
	singleRechargeRewardNeedGemsTb = {},
	curSelfStateTb = {},
	curStateTb = {},
	upDataState = false,
	upDataState3 = false,
}
function acQmsdVoApi:clearAll()
	self.name = nil
	self.upDataState = nil
	self.upDataState3 = nil
	self.allRechargeRewardNeedGemsTb={}
	self.allRechargeRewardTb={}
	self.singleRechargeRewardTb = {}
	self.singleRechargeRewardNeedGemsTb = {}
	self.curSelfStateTb={}
	self.curStateTb={}
end
function acQmsdVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acQmsdVoApi:setActiveName(name)
	self.name=name
end

function acQmsdVoApi:getActiveName()
	return self.name or "qmsd"
end

function acQmsdVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end

function acQmsdVoApi:canReward( )

	-- if SizeOfTable(self.curStateTb) == 0 then
		self:getAllRechargeNumsState()
	-- end
	-- if SizeOfTable(self.curSelfStateTb) == 0 then
		self:getSingleRechargeNumsState()
	-- end

	for k,v in pairs(self.curStateTb) do
		if v["state"] == 2 then
			return true
		end
	end

	for k,v in pairs(self.curSelfStateTb) do
		if v["state"] == 2 then
			return true
		end
	end

	if self:isToday() == false or self:getFirstFree() == 0 then
		return true
	end

	return false
end

function acQmsdVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acQmsdVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1
end
function acQmsdVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acQmsdVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end
function acQmsdVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acQmsdVoApi:updateSpecialData(data)
	-- print(" in updateSpecialData~~~~~~")
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end
function acQmsdVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acQmsdVoApi:updateInServer(state,data)
	-- print(" in updateInServer~~~~~~")
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		self.upDataState = state
	end
end

function acQmsdVoApi:getLotteryLog()
	if self.lotteryLog then
		return self.lotteryLog,SizeOfTable(self.lotteryLog)
	end
end
function acQmsdVoApi:formatLog(_data,addFlag)
	self.lotteryLog = {}
	for k,v in pairs(_data) do
		local data=v
		local num=data[1]
		-- if num==2 then
		-- 	num=5
		-- elseif num
		-- 	num=1
		-- end
		-- local scores = data[2]
		local rewards=data[2]
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
function acQmsdVoApi:getRechargeRewardSocket(gotCallBack,cmdStr,action,limit,num,free)--领取充值礼包对应的奖励 action 1 个人 2 全服 limit 对应档位金币数
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateData(sData.data[self.name])
				self:updateSpecialData(sData.data[self.name])
			end	
			if sData.data.log then
				-- print("formatLog~~~~~~~~")
                self:formatLog(sData.data.log)
            end
			if gotCallBack then
				if sData and sData.data and sData.data.reward then
					gotCallBack(sData.data.reward,sData.data.rkeys)
				else
					gotCallBack()
				end
			end
		end
	end
	socketHelper:activityQmsdSock(callBack,cmdStr,action,num,free,limit)
end
------------ tab     1    ---------------
function acQmsdVoApi:getRewardToShow( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg.reward then
		local rewardTb = vo.activeCfg.reward
		local formatAllRewardTb = {}
		local formatSingleTb = {}
		for k,v in pairs(rewardTb) do
			local formatTb = FormatItem(v,nil,true)
			-- for m,n in pairs(formatTb) do
			-- 	table.insert(formatSingleTb,n)
			-- end
			-- print("SizeOfTable(formatTb)====>>>>>>",SizeOfTable(formatTb))
			table.insert(formatAllRewardTb,formatTb)
		end

		return formatAllRewardTb,SizeOfTable(formatAllRewardTb)
	end
	return {}
end


function acQmsdVoApi:addHeXieReward( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg then
		local cfg = vo.activeCfg
		local hxTb = cfg.hxcfg.reward or {}
		local hxReward = FormatItem(hxTb,nil,true)
		for k,v in pairs(hxReward) do
			v.num = v.num * 5
            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
        end
        local lihe = {p={["p3390"]=5,["index"]=1}}
        local formatLihe = FormatItem(lihe,nil,true)
        table.insert(hxReward,formatLihe[1])
		G_showRewardTip(hxReward)
	end
end
function acQmsdVoApi:getNeedGems( )
	local vo = self:getAcVo()
	local cfg = vo.activeCfg
	if cfg and cfg.cost then
		return tonumber(cfg.cost)
	end
	return 999
end

function acQmsdVoApi:setChrisBoxes(newChrisBoxes)
	local vo = self:getAcVo()
	if vo and newChrisBoxes then
		vo.chrisBoxes = newChrisBoxes
	end
end
function acQmsdVoApi:getChrisBoxes()
	local vo = self:getAcVo()
	if vo and vo.chrisBoxes then
		return tonumber(vo.chrisBoxes)
	end
	return 0
end


------------ tab     2    ---------------

function acQmsdVoApi:isGetIconFunc( )-- 1 已领取
	local vo = self:getAcVo()
	if vo and vo.isGetedIcon then
		return vo.isGetedIcon
	end
	return 0
end

function acQmsdVoApi:getHeadReward( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.headPicReward then
		local headReward = vo.activeCfg.headPicReward[1][2]
		local reward=FormatItem(headReward,nil,true)
		return reward,tonumber(vo.activeCfg.headPicReward[1][1])
	end
	return nil

end

function acQmsdVoApi:getSingleRechargeReward( )
	local vo = self:getAcVo()
	local num1 = self:getSingleRechargeNums( )
	local singleNums = tonumber(num1)
	local needGems = nil

	if SizeOfTable(self.singleRechargeRewardNeedGemsTb) == 0 then
		if vo and vo.activeCfg and vo.activeCfg.rechargeReward then
			local singleRechargeRewardTb = {}
			local singleRechargeRewardNeedGemsTb = {}
			for k,v in pairs(vo.activeCfg.rechargeReward) do
				table.insert(singleRechargeRewardNeedGemsTb,v[1])
				table.insert(singleRechargeRewardTb,v[2])
			end
			self.singleRechargeRewardTb = singleRechargeRewardTb
			self.singleRechargeRewardNeedGemsTb = singleRechargeRewardNeedGemsTb

			for k,v in pairs(self.singleRechargeRewardNeedGemsTb) do
				if v > singleNums then
					needGems = v - singleNums
					do break end
				end
			end

			return singleRechargeRewardNeedGemsTb,singleRechargeRewardTb,needGems
		end
		return {},{}
	else
		for k,v in pairs(self.singleRechargeRewardNeedGemsTb) do
			if v > singleNums then
				needGems = v - singleNums
				do break end
			end
		end

		return self.singleRechargeRewardNeedGemsTb,self.singleRechargeRewardTb,needGems
	end
end

function acQmsdVoApi:getSingleRechargeNums( )--拿到当前个人充值金额
	local vo = self:getAcVo()
	if vo and vo.selfRechargeNums then
		return vo.selfRechargeNums
	end
	return 0 
end
function acQmsdVoApi:setSingleRechargeNums(newRecharge)--目前应该只需要给跨天刷新使用（不需传newRecharge)
	local vo = self:getAcVo()
	if newRecharge and vo and vo.selfRechargeNums then
		vo.selfRechargeNums = newRecharge
	else
		vo.selfRechargeNums = 0
	end
end

function acQmsdVoApi:getSingleRechargeNumsState()
	local vo = self:getAcVo()
	local gemsTb = self:getSingleRechargeReward()--全服领奖需要的金币档位
	local allRechargeNums = self:getSingleRechargeNums()--全服当前的金币数
	local getedByGemsTb = vo.selfGetedByGemsTb or {}--个人当前已领过的金币档位对应奖励
	local tbNum = SizeOfTable(gemsTb)

	local curSelfStateTb = {}
	local getedTb = {}
	for i=1,tbNum do
		if allRechargeNums >=gemsTb[i]then
			local noHas = true
			for k,v in pairs(getedByGemsTb) do
				if v == gemsTb[i] then
					noHas = false
					table.insert(getedTb,i)
				end
			end	
			-- print("noHas===>>>>",noHas)
			if noHas then
				table.insert(curSelfStateTb,{index=i,state=2})
			end
		end
	end
	for i=1,tbNum do
		if allRechargeNums < gemsTb[i] then
			table.insert(curSelfStateTb,{index=i,state=1})
		end
	end
	for k,v in pairs(getedTb) do
		table.insert(curSelfStateTb,{index=v,state=3})
	end
	self.curSelfStateTb = curSelfStateTb
	return curSelfStateTb

end



------------ tab     3    ---------------

function acQmsdVoApi:setUpDataState(state)
	self.upDataState = state
end
function acQmsdVoApi:getUpDataState()
	return self.upDataState
end

function acQmsdVoApi:getAllRechargeReward( )--allRechargeReward
	local vo = self:getAcVo()
	local num1 = self:getAllRechargeNums( )
	local allRechargeNums = tonumber(num1)
	local needGems = nil
	if SizeOfTable(self.allRechargeRewardNeedGemsTb) == 0 then
		if vo and vo.activeCfg and vo.activeCfg.allRechargeReward then
			local allRechargeRewardTb = {}
			local allRechargeRewardNeedGemsTb = {}
			for k,v in pairs(vo.activeCfg.allRechargeReward) do
				table.insert(allRechargeRewardNeedGemsTb,v[1])
				table.insert(allRechargeRewardTb,v[2])
			end
			self.allRechargeRewardTb = allRechargeRewardTb
			self.allRechargeRewardNeedGemsTb = allRechargeRewardNeedGemsTb


			for k,v in pairs(self.allRechargeRewardNeedGemsTb) do
				if v > allRechargeNums then
					needGems = v - allRechargeNums
					do break end
				end
			end

			return allRechargeRewardNeedGemsTb,allRechargeRewardTb,needGems
		end
		return {},{}
	else

		for k,v in pairs(self.allRechargeRewardNeedGemsTb) do
			if v > allRechargeNums then
				needGems = v - allRechargeNums
				do break end
			end
		end

		return self.allRechargeRewardNeedGemsTb,self.allRechargeRewardTb,needGems
	end
end

function acQmsdVoApi:getAllRechargeNums( )--拿到当前总金额
	local vo = self:getAcVo()
	if vo and vo.allRechargeNums then
		return vo.allRechargeNums,vo.lastAllRechargeNums
	end
	return 0 ,0
end

function acQmsdVoApi:setAllRechargeNums(newRechargeNums)
	local vo = self:getAcVo()
	if newRechargeNums and vo and vo.allRechargeNums then
		vo.lastAllRechargeNums = newRechargeNums
		vo.allRechargeNums = newRechargeNums
		-- self.upDataState3 = true
	else
		print("error~~~~ in setAllRechargeNums")
	end
end
-- function acQmsdVoApi:setUpDataState3(state3)
-- 	self.upDataState3 = state3
-- end
-- function acQmsdVoApi:getUpDataState3()
-- 	return self.upDataState3
-- end

function acQmsdVoApi:getAllRechargeNumsState()
	local vo = self:getAcVo()
	local gemsTb = self:getAllRechargeReward()--全服领奖需要的金币档位
	local allRechargeNums = self:getAllRechargeNums()--全服当前的金币数
	local getedByGemsTb = vo.getedByGemsTb or {}--个人当前已领过的金币档位对应奖励
	local tbNum = SizeOfTable(gemsTb)

	local curStateTb = {}
	local getedTb = {}
	for i=1,tbNum do
		if allRechargeNums >=gemsTb[i]then
			local noHas = true
			for k,v in pairs(getedByGemsTb) do
				if v == gemsTb[i] then
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
		if allRechargeNums < gemsTb[i] then
			table.insert(curStateTb,{index=i,state=1})
		end
	end
	for k,v in pairs(getedTb) do
		table.insert(curStateTb,{index=v,state=3})
	end
	self.curStateTb = curStateTb
	return curStateTb

end