acZnkh2017VoApi = {
	name="",
}

function acZnkh2017VoApi:setActiveName(name)
	self.name=name
end

function acZnkh2017VoApi:getActiveName()
	return self.name
end

function acZnkh2017VoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	if activeName==nil or activeName=="" then
		activeName="znkh2017"
	end
	return activityVoApi:getActivityVo(activeName)
end

function acZnkh2017VoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acZnkh2017VoApi:getTimeStr()
	local timeStr=""
	local vo=self:getAcVo()
	if vo then
		timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	end
	return timeStr
end

function acZnkh2017VoApi:canReward(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.activeCfg then
		if self:isGetDailyReward()~=1 then
			return true
		end
		local vipLevel=playerVoApi:getVipLevel() or 0
		local needVip=acVo.activeCfg.needVip or 0
		if tonumber(vipLevel)>=tonumber(needVip) and tonumber(self:getV())~=1 then
			return true
		end
		local needPointCfg=acVo.activeCfg.needPoint or {}
		for k,v in pairs(needPointCfg) do
			local state=self:getLuckState(k)
			if state==2 then
				return true
			end
		end
	    local taskTb=self:getCurrentTaskState()
	    for k,v in pairs(taskTb) do
	    	if v.index<=1000 then
	    		return true
	    	end
	    end
	end
	return false
end

function acZnkh2017VoApi:getActiveCfg(activeName)
	local vo=self:getAcVo(activeName)
	if vo and vo.activeCfg then
		return vo.activeCfg
	end
	return {}
end

-- 1 未完成 2 可领取 3 已领取
function acZnkh2017VoApi:getLuckState(id)
	local acVo=self:getAcVo()
	if acVo then
		local needPoint=acVo.activeCfg.needPoint
		local tbox=acVo.tbox or {}
		local point=acVo.myPoint or 0
		if tbox["tb" .. id]==1 then
			return 3
		end

		if point>=(needPoint[id] or needPoint[#needPoint]) then
			return 2
		end
	end
	return 1
end

function acZnkh2017VoApi:showRewardKu(title,layerNum,reward,desStr,titleColor)
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

function acZnkh2017VoApi:showRewardDialog(rewardlist,layerNum,fqNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	local rewardPromptStr=nil
	if fqNum and fqNum~=0 then
		rewardPromptStr=getlocal("activity_openyear_fetFQNum_des",{fqNum})
	end
	local function callBack()
		G_showRewardTip(rewardlist)
	end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),callBack,nil,nil,nil,true,false,nil,true)
end

function acZnkh2017VoApi:socketZnkh2017(refreshFunc,action,day,tid,num,type)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			local rewardItem
			if sData and sData.data and sData.data.reward then
				local item=FormatItem(sData.data.reward)
				rewardItem=item
				for k,v in pairs(item) do
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
			end
			if refreshFunc then
				refreshFunc(rewardItem)
			end
			self:updateStateChanged()
		end
	end
	socketHelper:activeZnkh2017(callBack,action,day,tid,num,type)
	-- socketHelper:activityOpenyear(action,callBack,tid,count)

end

function acZnkh2017VoApi:updateStateChanged()
	local acVo=self:getAcVo()
	if acVo then
		activityVoApi:updateShowState(acVo)
	end
end

function acZnkh2017VoApi:getCurrentTaskState()
	local acVo=self:getAcVo()
	if acVo==nil or acVo.activeCfg==nil then
		return {}
	end
	local day=self:getTheDayOfActive()
	local dailyTask=acVo.activeCfg.taskList[day] or acVo.activeCfg.taskList[#acVo.activeCfg.taskList]
	local dayTb=acVo.day or {}
	local currentDayTb=dayTb["d" .. day] or {}
	local dfTb=currentDayTb.fin or {} -- 任务领取标志
	local dtTb=currentDayTb.tk or {}  -- 任务进度

	local taskTb={}

	for k,v in pairs(dailyTask) do
		-- type
		local typeStr=v[1][1]
		-- 军徽判断开关
		if (typeStr=="fb" and base.emblemSwitch~=1) or (typeStr=="fa" and base.isRebelOpen~=1) then
		else
			local index=k+1000
			local flag1=false
			-- 是否领取
			if dfTb["t" .. k]==1 then
				flag1=true
			end

			local haveNum -- 已经完成的数量
			if flag1 then
				index=k+10000
				haveNum=v[1][2]
			else
				-- 是否完成未领取
				
				haveNum=dtTb[typeStr] or 0
				local needNum=v[1][2]
				if haveNum>=needNum then
					index=k
					haveNum=needNum
				end
			end
			-- 完成（已领取） index=v.index+10000
			-- 未完成 index=v.index+1000
			-- 可领取 index=v.index
			table.insert(taskTb,{index=index,value=v,haveNum=haveNum})
		end
		
	end

	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(taskTb,sortFunc)
	return taskTb
end



function acZnkh2017VoApi:isFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acZnkh2017VoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acZnkh2017VoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


function acZnkh2017VoApi:refreshClear()
	local vo=self:getAcVo()
	if vo then
		vo.lastTime=base.serverTime
	end
end

function acZnkh2017VoApi:getTheDayOfActive()
	local vo=self:getAcVo()
	if vo then
		local weeTs=G_getWeeTs(vo.st)
		local currDay = math.floor(math.abs(base.serverTime-weeTs)/(24*3600)) + 1
		return currDay
	end
	return 1
end

function acZnkh2017VoApi:getV()
	local vo=self:getAcVo()
	if vo and vo.v then
		return vo.v
	end
	return 0
end

-- 是否领取当日奖励
function acZnkh2017VoApi:isGetDailyReward()
	local vo=self:getAcVo()
	if vo then
		local numDay=self:getTheDayOfActive()
		local dayTb=vo.day or {}
		local correntDay=dayTb["d" .. numDay] or {}
		if correntDay.gf then
			return correntDay.gf
		end	
	end
	return 0
end

function acZnkh2017VoApi:getPoint()
	local vo=self:getAcVo()
	if vo and vo.myPoint then
		return vo.myPoint
	end
	return 0
end

-- 得到累计抽奖次数和累计消耗金币数量
function acZnkh2017VoApi:getLnAndGems()
	local gems,ln=0,0
	local vo=self:getAcVo()
	if vo then
		gems=vo.gems or 0
		ln=vo.ln or 0
	end
	return ln,gems
end

function acZnkh2017VoApi:getLotteryPool()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.reward then
		local rewardlist=FormatItem(vo.activeCfg.reward,nil,true)
		return rewardlist
	end
	return {}
end

function acZnkh2017VoApi:getLotteryIdx(reward)
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.reward and reward then
		local rewardlist=FormatItem(vo.activeCfg.reward,nil,true)
		for k,v in pairs(rewardlist) do
			if v.type and v.num and v.key and reward.type and reward.num and reward.key then
				if v.type==reward.type and v.num==reward.num and v.key==reward.key then
					return k
				end
			end
		end
	end
	return nil
end

function acZnkh2017VoApi:getPlayerIcon()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.finalPrize then
		local iconItem=FormatItem(vo.activeCfg.finalPrize,nil,true)
		return iconItem
	end
	return nil
end

function acZnkh2017VoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acZnkh2017VoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end


function acZnkh2017VoApi:clearAll()
	self.name=""
end


