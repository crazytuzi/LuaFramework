acGej2016VoApi = {
	name="",
	report={},
}

function acGej2016VoApi:setActiveName(name)
	self.name=name
end

function acGej2016VoApi:getActiveName()
	return self.name
end

function acGej2016VoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acGej2016VoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acGej2016VoApi:canReward(activeName)
	local flag=self:GetDailyBoxState(activeName)
	if flag==0 then
		return true
	end
	return self:checkTab1Tip(activeName)
end



function acGej2016VoApi:isFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acGej2016VoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acGej2016VoApi:getShop()
	local vo=self:getAcVo()
	return vo.activeCfg.shop
end

function acGej2016VoApi:getShopIndexTb()
	local vo=self:getAcVo()
	local shopIndexTb={}
	if vo and vo.activeCfg and vo.activeCfg.shop then
		local bLogTb=self:getB()
		local shop=vo.activeCfg.shop
		local num=SizeOfTable(shop)
		for i=1,num do
			local index=i
			local taskId="i" .. i
			if shop[taskId].limit then
				local limit=shop[taskId].limit
				local nowNum=bLogTb[taskId] or 0
				if nowNum>=limit then
					index=index+1000
				end
			end
			table.insert(shopIndexTb,{index=index,taskId=taskId})
		end
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(shopIndexTb,sortFunc)
	return shopIndexTb
end

function acGej2016VoApi:getPriceReward()
	local vo=self:getAcVo()
	return vo.activeCfg.reward
end

function acGej2016VoApi:getCurrentTaskState()
	local acVo=self:getAcVo()
	local dailyTask=acVo.activeCfg.dailyTask
	local trTb=acVo.tr or {}
	local tkTb=acVo.tk or {}

	local taskTb={}

	for k,v in pairs(dailyTask) do
		-- type
		local index=v.index+1000
		local flag1=false
		-- 是否领取
		for kk,vv in pairs(trTb) do
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
			haveNum=tkTb["t" .. v.type] or 0
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

	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(taskTb,sortFunc)
	return taskTb
end


-- 0 未领取  1 领取
function acGej2016VoApi:GetDailyBoxState(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.c then
		return acVo.c
	end
	return 0
end

-- 获得爱心值
function acGej2016VoApi:getV()
	local acVo=self:getAcVo()
	if acVo and acVo.v then
		return acVo.v
	end
	return 0
end

-- 获得爱心值
function acGej2016VoApi:getB()
	local acVo=self:getAcVo()
	if acVo and acVo.b then
		return acVo.b
	end
	return {}
end


function acGej2016VoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


function acGej2016VoApi:showRewardDialog(rewardlist,layerNum,fqNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	local rewardPromptStr=nil
	-- if fqNum and fqNum~=0 then
	-- 	rewardPromptStr=getlocal("activity_openyear_fetFQNum_des",{fqNum})
	-- end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false)
end

function acGej2016VoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
	vo.tr={}
	vo.tk={}
end

function acGej2016VoApi:socketGej2016(action,refreshFunc,tid)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			local reward={}
			if sData and sData.data and sData.data.reward then
				local item=FormatItem(sData.data.reward)
				for k,v in pairs(item) do
					table.insert(reward,v)
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
			end
			if refreshFunc then
				refreshFunc(reward)
			end
		end
	end
	socketHelper:activityGej2016(action,callBack,tid)

end

function acGej2016VoApi:checkTab1Tip(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo then
		if acVo.activeCfg and acVo.activeCfg.dailyTask then
			local dailyTask=acVo.activeCfg.dailyTask

			local trTb=acVo.tr or {}
			local tkTb=acVo.tk or {}

			for k,v in pairs(dailyTask) do
				local flag1=false
				-- 是否领取
				for kk,vv in pairs(trTb) do
					if vv==v.index then
						flag1=true -- 已领取
						break
					end
				end

				if not flag1 then
					-- 是否完成未领取
					local haveNum=tkTb["t" .. v.type] or 0 -- 已经完成的数量
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



function acGej2016VoApi:clearAll()
	self.name=""
	self.report={}
end


