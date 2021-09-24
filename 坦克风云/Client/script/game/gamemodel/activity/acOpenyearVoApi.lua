acOpenyearVoApi = {
	name="",
	report={},
	acShowType={TYPE_1=1,TYPE_2=2,TYPE_3=3}
}

function acOpenyearVoApi:setActiveName(name)
	self.name=name
end

function acOpenyearVoApi:getActiveName()
	return self.name
end

function acOpenyearVoApi:getAcShowType(activeName)
	local version = self:getVersion(activeName)
	if version==2 then
		return self.acShowType.TYPE_2
	elseif version == 3 then
		return self.acShowType.TYPE_3
	end
	return self.acShowType.TYPE_1
end

function acOpenyearVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acOpenyearVoApi:getVersion(activeName)
	local acVo = self:getAcVo(activeName)
	if acVo and acVo.activeCfg and acVo.activeCfg.version then
		return acVo.activeCfg.version
	end
	return 1
end

function acOpenyearVoApi:canReward(activeName)
	local flag=self:GetCommonFdState(activeName)
	if flag==0 then
		return true
	end
	flag=self:checkF(activeName)
	if flag then
		return true
	end
	flag=self:checkTab2Tip(activeName)
	if flag then
		return true
	end
	return self:checkTab3Tip(activeName)
end



function acOpenyearVoApi:isFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acOpenyearVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acOpenyearVoApi:getCurrentTaskState()
	local acVo=self:getAcVo()
	local dailyTask=acVo.activeCfg.dailyTask
	local dfTb=acVo.df or {}
	local dtTb=acVo.dt or {}

	local taskTb={}

	for k,v in pairs(dailyTask) do
		-- type

		-- 军徽判断开关
		if (v.key=="fb" and base.emblemSwitch~=1) or (v.key=="fa" and base.isRebelOpen~=1) then
		else
			local typeStr=v.key
			local index=v.index+1000
			local flag1=false
			-- 是否领取
			for kk,vv in pairs(dfTb) do
				if vv==v.index then
					flag1=true -- 已领取
					break
				end
			end

			local haveNum -- 已经完成的数量
			if flag1 then
				index=v.index+10000
				haveNum=v.needNum
			else
				-- 是否完成未领取
				haveNum=dtTb[v.key] or 0
				local needNum=v.needNum
				if haveNum>=needNum then
					index=v.index
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

-- 1 未完成 2 可领取 3 已领取
function acOpenyearVoApi:getRechargeState(id,activeName)
	local acVo=self:getAcVo(activeName)
	local needMoney=acVo.activeCfg.needMoney
	local rfTb=acVo.rf or {}
	local vNum=acVo.v or 0
	for k,v in pairs(rfTb) do
		if v==id then
			return 3
		end
	end
	if vNum>=needMoney[id] then
		return 2
	end
	return 1

end

-- 1 未完成 2 可领取 3 已领取
function acOpenyearVoApi:getLuckState(id)
	local acVo=self:getAcVo()
	local needLuck=acVo.activeCfg.needLuck
	local ffTb=acVo.ff or {}
	local fNum=acVo.f or 0
	for k,v in pairs(ffTb) do
		if v==id then
			return 3
		end
	end
	if fNum>=needLuck[id] then
		return 2
	end
	return 1

end

function acOpenyearVoApi:getNeedMoneyAndReward()
	local acVo=self:getAcVo()
	return acVo.activeCfg.needMoney,acVo.activeCfg.recharge
end

function acOpenyearVoApi:getLuckyAndBagReward()
	local acVo=self:getAcVo()
	return acVo.activeCfg.luckReward,acVo.activeCfg.needLuck,acVo.activeCfg.bagReward
end

-- 0 未领取  1 领取
function acOpenyearVoApi:GetCommonFdState(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.c then
		return acVo.c
	end
	return 0
end

-- 获得每种福包的数量
function acOpenyearVoApi:getP()
	local acVo=self:getAcVo()
	if acVo and acVo.p then
		return acVo.p
	end
	return {}
end

-- 获得福气值
function acOpenyearVoApi:getF()
	local acVo=self:getAcVo()
	if acVo and acVo.f then
		return acVo.f
	end
	return 0
end

-- 获得当前充值金币
function acOpenyearVoApi:getV()
	local acVo=self:getAcVo()
	if acVo and acVo.v then
		return acVo.v
	end
	return 0
end

function acOpenyearVoApi:setV(addMoney)
	local acVo=self:getAcVo()
	if acVo then
		acVo.v=(acVo.v or 0) + addMoney
		eventDispatcher:dispatchEvent("acOpenyear.recharge",{})
	end
end

function acOpenyearVoApi:socketOpenyear(action,refreshFunc,tid,count)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			local reward={}
			local fqNum=0
			if sData and sData.data and sData.data.report then
				local item=FormatItem(sData.data.report[1][1])
				for k,v in pairs(item) do
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					table.insert(reward,v)
				end
				
				fqNum=sData.data.report[1][2]
				if self.report[self.name] and self.report[self.name]==1 then
					for k,v in pairs(sData.data.report) do
						self:setLog(v)
					end
				end
			end
			if sData and sData.data and sData.data.reward then
				local item=FormatItem(sData.data.reward)
				
				for k,v in pairs(item) do
					table.insert(reward,v)
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
			end
			if sData and sData.data and sData.data.p then
				local ver = self:getVersion()
				for k,v in pairs(sData.data.p) do
					local sbRwarad = {p={{p3334=1,index=1}}}
					local item=FormatItem(sbRwarad)
					local resId=RemoveFirstChar(k)
					item[1].name= ver == 3 and getlocal("activity_openyear_fd_v2_title" .. resId) or getlocal("activity_openyear_fd_title" .. resId)
					item[1].desc=ver == 3 and "activity_openyear_fd_v2_des" .. resId or "activity_openyear_fd_des" .. resId
					item[1].num=v
					item[1].pic=ver == 3 and "openyear_v2_fd" .. resId .. ".png" or "openyear_fd" .. resId .. ".png"
					table.insert(reward,item[1])
				end
			end
			if refreshFunc then
				refreshFunc(reward,fqNum)
			end
		end
	end
	socketHelper:activityOpenyear(action,callBack,tid,count)

end

function acOpenyearVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end




function acOpenyearVoApi:getLog(refreshFunc)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.log then
				self:updateData(sData.data)
			end
			self.report[self.name]=1
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	if self.report[self.name]==nil then
		local action="getlog"
		socketHelper:activityOpenyear(action,callback)
	else
		if refreshFunc then
			refreshFunc()
		end
	end
end

function acOpenyearVoApi:showLogRecord(layerNum)
	local acVo = self:getAcVo()
	if acVo.log==nil or SizeOfTable(acVo.log)==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_openyear_noRecord"),30)
        do return end
	end
	local ver = self:getVersion()
	local record={}
	for k,v in pairs(acVo.log) do
		local color=G_ColorWhite
		local str = ver ==3 and getlocal("activity_openyear_fd_v2_title" .. v[3]) or getlocal("activity_openyear_fd_title" .. v[3])
		local desc=getlocal("activity_openyear_log_des",{str,v[2]})
		local reward=FormatItem(v[1],nil,true)

		table.insert(record,{award=reward,time=v[4],desc=desc,colorTb={color}})
	end

    local function confirmHandler()
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),record,false,layerNum+1,confirmHandler,true,10,nil,nil,nil,nil,nil,true)
end


function acOpenyearVoApi:setLog(report)
	local acVo = self:getAcVo()
	if acVo.log==nil then
		acVo.log={}
	end
	table.insert(acVo.log,1,report)
	if SizeOfTable(acVo.log)>10 then
		table.remove(acVo.log)
	end
	
end

function acOpenyearVoApi:showRewardDialog(rewardlist,layerNum,fqNum)
	-- require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,v)                        
	end
	local rewardPromptStr=nil
	local addStrTb = nil
	if fqNum and fqNum~=0 then
		rewardPromptStr=getlocal("activity_openyear_fetFQNum_des",{fqNum})
	end
	local function showEndHandler() end
	rewardShowSmallDialog:showNewReward(layerNum+1,true,true,rewardlist,showEndHandler,titleStr,rewardPromptStr,addStrTb,nil,"")
	-- acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false,nil,nil,true)
end

function acOpenyearVoApi:showRewardKu(title,layerNum,reward,desStr,titleColor)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acOpenyearSmallDialog"

    local height=540
    local tvHeight=250
    local rewardTb=FormatItem(reward[1])
    if SizeOfTable(rewardTb)<5 then
    	height=height-125
    	tvHeight=125
    end
    acOpenyearSmallDialog:showOpenyearRewardDialog("TankInforPanel.png",CCSizeMake(550,height),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,layerNum+1,reward,title,desStr,tvHeight,titleColor,true)
end

function acOpenyearVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
	vo.v=0
	vo.dt={}
	vo.df={}
	vo.rf={}
end


function acOpenyearVoApi:checkTab2Tip(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo then
		if acVo.activeCfg and acVo.activeCfg.needMoney then
			local needMoney=acVo.activeCfg.needMoney
			for k,v in pairs(needMoney) do
				local flag=self:getRechargeState(k,activeName)
				if flag==2 then
					return true
				end
			end
		end
	end
	return false
end

function acOpenyearVoApi:checkTab3Tip(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo then
		if acVo.activeCfg and acVo.activeCfg.dailyTask then
			local dailyTask=acVo.activeCfg.dailyTask
			local dfTb=acVo.df or {}
			local dtTb=acVo.dt or {}

			for k,v in pairs(dailyTask) do
				local flag1=false
				-- 是否领取
				for kk,vv in pairs(dfTb) do
					if vv==v.index then
						flag1=true -- 已领取
						break
					end
				end

				if not flag1 then
					-- 是否完成未领取
					local haveNum=dtTb[v.key] or 0 -- 已经完成的数量
					local needNum=v.needNum
					if haveNum>=needNum then
						return true
					end
				end
			end
		end
	end
	return false
end

function acOpenyearVoApi:checkF(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.activeCfg then
		local needLuck = acVo.activeCfg.needLuck
		local fNum=acVo.f
		local ffTb=acVo.ff or {}
		if needLuck and fNum and ffTb then
			local flagNum=SizeOfTable(needLuck)
			for k,v in pairs(needLuck) do
				if fNum<v then
					flagNum=k-1
					break
				end
			end
			if SizeOfTable(ffTb)<flagNum then
				return true
			end

		end

	end
	return false
end


function acOpenyearVoApi:clearAll()
	self.name=""
	self.report={}
end


