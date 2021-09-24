acQxtwVoApi = {
	name="",
	report={},
	lastCheckTs=0,
}

function acQxtwVoApi:setActiveName(name)
	self.name=name
end

function acQxtwVoApi:getActiveName()
	return self.name
end

function acQxtwVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acQxtwVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acQxtwVoApi:canReward(activeName)
	local flag=self:isDailyFree(activeName)
	if flag==0 then
		return true
	end
	return self:checkTab2Tip(activeName)
end



function acQxtwVoApi:isFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acQxtwVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end


function acQxtwVoApi:getCurrentTaskState()
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
			if vv==k then
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
		table.insert(taskTb,{index=index,value=v,haveNum=haveNum,key=k})
	end

	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(taskTb,sortFunc)
	return taskTb
end

function acQxtwVoApi:getCostByType(type)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.activeCfg then
		if type==1 then
			return acVo.activeCfg.cost1
		else
			return acVo.activeCfg.cost2
		end
	end
	return 9999
end

-- 组装所需和所得
function acQxtwVoApi:getExchange()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		return acVo.activeCfg.exchange
	end
	return nil
end


-- 0 未领取  1 领取
function acQxtwVoApi:isDailyFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo and acVo.c then
		return acVo.c
	end
	return 0
end


function acQxtwVoApi:getMap()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		return acVo.activeCfg.map
	end
	return {}
end

function acQxtwVoApi:getGetKey(activeName)
	local acVo=self:getAcVo(activeName)
	local exchange=acVo.activeCfg.exchange
	local getkey
    for k,v in pairs(exchange.get[2]) do
        getkey=k
    end
    return getkey
end


function acQxtwVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


function acQxtwVoApi:showRewardDialog(rewardlist,layerNum,rewardPromptStr,promptColor)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false,promptColor)
end

function acQxtwVoApi:refreshClear()
	local vo=self:getAcVo()
	vo.lastTime=base.serverTime
	vo.c=0
	vo.tr={}
	vo.tk={}
end

function acQxtwVoApi:socketQxtw(cmd,rand,count,refreshFunc,tid)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end
			local reward={}
			local report
			if sData and sData.data and sData.data.report then
				report=sData.data.report
			end

			if sData and sData.data and sData.data.reward then
				local item=FormatItem(sData.data.reward)
				for k,v in pairs(item) do
					table.insert(reward,v)
					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
				end
			end

			-- 设置log
			if rand then
				local oneReport={}
				oneReport[1]=1
				if rand==3 then
					oneReport[1]=5
				end
				oneReport[2]=sData.data.reward
				oneReport[3]=sData.ts
				if self.report[self.name] and self.report[self.name]==1 then
					self:setLog(oneReport)
				end
			end
			if(cmd=="active.quanxiantuwei.checkqxtw")then
				self.lastCheckTs=base.serverTime
			end
			if refreshFunc then
				refreshFunc(reward,report)
			end
		end
	end
	socketHelper:activityQxtw(cmd,rand,count,callBack,tid)
end

function acQxtwVoApi:setLog(report)
	local acVo = self:getAcVo()
	if acVo.log==nil then
		acVo.log={}
	end
	table.insert(acVo.log,1,report)
	if SizeOfTable(acVo.log)>10 then
		table.remove(acVo.log)
	end
end

function acQxtwVoApi:emblemCompose(refreshFunc)
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
	local cmd="active.quanxiantuwei.change"
	socketHelper:activityQxtw(cmd,nil,1,callBack)
end

function acQxtwVoApi:getLog(refreshFunc)
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
		local cmd="active.quanxiantuwei.getlog"
		socketHelper:activityQxtw(cmd,nil,nil,callback)
	else
		if refreshFunc then
			refreshFunc()
		end
	end
end

function acQxtwVoApi:showLogRecord(layerNum)
	local acVo = self:getAcVo()
	if acVo.log==nil or SizeOfTable(acVo.log)==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_qxtw_logcare"),30)
        do return end
	end

	local record={}
	for k,v in pairs(acVo.log) do
		local color=G_ColorWhite
		local desc=getlocal("activity_qxtw_logdes",{v[1]})
		local reward=FormatItem(v[2],nil,true)

		table.insert(record,{award=reward,time=v[3],desc=desc,colorTb={color}})
	end

    local function confirmHandler()
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),record,false,layerNum+1,confirmHandler,false,10,30,nil,nil,true)
end

function acQxtwVoApi:showAllreward(layerNum)
	local acVo = self:getAcVo()
	if not acVo then
		return 
	end
	local record={}
	for k,v in pairs(acVo.activeCfg.reward) do

		local color=G_ColorWhite
		local desc=getlocal("activity_qxtw_rewardDes" .. k)
		local reward=FormatItem(v,nil,true)

		table.insert(record,{award=reward,time=nil,desc=desc,colorTb={color}})
	end

    local function confirmHandler()
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("local_war_help_title9"),record,false,layerNum+1,confirmHandler,true,10,30,nil,true,true)
end

function acQxtwVoApi:checkTab2Tip(activeName)
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
					if vv==k then
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

-- true 跳转第一个页签  false:军徽
function acQxtwVoApi:getGoFlag()
	local acVo=self:getAcVo()
	if acVo then
		if acVo.activeCfg and acVo.activeCfg.dailyTask then
			local dailyTask=acVo.activeCfg.dailyTask
			local trTb=acVo.tr or {}
			local tkTb=acVo.tk or {}
			local flag=false
			for k,v in pairs(dailyTask) do
				if v.type~=2 then
					local haveNum=tkTb["t" .. v.type] or 0 -- 已经完成的数量
					local needNum=v.needNum
					if needNum>haveNum then
						return false
					end
				else
					local haveNum=tkTb["t" .. v.type] or 0 -- 已经完成的数量
					local needNum=v.needNum
					if needNum>haveNum then
						flag=true
					end
				end
			end
			return flag
		end
	end

	return false
end

function acQxtwVoApi:isMustR()
	if base.mustmodel==1 and self:getMustMode() then
		return true
	else
		return false
	end
end

function acQxtwVoApi:getMustMode()
	local vo = self:getAcVo()
	if vo.activeCfg and vo.activeCfg.mustMode and tonumber(vo.activeCfg.mustMode)==1 then
		return true
	end
	return false
end

function acQxtwVoApi:getMustRewardByTag(tag)
	local vo = self:getAcVo()
	if tag==1 then
		return vo.activeCfg.mustReward1.reward
	else
		return vo.activeCfg.mustReward2.reward
	end

end

function acQxtwVoApi:showRewardSmallDialog(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreSmallDialog"    
    local dialog=acMineExploreSmallDialog:new()
    dialog:init(bgSrc,size,inRect,title,contentTb,tipStrTb,istouch,isuseami,layerNum,callBackHandler)
    return dialog
end

function acQxtwVoApi:rewardShowH(layerNum)
	local acVo = self:getAcVo()
	if not acVo then
		return 
	end
	local rewardList={}

	for i=#acVo.activeCfg.reward,1 ,-1 do
		local reward=acVo.activeCfg.reward[i]
		local rewardItem=FormatItem(reward,nil,true)
		for k,v in pairs(rewardItem) do
			table.insert(rewardList,v)
		end
	end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acLoversDaySmallDialog"
    acLoversDaySmallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(500,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("award"),getlocal("activity_qxtw_buyDesT"),true,layerNum,nil,rewardList,4,1,0.6)
end

function acQxtwVoApi:showLogRecordNew(layerNum,mustR1,mustR2)
	local acVo = self:getAcVo()
	if acVo.log==nil or SizeOfTable(acVo.log)==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_qxtw_logcare"),30)
        do return end
	end

	local recordList={}
	for k,v in pairs(acVo.log) do

		local color=G_ColorWhite
		local desc=getlocal("activity_qxtw_buyLogDes",{v[1]})
		local reward=FormatItem(v[2],nil,true)

		local record={}

		local item1={}
		item1[1]={}
		if v[1]==1 then
			item1[1][1] = mustR1
		else
			item1[1][1] = mustR2
		end
		item1[2] = getlocal("activity_mineexploreG_storeReward")
		item1[3] = G_ColorWhite
		table.insert(record,item1)

		local item2={}
		item2[1] = self:sortReward(reward)
		item2[2] = getlocal("activity_mineExploreG_otherReward")
		item2[3] = G_ColorWhite
		table.insert(record,item2)

		table.insert(recordList,{title={desc,G_ColorWhite},ts=v[3],content=record})
	end

    require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
    acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("buyLogTitle"),G_ColorYellowPro},recordList,false,layerNum,nil,true,10,false)
end

function acQxtwVoApi:sortReward(reward)
	local realReward=G_clone(reward)

	for k,v in pairs(realReward) do
		local index=self:getSortIndex(v.key)
		v.index=index
	end
	local function sortFunc(a,b)
        return a.index<b.index
    end
    table.sort(realReward,sortFunc)
	return realReward
end

function acQxtwVoApi:getSortIndex(key)
	local vo=self:getAcVo()
	if vo then
		if vo.activeCfg.reward and vo.activeCfg.reward then
			for ptype,ptb in pairs(vo.activeCfg.reward) do
				for ptype,bigValue in pairs(ptb) do
					for num,value in pairs(bigValue) do
						if value[key] then
							return value.index
						end
					end
				end
			end
		end
	end
	return 1
end

function acQxtwVoApi:getShowReport(eid)
	require "luascript/script/game/scene/tank/tankShowData"
	if  tankShowData and tankShowData[eid] then
		return tankShowData[eid]
	end
end

function acQxtwVoApi:clearAll()
	self.name=""
	self.report={}
	self.lastCheckTs=0
end


