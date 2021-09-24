--2018万圣节活动不给糖果就捣蛋
--author: Du Wei
acHalloween2018VoApi={
	rewardLog=nil,
	rankAwardList={},
}

function acHalloween2018VoApi:getAcVo()
	return activityVoApi:getActivityVo("wsj2018")
end

function acHalloween2018VoApi:setActiveName(name)
	self.name=name
end

function acHalloween2018VoApi:getActiveName()
	return self.name or "wsj2018"
end

function acHalloween2018VoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	local str=""
	if vo then
		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
	end
	return str
end
function acHalloween2018VoApi:showInfoTipTb(layerNum)
	local version = self:getVersion()
	local tabStr = {}
	for i=1,7 do
		if version==2 and (i==2 or i==4 or i==5) then
        	table.insert(tabStr,getlocal("activity_wsj2018_ver"..version.."_tip"..i))
		else
        	table.insert(tabStr,getlocal("activity_wsj2018_tip"..i))
		end
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(layerNum,true,true,nil,titleStr,tabStr,nil,25)
end
function acHalloween2018VoApi:canReward()
	local vo=self:getAcVo()
	if playerVoApi:getPlayerLevel() < 50 then
		return false
	end
	if self:isFreeLottery() == 1 or self:isToday() == false then
		return true
	end
	return false
end

function acHalloween2018VoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
	spriteController:addTexture("public/activeCommonImage2.png")
end

function acHalloween2018VoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
	spriteController:removeTexture("public/activeCommonImage2.png")
end

function acHalloween2018VoApi:clearAll()
	self.rewardPos = nil
	self.rankAwardList =nil
	self.rewardLog     =nil
	self.rewardTb      = nil
end

function acHalloween2018VoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.t then
		isToday=G_isToday(vo.t)
	end
	return isToday
end
function acHalloween2018VoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end
function acHalloween2018VoApi:resetFreeLottery()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end
function acHalloween2018VoApi:isFreeLottery()
	-- local flag=1
	-- local vo=self:getAcVo()
	-- if vo then
	-- 	if vo.free and vo.free>=1 then
	-- 		flag=0
	-- 	end
	-- end
	local vo=self:getAcVo()
	if vo and vo.free then
		if vo.free == 1 then
			if not self:isToday() then
				return 1
			end
		end
		return 0--vo.free
	elseif vo.free == nil then
		return 1
	end

	return 0
end

function acHalloween2018VoApi:getLotteryCost( )
	local cost1,cost2=0,0
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		cost1=vo.activeCfg.cost
		cost2=vo.activeCfg.cost2
	end
	return cost1,cost2
end

function acHalloween2018VoApi:getMultiNum()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.mul or 5
	end
	return 5
end

function acHalloween2018VoApi:specicalMarkShow(icon,key)
 	local specShowTb = {[1]="r",[8]="y"}
	local specNumTb = {[1]=5,[8]=3}
	if specShowTb[key] then	
		G_addRectFlicker2(icon,1.1,1.1,specNumTb[key],specShowTb[key],nil,55)
	end
end

function acHalloween2018VoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return {}
end

function acHalloween2018VoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acHalloween2018VoApi:getlevelLimit( )
	local vo = self:getAcVo()
	if vo and vo.levelLimit then
		return vo.levelLimit
	end
	return 50
end
function acHalloween2018VoApi:setScore(score)
	local vo = self:getAcVo()
	if vo and score then 
		vo.score =score 
	end
end
function acHalloween2018VoApi:getScore( )---总糖果数
	local vo = self:getAcVo()
	if vo and vo.score then
		return vo.score > vo.topScore and vo.topScore or vo.score,vo.topScore or 9999
	end
	return 0 
end
function acHalloween2018VoApi:getPercentScorePic()
	local vo = self:getAcVo()

	if vo and vo.score and vo.topScore then--math.floor(
		local curPer = math.floor(vo.score/vo.topScore * 100)
		
		local returnPer = 0
		local perTb = {25,50,75,100}
		local usePic = {"acWsjSweet1.png","acWsjSweet2.png","acWsjSweet3.png","acWsjSweet4.png"}

		if curPer == 0 then
			return nil,returnPer
		else
			for k,v in pairs(perTb) do
				if curPer < v then--if curPer >= v then
					returnPer = k
					do break end
				end
			end
			if curPer >= 100 then
				returnPer = 4
			end
			return usePic[returnPer],returnPer
		end
	end
	print "~~~~~~~~~~~~~~error in getPercentScore~~~~~~~~~~~~~"
	return nil
end
function acHalloween2018VoApi:acHalloween2018Request(cmd,args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				local awardTime = base.serverTime
				if sData.data.wsj2018 then
					self:updateData(sData.data.wsj2018)

					if sData.ts then
						awardTime = sData.ts
					end

					if sData.data.wsj2018.p then
						self:setScore(sData.data.wsj2018.n)
					end
				end
				local rewardlist={}
				local num=1
				local point,pointsTb=0,{}
				local hxReward
				local rewardPos = nil

				if sData.data.points then
					pointsTb = sData.data.points
					-- self:setPointsTb(sData.data.points)
					point=0
					for k,v in pairs(sData.data.points) do
						point = point + v
					end
				end
--activity_pjjnh_chatSystemMessage
				if sData.data.reward then --奖励
					num= SizeOfTable(sData.data.reward)
					local rewards=sData.data.reward
					for k,v in pairs(rewards) do
						local reward=FormatItem(v,nil,true)[1]
						table.insert(rewardlist,reward)
						G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
						self:willChatMessage(reward)
						if k == num then
							local key = reward.key
							local num = reward.num
							local useRewardTb = self:getRewardTb()
							for mm,nn in pairs(useRewardTb) do
								if nn.key == key and nn.num == num then
									rewardPos = mm
									do break end
								end
							end
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
						awardInfoTb[3] = point
						awardInfoTb[4] = awardTime
						self:formatLog(awardInfoTb,true)
					end
				end
				
				if sData.data.log then --日志
					self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end
				end
				if callback then
					
					self.rewardPos = rewardPos
					callback(pointsTb,point,rewardlist,hxReward,rewardPos)				
				end
			end
		end
	end
	socketHelper:acHalloween2018Request(cmd,args,requestHandler)
end

function acHalloween2018VoApi:willChatMessage(curReward)
	local rewardTb = acHalloween2018VoApi:getRewardTb( )
	for k,v in pairs(rewardTb) do
		if (k ==1 or k == 8 ) and v.key == curReward.key and v.num == curReward.num then
			local desStr
            desStr="activity_pjgx_chatMessage1"
            local paramTab={}
            paramTab.functionStr="wsj2018"
            paramTab.addStr="i_also_want"
            local activeName = getlocal("activity_wsj2018_title")
            local ver=self:getVersion()
            if ver==2 then
            	activeName = getlocal("activity_wsj2018_ver2_title")
            end
            local message={key=desStr,param={playerVoApi:getPlayerName(),activeName,v.name.."x"..v.num}}
            chatVoApi:sendSystemMessage(message,paramTab)

		end
	end
end
function acHalloween2018VoApi:getoldRewardPos()
	return self.rewardPos or 2
end
--格式化抽奖记录
function acHalloween2018VoApi:formatLog(data,addFlag)
	local num=data[1]
	local rewards=data[2]
	local rewardlist={}
	for k,v in pairs(rewards) do
		local reward=FormatItem(v,nil,true)
		table.insert(rewardlist,reward[1])
	end
	local hxReward=self:getHexieReward()
	if hxReward then
		hxReward.num=hxReward.num*num
		table.insert(rewardlist,1,hxReward)
	end
	local time=data[4] or 0
	local point=data[3] or base.serverTime
	local lcount=SizeOfTable(self.rewardLog)
	if lcount>=10 then
		for i=10,lcount do
			table.remove(self.rewardLog,i)
		end
	end
	if addFlag and addFlag==true then
    	table.insert(self.rewardLog,1,{num=num,reward=rewardlist,time=time,point=point})
	else
	    table.insert(self.rewardLog,{num=num,reward=rewardlist,time=time,point=point})
	end
end

function acHalloween2018VoApi:getRewardLog()
	return self.rewardLog
end



------------------------额外奖励------------------------

function acHalloween2018VoApi:acHalloween2018SmallDialog(index,layerNum,callback)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acHalloween2018SmallDialog"
    local sDialog=acHalloween2018SmallDialog:new()
    sDialog:init(index,layerNum,callback)
    return sDialog
end

function acHalloween2018VoApi:getUseNum(idx)
	local acVo = self:getAcVo()
	local canGet = false
	local canUseNum,curNum = 0,acVo.curNum or 0
	if acVo.extraReward and acVo.extraReward[idx] then
		canUseNum = acVo.extraReward[idx].num
		curNum = canUseNum > curNum and curNum or canUseNum
		if curNum >= canUseNum then
			canGet =true
		end
	end
	return curNum,canUseNum,canGet
end

function acHalloween2018VoApi:getboxAwardTb(idx)
	local acVo = self:getAcVo()
	if acVo and acVo.extraReward and acVo.extraReward[idx] then
		return acVo.extraReward[idx].reward
	end
	print("~~~~~~~~~~~error in getboxAwardTb idx:",idx)
	return {}
end
function acHalloween2018VoApi:getedAwardBoxTb(idx)
	local acVo = self:getAcVo()
	if acVo and acVo.getedAwardBoxTb then
		for k,v in pairs(acVo.getedAwardBoxTb) do
			if v == idx then
				return true
			end
		end
	end
	return false
end

------------------------ 抽 奖 ------------------------

function acHalloween2018VoApi:getClockItemId( )
	local acVo = self:getAcVo()
	if acVo and acVo.clockItemId then
		return acVo.clockItemId
	end
	return nil
end
function acHalloween2018VoApi:getFlickTb( )
	local acVo = self:getAcVo()
	if acVo and acVo.flickerTb then
		return acVo.flickerTb
	end
	return nil
end
function acHalloween2018VoApi:getRewardTb( )
	if self.rewardTb then
		return self.rewardTb
	else
		local acVo = self:getAcVo()
		local clockItemId = self:getClockItemId()
		local rewardTb = {}
		if acVo and acVo.reward then
			rewardTb = FormatItem(acVo.reward,nil,true)
			
			for k,v in pairs(rewardTb) do
				if v.key == clockItemId then
					v.clockItemId = true
					do break end
				end
			end
		end
		self.rewardTb = rewardTb
		return rewardTb
	end
end

function acHalloween2018VoApi:getRechargeData( )
	local acVo = self:getAcVo()
	if acVo then
		local curRecharge = tonumber(acVo.curRecharge) or 0
		local topRecharge = tonumber(acVo.topRecharge) or 0
		local isLock = curRecharge < topRecharge and true or false
		return curRecharge,topRecharge,isLock
	end
	return 0 ,0
end

function acHalloween2018VoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo.version then
		return tonumber(acVo.version)
	end
	return 1
end




