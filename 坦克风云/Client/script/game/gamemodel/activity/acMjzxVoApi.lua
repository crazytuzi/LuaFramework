acMjzxVoApi={
	name             =nil,
	rewardLog        =nil,
	rankAwardList    = {},
	oldRankAwardList = {},
	poolAwardTb = {},
}
function acMjzxVoApi:clearAll()
	self.name             = nil
	self.rankAwardList    = nil
	self.rewardLog        = nil
	self.oldRankAwardList = nil
	self.poolAwardTb	  = nil
	self.formatTab		  = nil
end
function acMjzxVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acMjzxVoApi:setActiveName(name)
	self.name=name
end

function acMjzxVoApi:getActiveName()
	return self.name or "mjzx"
end

function acMjzxVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et - 86400 then
		return false
	end
	return true
end

--获取领奖时间的结束时间戳, 详情见上面getActiveEndTs方法的注释
function acMjzxVoApi:getRewardEndTs()
	local acVo=self:getAcVo()
	if(acVo==nil or acVo.et==nil)then
		return 0
	end
	return acVo.et
end

--当前是活动时间还是领奖时间
--活动时间可以购买充值，领奖时间不能
--1是活动时间
--2是领奖时间
function acMjzxVoApi:checkActiveStatus()
	local endTs=self:getRewardEndTs()
	if(base.serverTime<endTs)then
		return 1
	else
		return 2
	end
end


function acMjzxVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

-- function acMjzxVoApi:getTimer( )--倒计时 需要时时显示
-- 	local vo=self:getAcVo()
-- 	local str=""
-- 	if vo then
-- 		str=getlocal("activityCountdown")..":"..G_formatActiveDate(vo.et - base.serverTime)
-- 	end
-- 	return str
-- end

function acMjzxVoApi:getTimeStr()
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

function acMjzxVoApi:getRewardTimeStr()
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

--是否处于领奖时间
function acMjzxVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo then
		if base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt then
			return true
		end
	end
	return false
end

function acMjzxVoApi:canReward( )

	return false
end

function acMjzxVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end
function acMjzxVoApi:getFirstFree()--免费标签
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 0
end
function acMjzxVoApi:setFirstFree(newfree)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = newfree
	end
end
function acMjzxVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end
function acMjzxVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acMjzxVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

-------------------- t a b 1 ---------------------

function acMjzxVoApi:getShowList( )
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.showList then
		return vo.activeCfg.showList
	end
	return nil
end
function acMjzxVoApi:getShowList2( )--vo.activeCfg.showListFlash
	local vo = self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.showListFlash then
		return vo.activeCfg.showListFlash
	end
	return nil
end
function acMjzxVoApi:formatHero()
	local needList = self:getShowList().h
	local name ,key,quality,index,type,num,etype
	if not self.formatTab then
		self.formatTab = {}
		for k,v in pairs(needList) do
		        name = k
		        key = k 
		        type= string.sub(k,1,1)
		        etype = string.sub(k,1,1)
		        quality = v
		        index = tonumber(RemoveFirstChar(k))
		        num = tonumber(RemoveFirstChar(k))
		        if name and name ~= "" then
		        	local award = {name=name,key=key,type=type,index=index}
		            local function sortAsc(a, b)
		                if a and b and a.index and b.index and tonumber(a.index) and tonumber(b.index) then
		                    return a.index < b.index
		                end
		            end
		            table.sort(award,sortAsc)
		        	table.insert(self.formatTab,{name=name,quality=quality,index=index,award=award})
		        end	
		end
		if self.formatTab and SizeOfTable(self.formatTab)>0 then
			local function sortAsc(a, b)
				if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
					return a.index < b.index
				end
		    end
			table.sort(self.formatTab,sortAsc)
		end
	end
	return self.formatTab
end

function acMjzxVoApi:getAgainNum()
	local vo = self:getAcVo()

	if vo and vo.againNum then
		return 10 - vo.againNum
	end
	return 10
end

function acMjzxVoApi:isFreeLottery()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			flag=0
		end
	end
	return flag
end
function acMjzxVoApi:resetFreeLottery()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

function acMjzxVoApi:getLotteryCost()
	local cost1,cost2=0,0
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		cost1=vo.activeCfg.cost
		cost2=vo.activeCfg.cost2
	end
	return cost1,cost2
end

function acMjzxVoApi:getMultiNum()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.mul or 5
	end
	return 5
end

function acMjzxVoApi:getRewardPool()
	local acVo=self:getAcVo()
	local awardFormatTb = {}
	if self.poolAwardTb == nil or SizeOfTable(self.poolAwardTb) == 0 then
		if acVo and acVo.activeCfg and acVo.activeCfg.reward then
				self.poolAwardTb = FormatItem(acVo.activeCfg.reward,nil,true)
		end
	end

	return self.poolAwardTb
end
function acMjzxVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acMjzxVoApi:acMjzxRequest(sockStr,args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				local awardTime = base.serverTime
				if sData.data.mjzx then
					self:updateData(sData.data.mjzx)

					if sData.ts then
						awardTime = sData.ts
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
				local showAwardNameNum,showAwardNameNumTb = "",{}
				if sData.data.reward then --奖励
					num= SizeOfTable(sData.data.reward)
					local rewards=sData.data.reward
					
					for k,v in pairs(rewards) do
						local reward=FormatItem(v,nil,true)[1]
						table.insert(rewardlist,reward)

						local heroSoulTb = self:getShowList2().h
						-- print("SizeOfTable(heroSoulTb)=====>>>>",SizeOfTable(heroSoulTb))
						for m,n in pairs(heroSoulTb) do
							-- print('reward.name == n.name=======>>>>',reward.key,m)
							-- useNum = useNum + 1
							-- local useS = SizeOfTable(heroSoulTb) == useNum and "" or ", "
							if reward.key == m and reward.num > 5 then
								reward.isNeedBigAwardBg = true
								-- showAwardNameNum = showAwardNameNum..reward.name.."x"..reward.num..useS
								table.insert(showAwardNameNumTb,reward.name.."x"..reward.num)
							end
						end

						-- print("reward.type---reward.eType--->>>",reward.type,reward.eType)
						if reward.type =="h" then
							local oldHeroList3=heroVoApi:getHeroList()
							local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(reward,oldHeroList)
							if heroVoApi:heroHonorIsOpen()==true then
								local hid
								if reward.eType=="h" then 
			                        hid=reward.key
			                    elseif reward.eType=="s" then
			                        hid=heroCfg.soul2hero[reward.key]
			                    end 
			                    if hid and heroVoApi:getIsHonored(hid)==true then--转化铁十字
			                        local pid=heroCfg.getSkillItem
			                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
			                        bagVoApi:addBag(id,addNum)
			                        reward.isIronCross = true--给显示使用
			                    else
			                    	-- print("111111",reward.type,reward.key,reward.id,reward.num)
			                    	heroVoApi:addSoul(reward.key,reward.num)
			                    end
			                else 
			                	heroVoApi:addSoul(reward.key,reward.num)
			                end
						else
							-- print("11111133333",reward.type,reward.key,reward.id,reward.num)
							G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
						end
					end
					for k,v in pairs(showAwardNameNumTb) do
						local useS = SizeOfTable(showAwardNameNumTb) == k and "" or ", "
						showAwardNameNum = showAwardNameNum..v..useS
					end
					if showAwardNameNum ~= "" then
						local paramTab={}
		                paramTab.functionStr="mjzx"
		                paramTab.addStr="take_part"
		                local chatKey = "activity_mjzx_chat"
		                local message={key=chatKey,param={playerVoApi:getPlayerName(),showAwardNameNum}}
		                chatVoApi:sendSystemMessage(message,paramTab)
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
				if sockStr == "buy" then
					callback(pointsTb,point,rewardlist,hxReward)				
				else
					callback()
				end
			end
		end
	end
	socketHelper:acMjzxRequest(sockStr,args,requestHandler)
end

--格式化抽奖记录
function acMjzxVoApi:formatLog(data,addFlag)
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
	local time=data[4] or base.serverTime
	local point=data[3] or 0
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

function acMjzxVoApi:getRewardLog()
	return self.rewardLog
end
-------------------- t a b 2 ---------------------
function acMjzxVoApi:getRankAwardList(bigAwardIdx)
	local vo,dataIdx,idxx = self:getAcVo(),nil,1

	if self.rankAwardList and SizeOfTable(self.rankAwardList) > 0 then
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
		end
		self.rankAwardList = formatRankAwardList
		self.oldRankAwardList = formatRankAwardList2
		return formatRankAwardList,dataIdx,formatRankAwardList2
	end
	return nil
end

function acMjzxVoApi:setPlayerList( list )
	local vo = self:getAcVo()
	if vo and list then
		vo.playerList =list
	end
end
function acMjzxVoApi:getPlayerList( )
	local vo = self:getAcVo()
	if vo and vo.playerList then
		return vo.playerList
	end
	return nil
end

function acMjzxVoApi:setScore( curScore )
	local vo = self:getAcVo()
	if vo and curScore then
		vo.score = curScore
	end
end
function acMjzxVoApi:addScore( adScore )
	local vo = self:getAcVo()
	if vo and adScore then
		print("vo.score + adScore=========>>>>",vo.score + adScore)
		vo.score = vo.score + adScore
	end
end
function acMjzxVoApi:getScore( )
	local vo = self:getAcVo()
	if vo and vo.score then
		return vo.score
	end
	return 0
end
function acMjzxVoApi:getScoreFloor( )
	local vo = self:getAcVo()
	if vo and vo.scoreFloor then
		return vo.scoreFloor
	end
	return nil
end

function acMjzxVoApi:getSelfPos( )
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

function acMjzxVoApi:getRankInfoStr( )
	local tabStr = {}
    local awardList,nodata,oldRankAwardList = self:getRankAwardList()
    local infoStr = ""

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

                infoStr = n.name .. ":" .. getlocal(n.desc)
            end
        end
        rewardStrTab[k]=str
    end

    tabStr={getlocal("activity_mjzx_rankInfo1"),getlocal("activity_jsss_rankInfo2"),getlocal("activity_jsss_rankInfo3"),
    	getlocal("activity_getRich_rankdes1",{rewardStrTab[1]}),
    	getlocal("activity_getRich_rankdes2",{rewardStrTab[2]}),
    	getlocal("activity_getRich_rankdes3",{rewardStrTab[3]}),
    	getlocal("activity_getRich_rankdes4",{rewardStrTab[4]}),
    	getlocal("activity_getRich_rankdes5",{rewardStrTab[5]}),
    	"",
    	infoStr,
    }

    return tabStr
end

function acMjzxVoApi:isReaward( )
	local score      = self:getScore()
	local playerList = self:getPlayerList()
	local playeName  = playerVoApi:getPlayerName()
	for k,v in pairs(playerList) do
		-- print("v[2].......",v[2],playeName,v[3],score)
		if v[1] ==playeName then
			return true
		end
	end
	return false
end

function acMjzxVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acMjzxVoApi:getedBigAward( )
	local vo = self:getAcVo()
	if vo and vo.getedBigAward then
		return vo.getedBigAward
	end
	return nil
end

function acMjzxVoApi:setGetedBigAward( )
	local vo  = self:getAcVo()
	if vo and vo.getedBigAward==nil then
		vo.getedBigAward =1
	end
end

function acMjzxVoApi:getAndShowBigAward(bigAwardIdx)
	local bigAwardTb,awardIdx,oldRankAwardList = self:getRankAwardList(bigAwardIdx)
	for k,v in pairs(oldRankAwardList[awardIdx]) do
		G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
	end
	G_showRewardTip(oldRankAwardList[awardIdx],true)
	self:setGetedBigAward( )
end
-------------------- e n d 2 ---------------------