acKljzVoApi={
	taskListTb = {},--转换成id顺序的任务列表
}
function acKljzVoApi:clearAll()
	self.taskListTb = {}
	self.rewardLog = {}
end
function acKljzVoApi:getAcVo()
	return activityVoApi:getActivityVo("kljz")
end

function acKljzVoApi:getVersion( )
	local vo = self:getAcVo()
	if vo and vo.version then
		return vo.version
	end
	return 1 --默认
end
function acKljzVoApi:getLastTime( )
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		return vo.lastTime
	end
	return 0 
end

function acKljzVoApi:getTimer( )--倒计时 需要时时显示
	local vo=self:getAcVo()
	return G_formatActiveDate(vo.et - base.serverTime)
end
function acKljzVoApi:isToday()
	local isToday=false
	local vo = self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end

function acKljzVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateSpecialData(data)
	activityVoApi:updateShowState(vo)
end

function acKljzVoApi:canReward()
	-- local vo = self:getAcVo()
	-- print("time is ======>>>>",G_getWeeTs(vo.st))
	return false
end

function acKljzVoApi:getUsedStep( )---使用过的步数
	local vo = self:getAcVo()
	if vo and vo.usedStep then
		return vo.usedStep
	end
end
function acKljzVoApi:setUsedStep( newUsedStep )
	local vo = self:getAcVo()
	if vo and newUsedStep then
		vo.usedStep = newUsedStep
	end
end

function acKljzVoApi:getAllSteps( )---到当前为止获得的总步数
	local vo = self:getAcVo()
	if vo and vo.allSteps then

		return vo.allSteps,vo.allSteps - vo.usedStep
	end
end
function acKljzVoApi:setAllSteps( newAllSteps )
	local vo = self:getAcVo()
	if vo and newAllSteps then
		vo.allSteps = newAllSteps
	end
end

function acKljzVoApi:getMaxmovetimes( )---任务完成可拿到的最大奖励
	local vo = self:getAcVo()
	if vo and vo.maxmovetimes then
		return vo.maxmovetimes
	end
end

function acKljzVoApi:getModulTb( )
	local vo = self:getAcVo()
	local key="@acKljzVoApi@"
	local valueStr=CCUserDefault:sharedUserDefault():getStringForKey(key)
	if self:getUsedStep( ) == 0 or valueStr == "" then
		local cjson=G_Json.encode(vo.inimedallist)
		CCUserDefault:sharedUserDefault():setStringForKey(key,cjson)
		CCUserDefault:sharedUserDefault():flush()

	else
		vo.inimedallist = G_Json.decode(valueStr)
	end
	return vo.inimedallist	
end

function acKljzVoApi:setModulTb( newInimedallist )
	local key="@acKljzVoApi@"
	if newInimedallist then
		-- print("setModulTb~~~~~~")
		local cjson=G_Json.encode(newInimedallist)
		CCUserDefault:sharedUserDefault():setStringForKey(key,cjson)
		CCUserDefault:sharedUserDefault():flush()
	else
		local vo = self:getAcVo()
		local cjson=G_Json.encode(vo.inimedallist)
		CCUserDefault:sharedUserDefault():setStringForKey(key,cjson)
		CCUserDefault:sharedUserDefault():flush()
	end
end

------------------------------------------------ t  a  b  2 ------------------------------------------------------

function acKljzVoApi:getTaskTb( )
	local vo = self:getAcVo()
	if vo and vo.taskListTb and SizeOfTable(self.taskListTb) == 0 then
		for k,v in pairs(vo.taskListTb) do
			self.taskListTb[v.id] = v
		end
		return self.taskListTb
	elseif SizeOfTable(self.taskListTb) > 0 then
		local curTaskedTb = vo.curTaskedTb or {}
		local removeTaskTb = self.taskListTb
		local newTaskedTb = {}
		local completeTaskTb,uncompleteTaskTb = {},{}
		for k,v in pairs(removeTaskTb) do
			if curTaskedTb[v.qtype] and curTaskedTb[v.qtype] >= v.condition then
				table.insert(completeTaskTb,v)
			else
				table.insert(uncompleteTaskTb,v)
			end
		end

		for k,v in pairs(uncompleteTaskTb) do
			table.insert(newTaskedTb,v)
		end
		for k,v in pairs(completeTaskTb) do
			table.insert(newTaskedTb,v)
		end
		return newTaskedTb
	end
	return {}
end

function acKljzVoApi:getCurTaskedTb( )
	local vo = self:getAcVo()
	if vo and vo.curTaskedTb then
		local curStep = 0
		for k,v in pairs(vo.curTaskedTb) do
			if v >= vo.taskListTb[k].condition then
				curStep = curStep + vo.taskListTb[k].rewardtimes
			end
		end
		return vo.curTaskedTb,curStep
	end
end
function acKljzVoApi:setCurTaskedTb( newTaskedTb )
	local vo = self:getAcVo()
	if vo and newTaskedTb then
		vo.curTaskedTb = newTaskedTb
	else
		vo.curTaskedTb = {}--置空
	end
end

-------------------------------------------------t  a  b  1 ------------------------------------------------------
function acKljzVoApi:sendRewardNotice(cc)
    local playerName=playerVoApi:getPlayerName()
    local activityName=getlocal("activity_kljz_title")
    local btnNameTb = {"r","g","b"}
    local colorShow = getlocal("activity_kljz_bestBadge"..btnNameTb[cc])
    local message={key="activity_kljz_placard",param={playerName,activityName,colorShow}}

    if message then
    	local paramTab={}
		paramTab.functionStr="kljz"
		paramTab.addStr="i_also_want"
    	chatVoApi:sendSystemMessage(message,paramTab)
    end
end

function acKljzVoApi:getFlickList( )
	local acVo = self:getAcVo()
	if acVo and acVo.flickList then
		return acVo.flickList
	end
	return {}
end

function acKljzVoApi:getRewardPool()
	local acVo=self:getAcVo()
	if acVo and acVo.poolList then
		local awardTb = {}
		for k,v in pairs(acVo.poolList) do
			local formatTb = FormatItem(v,nil,true)
			table.insert(awardTb,formatTb)
		end
		return awardTb
	end
	print("error~~~~~------getRewardPool->>>>>>>")
	return {}
end
function acKljzVoApi:getOneBigAwardTb(idx )
	local acVo = self:getAcVo()
	if acVo and acVo.bigAwardTb then
		return FormatItem(acVo.bigAwardTb[idx],nil,true)
	end
	print("errro~~~~~~~~getOneBigAwardTb~~~~~~~")
	return {}
end

function acKljzVoApi:getRewardLog()
	return self.rewardLog
end
--格式化抽奖记录
function acKljzVoApi:formatLog(data,addFlag)
	local num=data[1][1]
	local rewards=data
	local rewardlist={}
	for k,v in pairs(rewards) do
			for i,j in pairs(v[2]) do
				local reward=FormatItem(j,nil,true)	
				table.insert(rewardlist,reward[1])
			end
	end
	local time=data[1][3] or base.serverTime
	-- local color=data[2][4] or 0
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

function acKljzVoApi:socketByCall(cmdStr,color,id,specialCall,freshCall)--cmdStr:"active.kljz.reward"   "active.kljz.getlog"
	local function getStepAwardCall(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
        	if sData and sData.data and sData.data.kljz then
        		self:updateData(sData.data.kljz)
        	end

			if sData.data.bigreward then --大奖励
				local rewards = sData.data.bigreward
				for i,j in pairs(rewards) do
						local reward=FormatItem(j[1],nil,true)
						for m,n in pairs(reward) do
							G_addPlayerAward(n.type,n.key,n.id,n.num,nil,true)
						end
				end
				local colorTb,newRewards = {},{}
				for i,j in pairs(rewards) do
					if colorTb[j[2]] then
						colorTb[j[2]] = colorTb[j[2]] + 1
						table.insert(newRewards[j[2]],j[1])
					else
						colorTb[j[2]] = 1
						newRewards[j[2]] = {}
						table.insert(newRewards[j[2]],j[1])
					end
				end

				if specialCall then
					for k,v in pairs(colorTb) do
						specialCall(k,true,newRewards[k])					
					end						
				end
			end

			if sData.data.reward then --奖励
				local rewards = {} 
				table.insert(rewards,sData.data.reward)

				for k,v in pairs(rewards) do
					local reward=FormatItem(v,nil,true)
					for m,n in pairs(reward) do
						G_addPlayerAward(n.type,n.key,n.id,n.num,nil,true)
					end
					G_showRewardTip(reward,true)					
				end
			end

        	if sData.data.log then --日志
				self.rewardLog={}
				for k,v in pairs(sData.data.log) do
					self:formatLog(v)
				end
				if specialCall then
					specialCall()
				end
			elseif SizeOfTable(sData.data) == 0 and specialCall then
				specialCall()
			end

			if freshCall then
				freshCall()
			end
        end
    end
    local params = G_Json.encode({color=color,id=id})
    socketHelper:acKljzRequest(cmdStr,G_encodeMap(params),getStepAwardCall)
end

function acKljzVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acKljzVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end
