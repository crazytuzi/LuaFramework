acPjgxVoApi = {
	name=nil,
}

function acPjgxVoApi:setActiveName(name)
	self.name=name
end

function acPjgxVoApi:getActiveName()
	return self.name or "pjgx"
end

function acPjgxVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acPjgxVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acPjgxVoApi:getTimeStr()
	local timeStr=""
	local vo=self:getAcVo()
	if vo then
		timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
	end
	return timeStr
end

function acPjgxVoApi:canReward(activeName)
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		local needPoint=vo.activeCfg.taskPoint
		for k,v in pairs(needPoint) do
			local flag=self:getLuckState(k)
			if flag==2 then
				return true
			end
		end
		local taskTb=self:getCurrentTaskState()
		for k,v in pairs(taskTb) do
			if v.index<1000 then
				return true
			end
		end
	end

	return false
end
function acPjgxVoApi:updateData(data)
	local vo=self:getAcVo()
	if vo then
		vo:updateData(data)
		activityVoApi:updateShowState(vo)
	end
end

function acPjgxVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

-- 1 未完成 2 可领取 3 已领取
function acPjgxVoApi:getLuckState(id)
	local acVo=self:getAcVo()
	if acVo then
		local needPoint=acVo.activeCfg.taskPoint
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

function acPjgxVoApi:getActiveCfg(activeName)
	local vo=self:getAcVo(activeName)
	if vo and vo.activeCfg then
		return vo.activeCfg
	end
	return {}
end

function acPjgxVoApi:getCurrentTaskState()
	local acVo=self:getAcVo()
	if acVo==nil or acVo.activeCfg==nil then
		return {}
	end
	local dailyTask=acVo.activeCfg.taskList
	local dayTb=acVo.task or {}
	local currentDayTb=dayTb
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
			local nf
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

				if typeStr=="au" then -- 配件强化
					if accessoryVoApi:strengIsFull() then
						index=k
						haveNum=needNum
						nf=true
					end
				elseif typeStr=="ge" then -- 配件改造
					if accessoryVoApi:rankIsFull() then
						index=k
						haveNum=needNum
						nf=true
					end
				end
			end
			-- 完成（已领取） index=v.index+10000
			-- 未完成 index=v.index+1000
			-- 可领取 index=v.index
			table.insert(taskTb,{index=index,value=v,haveNum=haveNum,nf=nf})
		end
		
	end

	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(taskTb,sortFunc)
	return taskTb
end

function acPjgxVoApi:getPoint()
	local vo=self:getAcVo()
	if vo and vo.myPoint then
		return vo.myPoint
	end
	return 0
end

function acPjgxVoApi:showRewardKu(title,layerNum,reward,desStr,titleColor)
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

function acPjgxVoApi:socketPjgx2017(refreshFunc,action,tid,type,num,nf)
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
				refreshFunc(num)
			end
		end
	end
	socketHelper:activityPjgx(callBack,action,tid,type,num,nf)
end

function acPjgxVoApi:showRewardDialog(rewardlist,layerNum,fqNum)
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

function acPjgxVoApi:getBn()
	local vo=self:getAcVo()
	if vo and vo.bn then
		return vo.bn
	end
	return 0
end

function acPjgxVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.bn=0
	vo.task={}
	vo.task.fin={}
	vo.task.tk={}

end

function acPjgxVoApi:addBuffScuess(activeName)
	local acVo = self:getAcVo(activeName)
	if activityVoApi:isStart(acVo)==true then
		return acVo.activeCfg.value1
	end
	return 0
end

function acPjgxVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acPjgxVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end


function acPjgxVoApi:clearAll()
	self.name=nil
end


