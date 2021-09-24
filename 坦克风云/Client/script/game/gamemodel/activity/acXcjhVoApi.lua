-- @Author hj
-- @Description 新春聚惠数值处理模型
-- @Date 2018-12-20

acXcjhVoApi = {
	log = nil,
	bigNumber = {}
}

function acXcjhVoApi:getAcVo()
	return activityVoApi:getActivityVo("xcjh")
end
function acXcjhVoApi:getVersion(  )
	local vo = self:getAcVo()
    if vo and vo.activeCfg.version then
        return vo.activeCfg.version
    end
    return 1
end

function acXcjhVoApi:canReward()
	if  self:isGetRewardTime() == true then
		if self:getFirstFree() == 0  or self:taskRewad() == true  then
			return true
		end
	end
	return false
end

function acXcjhVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acXcjhVoApi:getActivePropImg(key)
	if key == "c1" or key == "c3" then
		if self:getVersion()==2 then
			return "ticket_v2.png"
		else
			return "ticket.png"
		end
	elseif key == "c2" or key == "c4" then
		if self:getVersion()==2 then
			return "resetTicket_v2.png"
		else
			return "resetTicket.png"
		end
	end
end

-- 任务是否有可领取奖励
function acXcjhVoApi:taskRewad( ... )
	local taskList = self:getTaskList()
	if taskList then
		for k,v in pairs(taskList) do
			if v.status == 1 then
				return true
			end
		end
	end
	return false
end
 
-- 任务列表
function acXcjhVoApi:getTaskList()

	local acVo = self:getAcVo()
	if acVo and acVo.taskList then
		for k,v in pairs(acVo.taskList) do
			v.curNum = self:getTr(v.id)
			v.status = self:isGetReward(v.id)
			if v.status == 2 and v.curNum >= v.needNum then
				v.status = 1
			end
		end

		local function sortFunc(a,b)
			if a.status ~= b.status then
				return a.status < b.status
			elseif a.id ~= b.id then
				return a.id < b.id 
			else
				return false
			end
		end

		table.sort(acVo.taskList,sortFunc)

		return acVo.taskList
	end

end

-- 跨天重置任务
function acXcjhVoApi:initTask( ... )

	local acVo = self:getAcVo()
	if acVo and acVo.tr  then
		for k,v in pairs(acVo.tr) do
			if k == "t4" then
				acVo.tr[k] = 1
			else
				acVo.tr[k] = 0
			end
		end
	end

	if acVo and acVo.status then
		acVo.status = {}
	end

end

function acXcjhVoApi:isGetReward(id)
	local acVo = self:getAcVo()
	if acVo and acVo.status then
		for k,v in pairs(acVo.status) do
			if v == id then
				return 3
			end
		end
	end
	return 2
end

function acXcjhVoApi:getTr(id)
	local key = "t"..id
	local acVo = self:getAcVo()
	if acVo and acVo.tr and acVo.tr[key] then
		-- if key == "t4" then
		-- 	return 1
		-- else
		-- 	return acVo.tr[key]
		-- end
		return acVo.tr[key]
	end
	return 0
end

-- 获取奖券数据
function acXcjhVoApi:getTicketList( ... )
	local ticketList = {}
	local acVo = self:getAcVo()
	if acVo and acVo.p then
		return acVo.p
	end
	return ticketList
end



function acXcjhVoApi:getStatus( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.status  then
		return acVo.status
	end
end

-- 获取不重复的随机数
function acXcjhVoApi:getRandom(num)
	if not num then
		num = 1
	end
	local randomArr = {}
	local resultArr = {}
	-- 16个抽奖位
	for i=1,16 do
		randomArr[i] = i
	end
	for i=1,num do
		local k = math.random(16-i+1)
		table.insert(resultArr,randomArr[k])
		local temp = randomArr[16-i+1]
		randomArr[16-i+1] = randomArr[k]
		randomArr[k] = temp
	end
	return resultArr
end

function acXcjhVoApi:hasRewardNum(number)
	local nowTicketNum = self:getTiketNumber()
	for k,v in pairs(nowTicketNum) do
		if v == number then
			return true
		end
	end
	return false
end

function acXcjhVoApi:getFirstFree( ... )
	
	local vo = self:getAcVo()
	-- if self:isToday() == false  then
	-- 	self:setFirstFree(0)
	-- end
	if self:isToday() == false and self:isGetRewardTime() == true then
		self:setFirstFree(0)
		-- self:initTask()
		vo.canRewardFlag = true 
    	vo.stateChanged = true  
	end

	if vo and vo.firstFree then
		return vo.firstFree
	end
	return 1

end

function acXcjhVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.lastTime then
		isToday=G_isToday(vo.lastTime)
	end
	return isToday
end


function acXcjhVoApi:setFirstFree(flag)
	local vo = self:getAcVo()
	if vo and vo.firstFree then
		vo.firstFree = flag
		-- acXcjhVoApi:initTask()
		-- vo.canRewardFlag = true 
  --   	vo.stateChanged = true  
	end
end

function acXcjhVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.hxcfg then
		local hxcfg=acVo.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

function acXcjhVoApi:getResetPropNum()
	local acVo=self:getAcVo()
	if acVo and acVo.ac2 then
		return acVo.ac2
	end
	return 0
end

function acXcjhVoApi:getAcNameAndDesc(key)

	if key == "c1" or key == "c3" then
		return getlocal("activity_xcjh_ticketName"),"activity_xcjh_ticketDesc"
	elseif key == "c2" or key == "c4" then
		return getlocal("activity_xcjh_resetTicketName"),"activity_xcjh_resetTicketDesc"
	end
end

-- 获取日志
function acXcjhVoApi:getLog(showlog)
	if self.log then
		showlog(self.log)
	else
		local function callback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then

				if sData.data and sData.data.log then
					self.log = {}
					for k,v in pairs(sData.data.log) do
						
						local rewardlist = {}
						local num=v[1]
						local rewards=v[2]
						local time=v[3] or base.serverTime
						local hxReward = self:getHexieReward()
						if hxReward then
							if num == 1 then
								table.insert(rewardlist,hxReward)
							elseif num == 5 then
								hxReward.num = hxReward.num * num
								table.insert(rewardlist,hxReward)
							end
						end
						for k,v in pairs(rewards) do
    						local reward = FormatItem(v,nil,true)[1]
							table.insert(rewardlist,reward)
						end

                    	local title = {getlocal("activity_xcjh_logtip",{num})}
                    	local content={{rewardlist}}
                    	local log={title=title,content=content,ts=time}

						table.insert(self.log,log)

					end
					showlog(self.log)
				end
			end
		end
		socketHelper:acXcjhGetLog(callback)
	end
end

-- 获取奖池
function acXcjhVoApi:getRewardPool()
	local vo = self:getAcVo()
	if vo and vo.pool  and vo.pool[1] then
		return vo.pool[1]
	end
end

-- 抽奖获取的log直接在前端加，不请求后台
function acXcjhVoApi:insertLog(title,content,time)
	if self.log then
		if #self.log < 10 then
			table.insert(self.log,1,{title=title,content=content,ts=time})
		else
			table.remove(self.log,10)
			table.insert(self.log,1,{title=title,content=content,ts=time})
		end
	end
end

function acXcjhVoApi:getTaskDay()
	local vo = self:getAcVo()
	if vo and vo.taskDay then
		return vo.taskDay
	end
	return 5
end

function acXcjhVoApi:isEnd( ... )
	local vo = self:getAcVo()
	if vo and vo.et then
		if base.serverTime >= vo.et - 86400 then
			return true
		end
	end
	return false
end

function acXcjhVoApi:getTimeStr( ... )

	local taskDay = self:getTaskDay()
	local str=""
	local vo=self:getAcVo()
	if vo and vo.st and vo.et then
		-- 防止配错,从开始时间计算
		local activeTime = vo.st + 86400*taskDay - base.serverTime > 0 and G_formatActiveDate(vo.st + 86400*taskDay - base.serverTime) or nil
		if activeTime==nil then
			activeTime=getlocal("serverwarteam_all_end")
		end
		return getlocal("activity_xcjh_activeRewardTime")..activeTime
	end
	return str
end

function acXcjhVoApi:getRewardTimeStr()
	
	local taskDay = self:getTaskDay()
	local str=""
	local vo=self:getAcVo()
	if vo and vo.st and vo.et then
		if base.serverTime > vo.st+86400*taskDay and base.serverTime < vo.et - 86400 then
			return getlocal("activity_xcjh_getRewardTime")..G_formatActiveDate(vo.et-86400-base.serverTime)
		elseif base.serverTime > vo.et - 86400 then
			return getlocal("activity_xcjh_getRewardTime")..getlocal("serverwarteam_all_end")
		else
			return getlocal("activity_xcjh_getRewardTime")..getlocal("notYetStr")
		end
	end
	return str
end

function acXcjhVoApi:isRewardCenterTime( ... )
	local vo=self:getAcVo()
	if vo and vo.et then
		if base.serverTime > vo.et-86400 and base.serverTime < vo.et then
			return true
		else
			return false
		end
	end
end

-- 是否是兑奖时间
function acXcjhVoApi:isRewardTime( ... )
	local taskDay = self:getTaskDay()
	local vo=self:getAcVo()
	if vo and vo.st and vo.et then
		if base.serverTime > vo.st + 86400*taskDay and base.serverTime < vo.et - 86400 then
			return true
		else
			return false
		end
	end
end

-- 是否是抽奖时间
function acXcjhVoApi:isGetRewardTime( ... )

	local taskDay = self:getTaskDay()
	local vo=self:getAcVo()
	if vo and vo.st and vo.et then
		if base.serverTime > vo.st and base.serverTime < vo.st + 86400*taskDay and base.serverTime < vo.et -86400 then
			return true
		else
			return false
		end
	end

end


function acXcjhVoApi:checkStatus(ticket)
	local day = self:getRewardDay()
	local quality = self:getSpRewardPicNum() + 1
	if #self.bigNumber >0 then
		for k,v in pairs(ticket) do
			for i=1,day do
				if v == self.bigNumber[i] then
					quality = quality - 1
					break
				end
			end
		end
	end
	return quality
end

function acXcjhVoApi:isSpeRewardTime( ... )
	
	local taskDay = self:getTaskDay()
	local vo=self:getAcVo()
	if vo and vo.st  then
		if base.serverTime >= vo.st + 86400*(taskDay-1)  and base.serverTime <= vo.st + 86400*taskDay and base.serverTime < vo.et -86400 then
			return true
		end
	end
	return false
end

function acXcjhVoApi:isCanupdate( ... )
	local ticketList = self:getTicketList()
	for k,v in pairs(ticketList) do
		if v[1] == 0 and self:checkStatus(v[2]) ~= 1 then
			return true
		end
	end
	return false
end

function acXcjhVoApi:getSpecialRewardNum(ticketList)
	local num = 0
	if ticketList  then
		for k,v in pairs(ticketList) do
			if self:checkStatus(v[2]) == 1 then
				num = num +1
			end
		end
	end
	return num
end

function acXcjhVoApi:getBigRewardNum()
	return self.bigNumber
end

function acXcjhVoApi:setBgigRewardNum(seq)
	self.bigNumber = seq
end

function acXcjhVoApi:getTiketNumber()
	local day = self:getRewardDay()
	local ticketList = {}
	if day and #self.bigNumber>0 and day<=#self.bigNumber then
		for i=1,day do
			table.insert(ticketList,self.bigNumber[i])
		end
	end
	return ticketList
end

function acXcjhVoApi:getRewardDay( ... )
	local spNum = acXcjhVoApi:getSpRewardPicNum()
	local acVo = self:getAcVo()
	if acVo and acVo.st then
		if base.serverTime > acVo.st and base.serverTime <= acVo.st+86400*spNum then
			local day
			-- 刚好是0点day的值就要加1
			if (base.serverTime-acVo.st)%86400 == 0 then
				day=(base.serverTime-acVo.st)/86400+1
			else
				day = math.ceil((base.serverTime-acVo.st)/86400)
			end
			return day
		elseif base.serverTime >= acVo.st+86400*spNum and base.serverTime < acVo.et - 86400 then
			return spNum
		end
	end
	return spNum
end

function acXcjhVoApi:getCanRewardNum( ... )
	local taskList = self:getTaskList()
	local num = 0
	for k,v in pairs(taskList) do
		if v.status == 1 then
			num = num + 1
		end
	end
	return num
end

-- function acXcjhVoApi:tick( ... )

-- 	if self:isToday() == false then
-- 		if self:isGetRewardTime() == true then
-- 			-- self:setLastTime()
-- 		end
-- 	end

-- end

-- function acXcjhVoApi:setLastTime( ... )
-- 	local vo=self:getAcVo()
-- 	if vo and vo.lastTime then
-- 		vo.lastTime = base.serverTime
-- 	end
-- end

function acXcjhVoApi:getSpRewardPicNum( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.spRewardPicNum then
		return acVo.spRewardPicNum
	end
end

function acXcjhVoApi:getSingleCost( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.cost then
		return acVo.cost
	end
end

function acXcjhVoApi:getMultiCost( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.multiCost then
		return acVo.multiCost
	end
end

function acXcjhVoApi:getReward( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.reward then
		return acVo.reward
	end
end

-- 根据中奖号码获取头像
function acXcjhVoApi:getTicketImgByNumber(id)
	if self:getVersion()==1 then
		return "acXcjhTicketNum"..id..".png"
	else
		local skinId
		if id==1 then
			skinId="s2"
		elseif id==2 then
			skinId="s3"
		elseif id==3 then
			skinId="s4"
		elseif id==4 then
			skinId="s5"
		elseif id==5 then
			skinId="s6"
		elseif id==6 then
			skinId="s7"
		elseif id==7 then
			skinId="s8"
		elseif id==8 then
			skinId="s9"
		elseif id==9 then
			skinId="s10"
		elseif id==10 then
			skinId="s11"
		else
			skinId="s12"
		end
		return skinId
	end
end

--坦克涂装加外边框
function acXcjhVoApi:tankSkinAddBg( skinId,size )
	if skinId then
		local tankSkinSp = CCSprite:createWithSpriteFrameName("tskin_bg1.png")
		local tankSkinIcon = CCSprite:createWithSpriteFrameName(tankSkinVoApi:getTankSkinIconPic(skinId))
		tankSkinIcon:setAnchorPoint(ccp(0.5,0.5))
		tankSkinIcon:setPosition(getCenterPoint(tankSkinSp))
		if size then
			tankSkinIcon:setScale((tankSkinSp:getContentSize().width-16)/tankSkinIcon:getContentSize().width)
			tankSkinSp:setScale(size/tankSkinSp:getContentSize().width)
		end
		tankSkinSp:addChild(tankSkinIcon)
		return tankSkinSp
	end
end

function acXcjhVoApi:clearAll( ... )
	self.log = nil
	self.bigNumber = {}
end

function acXcjhVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage3.plist")
	spriteController:addTexture("public/activeCommonImage3.png")
end

function acXcjhVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage3.plist")
	spriteController:removeTexture("public/activeCommonImage3.png")
end