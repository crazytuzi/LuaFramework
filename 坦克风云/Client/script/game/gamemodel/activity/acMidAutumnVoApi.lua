acMidAutumnVoApi={
	rankList=nil,
	-- selfRank={rank=0,name="",value=0},
	myRank="0",
	isTodayFlag=true,
	isRefresh=false,
	hasPullTask=false,
}

function acMidAutumnVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("midautumn")
	end
	return self.vo
end

function acMidAutumnVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end

function acMidAutumnVoApi:getTimeStr()
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

function acMidAutumnVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local activeTime = G_formatActiveDate(vo.et - base.serverTime)
		if self:isRewardTime()==false then
			activeTime=getlocal("notYetStr")
		end
		return getlocal("sendReward_title_time")..activeTime
	end
	return str
end

function acMidAutumnVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acMidAutumnVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acMidAutumnVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	local state=self:getFixedTaskState("gb")
	if state==2 then
		return true
	end
	local tasklist=self:getChangedTaskList()
	for k,v in pairs(tasklist) do
		local state=self:getChangedTaskState(k)
		if state==2 then
			return true
		end
	end
	-- local canReward=self:canRankReward()
	-- if canReward==true then
	-- 	return true
	-- end
	return false
end

--获取固定任务列表
function acMidAutumnVoApi:getFixedTaskList()
	local vo=self:getAcVo()
	if vo and vo.fixedTask then
		return vo.fixedTask
	end
	return {}
end

function acMidAutumnVoApi:getChangedTaskList()
	local vo=self:getAcVo()
	if vo and vo.changedTask then	
		return vo.changedTask
	end
	return {}
end

function acMidAutumnVoApi:getChangedTaskCfg()
	local vo=self:getAcVo()
	if vo and vo.changedTaskCfg then	
		return vo.changedTaskCfg
	end
	return {}
end

-- state:1：未完成，2：完成未领取，3：已领取
function acMidAutumnVoApi:getFixedTaskState(taskType, index)
	local function tableIndexof(array, value, begin)
	    for i = begin or 1, #array do
	        if array[i] == value then return i end
	    end
	    return false
	end

	index = index or 1
	local cur,max,state
	local task
	local taskList=self:getFixedTaskList()
	for k,v in pairs(taskList) do
		if v.key==taskType and k == index then
			task=v
			local vo=self:getAcVo()
			if vo then
				if v.key=="gu" then
					cur=0
					max=task.needNum
					state=1
				elseif v.key=="gb" then
					cur=vo.chargeCount or 0
					max=task.needNum
					if vo.rd and next(vo.rd) and tableIndexof(vo.rd, k) then
						state=3
					elseif cur>=max then
						state=2
					else
						state=1
					end
				end
			end
			do break end
		end
	end

	return state,cur,max
end

-- state:1：未完成，2：完成未领取，3：已领取
function acMidAutumnVoApi:getChangedTaskState(idx)
	local cur,max,state,level
	local isReachTop --四个达到顶级的任务
	local taskList=self:getChangedTaskList()
	local task=taskList[idx]
	if task and task[1] and task[2] and task[3] then
		local tType=task[1]
		level=task[2]
		max=task[3]
		cur=task[4]
		if cur==nil then
			cur=0
		end
		if cur==-1 then
			state=3
			cur=max
		elseif cur>=max then
			state=2
		else
			if tType=="au" then
				if accessoryVoApi:strengIsFull() then
					state=2
					isReachTop=true
				end
			elseif tType=="wp" then
				if superWeaponVoApi:isCanPlunder() then
					state=2
					isReachTop=true
				end
			elseif tType=="hu" then
				if heroEquipVoApi:isCanStreng() then
					state=2
					isReachTop=true
				end
			elseif tType=="rc" then
				if alienTechVoApi:isCanUpdate() then
					state=2
					isReachTop=true
				end
			end
			if state~=2 then
				state=1
			end
		end
	end
	if state==2 or state==3 then
		cur=max
	end
	return state,cur,max,level,isReachTop
end

function acMidAutumnVoApi:hasReward()
	local flag=false
	local vo=self:getAcVo()
	if vo and vo.fixedTask then
		for k,v in pairs(vo.fixedTask) do
			local state=self:getChangedTaskState(k)
			if state==2 then
				flag=true
				do break end
			end
		end
	end
	return flag
end

function acMidAutumnVoApi:getRefreshCost()
	local cost
	local vo=self:getAcVo()
	if vo and vo.change then
		cost=vo.change
	end
	return cost
end

function acMidAutumnVoApi:isFreeRefresh()
	local isFree=false
	local vo=self:getAcVo()
	if vo and (vo.r==nil or vo.r==0) then
		isFree=true
	end
	return isFree
end

function acMidAutumnVoApi:getRewardShowList()
	local rewardList={}
	local vo=self:getAcVo()
	if vo and vo.showList then
		rewardList=FormatItem(vo.showList,false,true)
	end
	return rewardList
end

function acMidAutumnVoApi:getOnceBlessPropCost()
	local cost={}
	local vo=self:getAcVo()
	if vo and vo.blessCost then
		cost=FormatItem(vo.blessCost,false,true)
	end
	return cost
end

function acMidAutumnVoApi:getMultiplier()
	local multiplier=10
	local vo=self:getAcVo()
	if vo and vo.multiplier then
		multiplier=tonumber(vo.multiplier)
	end
	return multiplier
end

-- 自己当前的任务点
function acMidAutumnVoApi:getBlessPoint()
	local vo=self:getAcVo()
	if vo and vo.blessPoint then
		return vo.blessPoint
	end
	return 0
end

function acMidAutumnVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
	activityVoApi:updateShowState(vo)
end

function acMidAutumnVoApi:getRankList()
	return self.rankList or {}
end

function acMidAutumnVoApi:setRankList(rank)
	if rank then
		if self.rankList==nil then
			self.rankList={}
		end
		self.rankList=rank
	end
end

function acMidAutumnVoApi:getRankReward()
	local reward={}
	local vo=self:getAcVo()
	if vo and vo.rankReward then
		reward=vo.rankReward
	end
	return reward
end

function acMidAutumnVoApi:getRankLimit()
	local rankLimit=100
	local vo=self:getAcVo()
	if vo and vo.rankLimit then
		rankLimit=vo.rankLimit
	end
	return rankLimit
end

function acMidAutumnVoApi:canRankReward()
	if self and self:acIsStop()==true then
		local rankList=self:getRankList()
		if rankList and SizeOfTable(rankList)>0 then
			for k,v in pairs(rankList) do
				if v and v[1] and tonumber(v[1])==playerVoApi:getUid() then
					local vo=self:getAcVo()
					if vo and vo.rankRewardFlag and vo.rankRewardFlag==1 then
						return false,2
					end
					return true,0,k
				end
			end
		end
	end
	return false,1
end

--活动所有请求数据处理
--taskType:领取任务奖励的任务key（对于那些玩家已经升到顶级无法完成的任务，需要给后台传任务key）
function acMidAutumnVoApi:midAutumnRequest(action,varArg,callback,isShowTip,taskType,gt)
	if action==1 then --刷新任务列表
		local function refreshTaskCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.midautumn then
	            	self:updateData(sData.data.midautumn)
	                if callback then
	                	callback(true)
	                end
	            end
	        else
	        	if callback then
	        		callback(false)
	        	end
	        end
	    end
		socketHelper:midAutumnRequest(action,varArg,nil,nil,nil,refreshTaskCallBack)
	elseif action==2 or action==3 or action==6 then --领取任务奖励,action==6 为领取排行榜奖励
		local function rewardCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.midautumn then
	            	self:updateData(sData.data.midautumn)
	            end
	      		if sData and sData.data and sData.data.reward then
			       	local award=FormatItem(sData.data.reward) or {}
					for k,v in pairs(award) do
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
					if isShowTip==nil then
						isShowTip=true
					end
					if isShowTip==true then
						G_showRewardTip(award)
					end
	      		end
	            if callback then
                	callback()
                end
	        end
	    end
	    if action==6 then
			socketHelper:midAutumnRequest(action,nil,nil,nil,varArg,rewardCallback)
	    else
			socketHelper:midAutumnRequest(action,nil,varArg,nil,nil,rewardCallback,taskType,gt)
	    end
	elseif action==4 then --抽奖
		local function rewardCallback(fn,data)
        	local oldHeroList=heroVoApi:getHeroList()
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.midautumn then
	            	self:updateData(sData.data.midautumn)
	            end
	            if callback then
	            	if sData and sData.data then
		            	if sData.data.report then
	                		callback(true,sData.data.report,oldHeroList)
	                	else
            				callback(false)
		            	end
		            else
            			callback(false)
	  	         	end
                end
            else
            	if callback then
            		callback(false)
            	end	
	        end
	    end
		socketHelper:midAutumnRequest(action,nil,nil,varArg,nil,rewardCallback)
	elseif action==5 then --获取抽奖日志
		local function logHandler(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.midautumn then
	            	self:updateData(sData.data.midautumn)
	            end
	      		if sData and sData.data and sData.data.log then
				   	if callback then
                		callback(true,sData.data.log)
                	end
                else
                	if callback then
                		callback(false)
                	end
	      		end  
	        end
	    end
		socketHelper:midAutumnRequest(action,nil,nil,nil,nil,logHandler)
	elseif action==7 then --获取排行榜数据
		local function listCallback(fn,data)
			local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data and sData.data.ranklist then
	            	local ranklist=sData.data.ranklist
	            	self:setRankList(ranklist)
	            	local inRank=false
	            	local uid=playerVoApi:getUid()
	             	for k,v in pairs(ranklist) do
	            		if uid==tonumber(v[1]) then
	            			-- self.selfRank.rank=k
	            			-- self.selfRank.name=v[2]
	            			-- self.selfRank.value=v[3]
	            			self.myRank=k
	            			inRank=true
	            			do break end
	            		end
	            	end
	            	if inRank==false then
	            		local myPoint=self:getBlessPoint()
	        --     		local rankStr=self:getNeedRank().."+"
    					-- self.selfRank.rank=rankStr
         --    			self.selfRank.name=playerVoApi:getPlayerName()
         --    			self.selfRank.value=myPoint
         				local rankLimit=self:getRankLimit()
         				if tonumber(myPoint)<tonumber(rankLimit) then
         					self.myRank=getlocal("dimensionalWar_out_of_rank")
         				else
	            			self.myRank=self:getNeedRank().."+"
         				end
	            	end
	                if callback then
	                	callback()
	                end
	            end
	        end
	    end
		socketHelper:midAutumnRequest(action,nil,nil,nil,varArg,listCallback)
	end
end

function acMidAutumnVoApi:getNeedRank()
	return 10
end

function acMidAutumnVoApi:getSelfRank()
	-- return self.selfRank
	return self.myRank
end

function acMidAutumnVoApi:sendRewardNotice(myRank)
	local rewardStr=""
    local rewards=acMidAutumnVoApi:getRankReward()
    for k,v in pairs(rewards) do
        local rank=v[1]
        if myRank>=rank[1] and myRank<=rank[2] then
            local reward=FormatItem(v[2],false,true)
            for k,v in pairs(reward) do
                if k==SizeOfTable(reward) then
                    rewardStr=rewardStr.."【"..v.name.."】"
                else
                    rewardStr=rewardStr.."【"..v.name.."】".. ","
                end
            end
        end
    end
    local playerName=playerVoApi:getPlayerName()
    local activityName=self:getVersion() == 3 and getlocal("activity_midautumn_v2_title") or getlocal("activity_midautumn_title")
    local message={key="activity_midautumn_notice",param={playerName,activityName,myRank,rewardStr}}
    chatVoApi:sendSystemMessage(message)
end

function acMidAutumnVoApi:getFlick()
	local vo=self:getAcVo()
	if vo and vo.flick then
		return vo.flick
	end
	return {}
end

function acMidAutumnVoApi:getRebelReward()
	local reward={}
	local vo=self:getAcVo()
	if vo and vo.rebelReward then
		reward=FormatItem(vo.rebelReward,false,true)
	end
	return reward
end

function acMidAutumnVoApi:isRefreshTask()
	return self.isRefresh	
end

function acMidAutumnVoApi:setRefreshTaskFlag(flag)
	self.isRefresh=flag
end

function acMidAutumnVoApi:getRankShowIndex()
	local index = 11
	local rankStr = "10+"
	local ranklist = self:getRankList()
	local uid = playerVoApi:getUid()
 	for k,v in pairs(ranklist) do
		if uid==tonumber(v[1]) then
			if k <= 10 then
				index = k
				rankStr = "" .. k
			end
			break
		end
	end

	return index, rankStr
end

function acMidAutumnVoApi:tick()
   --  --跨天刷新任务
   --  local isEnd=self:acIsStop()
   --  if isEnd==false then
   --  	if self.hasPullTask==false then
			-- local tasklist=self:getChangedTaskList()
			-- local taskCount=SizeOfTable(tasklist)
			-- if taskCount==0 then
	  --       	local function callback()
			-- 		self.hasPullTask=true
		 --        end
		 --        self:midAutumnRequest(1,0,callback)
			-- end
   --  	end
   --  end
    -- local todayFlag=self:isToday()
    -- if self.isTodayFlag==true and todayFlag==false and isEnd==false then
    --     self.isTodayFlag=false
    --     local function refreshTask()
    --         self.isRefresh=true
    --     end
    --     self:midAutumnRequest(1,0,refreshTask)
    -- end
end

function acMidAutumnVoApi:showSmallDialog(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi,btnStr,callback)	
	local sd=acChunjiepanshengSmallDialog:new()
	sd:init(isTouch,isuseami,layerNum,titleStr,bgSrc,dialogSize,bgRect,reward,isXiushi,btnStr,callback)
end

function acMidAutumnVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end

function acMidAutumnVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acMidAutumnVoApi:getChangeTaskLimit()
	local vo=self:getAcVo()
	if vo and vo.changeTaskLimit then	
		return vo.changeTaskLimit
	end
	return 0
end

function acMidAutumnVoApi:getGiftLimit()
	local vo=self:getAcVo()
	if vo and vo.giftLimit then	
		return vo.giftLimit
	end
	return 0
end

function acMidAutumnVoApi:getReValue()
	local vo=self:getAcVo()
	if vo and vo.re then	
		return vo.re
	end
	return 0
end

function acMidAutumnVoApi:getGuValue()
	local vo=self:getAcVo()
	if vo and vo.gu then	
		return vo.gu
	end
	return 0
end

--是否处于领奖时间
function acMidAutumnVoApi:isRewardTime()
	local vo = self:getAcVo()
	if vo then
		if base.serverTime > vo.acEt-86400 and base.serverTime < vo.acEt then
			return true
		end
	end
	return false
end

function acMidAutumnVoApi:clearAll()
	self.rankList={}
	-- self.selfRank={rank=0,name="",value=0}
	self.myRank="0"
	self.isRefresh=false
	self.isTodayFlag=true
	self.hasPullTask=false
	self.vo=nil
end

function acMidAutumnVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage2.plist")
    spriteController:addTexture("public/activeCommonImage2.png")
end
function acMidAutumnVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage2.plist")
    spriteController:removeTexture("public/activeCommonImage2.png")
end