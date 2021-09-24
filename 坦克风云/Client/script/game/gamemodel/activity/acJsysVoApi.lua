acJsysVoApi={
	rewardLog=nil,
	rankAwardList={},
	oldRankAwardList = {},
	oldPercent = 0
}

function acJsysVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("jsss")
	end
	return self.vo
end
function acJsysVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acJsysVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end
function acJsysVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acJsysVoApi:getActiveName()
	return "jsss"
end
function acJsysVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.t then
		isToday=G_isToday(vo.t)
	end
	return isToday
end

function acJsysVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		str=getlocal("activity_timeLabel").."\n"..timeStr
	end

	return str
end

function acJsysVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local rewardTimeStr=activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		str=getlocal("recRewardTime").."\n"..rewardTimeStr
	end
	return str
end

function acJsysVoApi:getTabOneHelpInfo( )
	local strTb,strNums,strLb = {},5,"activity_jsss_info"

	if base.hexieMode==1 then
		strNums = 6
		strLb = "activity_jsss_".."hxInfo"
	end
	for i=1,strNums do
		local str = getlocal(strLb..i)
		table.insert(strTb,str)
	end
	return strTb
end

function acJsysVoApi:getRewardPool(idx)
	local acVo=self:getAcVo()
	local awardFormatTb = {}
	if acVo and acVo.activeCfg and acVo.activeCfg.reward then
		if idx and acVo.activeCfg.reward[idx] then--活动面板使用
			local awardTb = FormatItem(acVo.activeCfg.reward[idx],nil,true)

			return awardTb
		else--目前只用于奖励库使用
			for i=1,3 do
				local awardTb = FormatItem(acVo.activeCfg.reward[i],nil,true)
				table.insert(awardFormatTb,awardTb)
			end

			return awardFormatTb
		end
	end
	
end

function acJsysVoApi:canReward()
	local vo=self:getAcVo()
	if vo.free ==nil then
		return true
	else 
		return false
	end

end

function acJsysVoApi:getMultiNum()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.mul or 5
	end
	return 5
end
function acJsysVoApi:getLotteryCost()
	local cost1,cost2=0,0
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		cost1=vo.activeCfg.cost
		cost2=vo.activeCfg.cost2
	end
	return cost1,cost2
end

function acJsysVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acJsysVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg and base.hexieMode==1 then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

function acJsysVoApi:isFreeLottery()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			flag=0
		end
	end
	return flag
end

function acJsysVoApi:resetFreeLottery()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

function acJsysVoApi:acJsysRequest(args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				local awardTime = base.serverTime
				if sData.data.jsss then
					self:updateData(sData.data.jsss)

					if sData.ts then
						awardTime = sData.ts
					end
					if sData.data.jsss.c then
						self:setCurScore(sData.data.jsss.c)
					end
					if sData.data.jsss.n then
						self:setScore(sData.data.jsss.n)
					end
				end
				local rewardlist={}
				local num=1
				local point,pointsTb=0,{}
				local hxReward

				if sData.data.points then
					pointsTb = sData.data.points
					-- self:setPointsTb(sData.data.points)
					point=0
					for k,v in pairs(sData.data.points) do
						point = point + v
					end
				end

				if sData.data.clientReward then --奖励
					num= SizeOfTable(sData.data.clientReward)
					local rewards=sData.data.clientReward
					for k,v in pairs(rewards) do
						local reward=FormatItem(v,nil,true)[1]
						table.insert(rewardlist,reward)
						G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
					end
					hxReward=self:getHexieReward()
					if hxReward then
						hxReward.num=hxReward.num*num
						G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
					end
					if self.rewardLog then
						local awardInfoTb = {}
						awardInfoTb[1] = num
						awardInfoTb[2] = sData.data.clientReward
						awardInfoTb[3] = awardTime
						awardInfoTb[4] = point
						self:formatLog(awardInfoTb,true)
					end
				end
				
				if sData.data.log then --日志
					self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end
				end
				local action=args.action
				if action and callback then
					if action==1 then
							callback(pointsTb,point,rewardlist,hxReward)				
					else
						callback()
					end
				end
			end
		end
	end
	socketHelper:acJsysRequest(args,requestHandler)
end

--格式化抽奖记录
function acJsysVoApi:formatLog(data,addFlag)
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
	local time=data[3] or base.serverTime
	local point=data[4] or 0
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

function acJsysVoApi:getRewardLog()
	return self.rewardLog
end

function acJsysVoApi:setPointsTb(pointsTb)
	local vo = self:getAcVo()
	if vo and pointsTb then
		vo.pointsTb = pointsTb
	else
		vo.pointsTb = {}
	end
end
function acJsysVoApi:getPointsTb( )
	local vo = self:getAcVo()
	return vo.pointsTb
end

function acJsysVoApi:setScore( idx,num )
	local vo = self:getAcVo()
	if idx and num ==nil then 
		vo.score =idx 
	end
	if idx and num ==2 then
		vo.score =vo.score+idx
	end
end

function acJsysVoApi:getScore( )
	local vo = self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end
function acJsysVoApi:getScoreFloor( )
	local vo = self:getAcVo()
	if vo and vo.scoreFloor then
		return vo.scoreFloor
	end
	return nil
end

function acJsysVoApi:getPoolLimit( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.poolLimit then
		return vo.activeCfg.poolLimit
	end
	return {}
end
function acJsysVoApi:setCurScore(curScore)
	local vo = self:getAcVo()
	if vo and curScore then
		vo.curScore = curScore
	end
end
function acJsysVoApi:getCurScoreAndPercent( )
	local vo = self:getAcVo()
	local poolLimit = self:getPoolLimit()
	if vo.curScore then
		local floor = 0
		if vo.curScore > poolLimit[#poolLimit] then--后台没有及时刷，需要前台自己刷回第一档
			local showCurScore = vo.curScore - poolLimit[#poolLimit]
			local showCurScoreLimit =  poolLimit[1] 
			local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
			self.oldPercent = percent
			return tonumber(percent),1,poolLimit[1],1
		end
		for i=1,#poolLimit do
			-- print("vo.curScore <= poolLimit[i]----->",vo.curScore , poolLimit[i])
			if vo.curScore <= poolLimit[i] then
				local showCurScore = i > 1 and vo.curScore - poolLimit[i-1] or vo.curScore
				local showCurScoreLimit = i > 1 and poolLimit[i] - poolLimit[i-1] or poolLimit[i]
				local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
				floor = i
				-- print("percent,floor,poolLimit[i]====>>>>",percent,floor,poolLimit[i])
				self.oldPercent = percent
				return tonumber(percent),floor,poolLimit[i]
			end
		end

	end
	return 0
end
--poolimitNum 旧的上限值 用于判断 最新的积分是否用于刷新进度条
function acJsysVoApi:getPercentActionData(limitIdx,poolimitNum,nextAwardPosTb,refreshNext)
	local vo = self:getAcVo()
	local poolLimit = self:getPoolLimit()
	local curUseCurScore = vo.curScore
	-- print("limitIdx,poolimitNum------>",limitIdx,poolimitNum)
	if refreshNext then
		if limitIdx == 1 then
			if curUseCurScore > poolLimit[#poolLimit] then
				local showCurScore = curUseCurScore - poolLimit[#poolLimit]
				local showCurScoreLimit =  poolLimit[1] 
				local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
				self.oldPercent = percent

				return tonumber(percent),1,poolLimit[1]
			else
				if curUseCurScore <= poolimitNum then
					local showCurScore =  curUseCurScore
					local showCurScoreLimit = poolLimit[1]
					-- print("poolLimit[1]----->",poolLimit[1],poolimitNum)
					local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
					-- print("percent,floor,poolLimit[i]====>>>>",percent,floor,poolLimit[i])
					self.oldPercent = percent
					return tonumber(percent),limitIdx,poolimitNum
				else
					-- print("wrong~~111~~~---curUseCurScore-----poolimitNum--->",curUseCurScore,poolimitNum)
				end
			end
		else
			if curUseCurScore > poolLimit[limitIdx] then
				local showCurScore = curUseCurScore - poolLimit[limitIdx-1]
				local showCurScoreLimit =  poolLimit[limitIdx]
				local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
				self.oldPercent = percent

				return tonumber(percent),poolLimit,poolLimit[limitIdx]
			else
				if curUseCurScore <= poolimitNum then
					local showCurScore =  curUseCurScore - poolLimit[limitIdx-1]
					local showCurScoreLimit = poolLimit[limitIdx] - poolLimit[limitIdx-1]
					-- print("poolLimit[limitIdx]----->",poolLimit[limitIdx],poolimitNum)
					local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
					-- print("percent,floor,poolLimit[i]====>>>>",percent,floor,poolLimit[i])
					self.oldPercent = percent
					return tonumber(percent),limitIdx,poolimitNum
				else
					-- print("wrong~~~~~---curUseCurScore-----poolimitNum--->",curUseCurScore,poolimitNum)
				end
			end
		end

	else
		-- print("curUseCurScore > poolimitNum--===-=-=-=-====>>",curUseCurScore ,poolimitNum)
		if nextAwardPosTb and limitIdx == 3 and curUseCurScore <  poolLimit[#poolLimit] then--没有换库的情况
			curUseCurScore = curUseCurScore + poolLimit[#poolLimit]
		end	
		local floor = 0
		if curUseCurScore > poolLimit[#poolLimit] then--后台没有及时刷，需要前台自己刷回第一档
			local showCurScore = curUseCurScore - poolLimit[#poolLimit]
			local showCurScoreLimit =  poolLimit[1] 
			local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
			self.oldPercent = percent

			return 1,1,poolLimit[1],tonumber(percent)

		elseif curUseCurScore > poolimitNum then
			local showCurScore = curUseCurScore - poolimitNum
			local showCurScoreLimit =  poolLimit[limitIdx+1] 
			local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
			self.oldPercent = percent

			return 1,limitIdx+1,poolLimit[limitIdx+1],tonumber(percent)

		elseif curUseCurScore <= poolimitNum then
			local showCurScore = limitIdx > 1 and curUseCurScore - poolLimit[limitIdx-1] or curUseCurScore
			local showCurScoreLimit = limitIdx > 1 and poolimitNum - poolLimit[limitIdx-1] or poolimitNum
			local percent = string.format("%0.2f",showCurScore/showCurScoreLimit)
			-- print("percent,floor,poolLimit[i]====>>>>",percent,floor,poolLimit[i])
			self.oldPercent = percent
			return tonumber(percent),limitIdx,poolimitNum
		end
	end		

end

function acJsysVoApi:getRankInfoStr( )
	local tabStr = {}
    local awardList,nodata,oldRankAwardList = self:getRankAwardList()

    local rewardStrTab={}
    for k,v in pairs(oldRankAwardList) do
        local award=v
        local str=""
        for m,n in pairs(award) do
            if n.type =="h" then
                if G_getCurChoseLanguage() ~="ar" then
                    if m==SizeOfTable(award) then
                        str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " 
                    else
                        str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " ..  ","
                    end
                else
                    if m==SizeOfTable(award) then
                        str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " 
                    else
                        str = str ..getlocal("whichStar",{n.num}).. n.name .. " x 1 " ..  ",\n"
                    end
                end
            else
                if m==SizeOfTable(award) then
                    str = str .. n.name .. " x" .. n.num
                else
                    str = str .. n.name .. " x" .. n.num .. ","
                end
            end
        end
        rewardStrTab[k]=str
    end

    tabStr={getlocal("activity_jsss_rankInfo1"),getlocal("activity_jsss_rankInfo2"),getlocal("activity_jsss_rankInfo3"),getlocal("activity_equipSearch_rank_tip_4",{rewardStrTab[1],rewardStrTab[2],rewardStrTab[3],rewardStrTab[4],rewardStrTab[5]})}

    return tabStr
end
function acJsysVoApi:getRankAwardList(bigAwardIdx)
	local vo,dataIdx,idxx = self:getAcVo(),nil,1

	if self.rankAwardList and SizeOfTable(self.rankAwardList) > 0 then
		if bigAwardIdx then
			for k,v in pairs(vo.activeCfg.rankreward) do
				if v[1][1]<= bigAwardIdx and v[1][2]>= bigAwardIdx then
					dataIdx = k
					do break end
				end
			end
		end
		return self.rankAwardList,dataIdx,self.oldRankAwardList
	end
	if vo and vo.activeCfg and vo.activeCfg.rankreward then
		local formatRankAwardList,formatRankAwardList2 = {},{}
		for k,v in pairs(vo.activeCfg.rankreward) do
			local reward=FormatItem(v[3])
			for i=v[1][1],v[1][2] do
				if v[1][1] <= idxx and v[1][2] >= idxx then
						table.insert(formatRankAwardList,reward)
						idxx = idxx + 1
				else 
					do break end
				end	
			end
			table.insert(formatRankAwardList2,reward)
			if bigAwardIdx then
				if v[1][1]<= bigAwardIdx and v[1][2]>= bigAwardIdx then
					dataIdx = k
				end
			end
		end
		self.rankAwardList = formatRankAwardList
		self.oldRankAwardList = formatRankAwardList2
		return formatRankAwardList,dataIdx,formatRankAwardList2
	end
	return nil
end

function acJsysVoApi:setPlayerList( list )
	local vo = self:getAcVo()
	if vo and list then
		vo.playerList =list
	end
end
function acJsysVoApi:getPlayerList( )
	local vo = self:getAcVo()
	if vo and vo.playerList then
		return vo.playerList
	end
	return nil
end
function acJsysVoApi:isReaward( )
	local score = self:getScore()
	local playerList = self:getPlayerList()
	local playeName = playerVoApi:getPlayerName()
	for k,v in pairs(playerList) do
		-- print("v[2].......",v[2],playeName,v[3],score)
		if v[1] ==playeName then
			return true
		end
	end
	return false
end

function acJsysVoApi:getSelfPos( )
	local score = self:getScore()
	local playerList = self:getPlayerList()
	local playeName = playerVoApi:getPlayerName()
	for k,v in pairs(playerList) do
		if v[1] ==playeName then
			return k
		end
	end
	return nil
end

function acJsysVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acJsysVoApi:getedBigAward( )
	local vo = self:getAcVo()
	if vo and vo.getedBigAward then
		return vo.getedBigAward
	end
	return nil
end
function acJsysVoApi:setGetedBigAward( )
	local vo  = self:getAcVo()
	if vo and vo.getedBigAward==nil then
		vo.getedBigAward =1
	end
end

function acJsysVoApi:getAndShowBigAward(bigAwardIdx)
	local bigAwardTb,awardIdx,oldRankAwardList = self:getRankAwardList(bigAwardIdx)
	for k,v in pairs(oldRankAwardList[awardIdx]) do
		G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	end
	G_showRewardTip(oldRankAwardList[awardIdx],true)
	self:setGetedBigAward( )
end


function acJsysVoApi:getCurAwardPos(curShowAwardTb,nextShowAwardTb,rewardlist)
	local awardPosTb,nextAwardPosTb = {},nil
	local trackPos1,trackPos2 = {},nil
	local findedIdx = 0
	local hadAwardTb = {}
	for k,v in pairs(curShowAwardTb) do
		for m,n in pairs(rewardlist) do
			if v.name == n.name and v.num == n.num and hadAwardTb[m] == nil then
			-- print("v.name-111--n.name->",v.name,n.name)				
				table.insert(awardPosTb,k)
				findedIdx = findedIdx +1

				if trackPos1[1] == nil and k < 6 then
					trackPos1[1] = 1
				elseif trackPos1[2] == nil and k < 11 then
					trackPos1[2] = 1
				elseif trackPos1[3] == nil and k > 10 then
					trackPos1[3] = 1
				end
				-- rewardlist[m] = nil`
				hadAwardTb[m] = 1
			end
		end
	end
	if findedIdx ~= SizeOfTable(rewardlist) then
		-- print("findedIdx --- SizeOfTable(rewardlist)---->",findedIdx,SizeOfTable(rewardlist))
		nextAwardPosTb,trackPos2 = {},{}
		for k,v in pairs(nextShowAwardTb) do
			for m,n in pairs(rewardlist) do
				-- print("v.name-2222--n.name->",v.name,n.name)
				if v.name == n.name and v.num == n.num and hadAwardTb[m] == nil then
					table.insert(nextAwardPosTb,k)
					findedIdx = findedIdx +1

					if trackPos2[1] == nil and k < 6 then
						trackPos2[1] = 1
					elseif trackPos2[2] == nil and k < 11 then
						trackPos2[2] = 1
					elseif trackPos2[3] == nil and k > 10 then
						trackPos2[3] = 1
					end
				end
			end
		end
		-- print("findedIdx------>",findedIdx)
	end
	return awardPosTb,nextAwardPosTb,trackPos1,trackPos2
end

function acJsysVoApi:specicalMarkShow(icon,key)
 	local specShowTb = {p3351="b",p3345="p",p3346="p",p3360="y"}
	local specNumTb = {p3351=1,p3345=2,p3346=2,p3360=3}
	if specShowTb[key] then	
		G_addRectFlicker2(icon,1.1,1.1,specNumTb[key],specShowTb[key],nil,55)
	end
 end 

function acJsysVoApi:clearAll()
	self.rankAwardList=nil
	self.rewardLog=nil
	self.vo=nil
	self.oldPercent = nil
	self.oldRankAwardList=nil
end