acNljjVoApi = {
	name="nljj",
	report={},
}

function acNljjVoApi:setActiveName(name)
	self.name="nljj"
end

function acNljjVoApi:getActiveName()
	return self.name
end

function acNljjVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acNljjVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acNljjVoApi:getRankReward()
	local acVo = self:getAcVo()
	if acVo and acVo.activeCfg then
		return acVo.activeCfg.rankReward
	end
	return {}
end

function acNljjVoApi:canReward(activeName)
	local flag=self:isDailyFree(activeName)

	local vo = self:getAcVo()
	if not vo.tipKey then--设置key
		self:setTipKey()
		vo.tipKeyInteger = CCUserDefault:sharedUserDefault():getIntegerForKey(vo.tipKey)
	end

	if flag==0 and self:acIsStop() == false then

		if vo.tipKeyInteger ~= 1 then
			CCUserDefault:sharedUserDefault():setIntegerForKey(vo.tipKey,1)--默认非领奖时间内 设置为 1
		    CCUserDefault:sharedUserDefault():flush()
		end

		return true
	elseif self:acIsStop() and vo.tipKeyInteger < 2 then
		return true
	end
	return false
end

function acNljjVoApi:setTipKey( )
	local vo = self:getAcVo()
	vo.tipKey = playerVoApi:getPlayerName()..playerVoApi:getUid().."nljj"
end
function acNljjVoApi:getTipKey(  )
	local vo = self:getAcVo()
	return vo.tipKey,vo.tipKeyInteger
end
function acNljjVoApi:afterExchange()
    local vo = self:getAcVo()

    CCUserDefault:sharedUserDefault():setIntegerForKey(vo.tipKey,2)-- 2 ： 玩家已领奖 或是非排行榜玩家已开过板子
    CCUserDefault:sharedUserDefault():flush()
    vo.tipKeyInteger = 2

    activityVoApi:updateShowState(vo)
    vo.stateChanged = true -- 强制更新数据
end

function acNljjVoApi:isFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime and G_isToday(acVo.lastTime)==false then
		return true
	else
		return false
	end
end

function acNljjVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acNljjVoApi:getCostByType(type)
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


-- 0 未领取  1 领取
function acNljjVoApi:isDailyFree(activeName)
	local acVo=self:getAcVo(activeName)
	if acVo.lastTime then
		if not G_isToday(acVo.lastTime) then
	        self:refreshClear(activeName)
	    end
	end
	if acVo and acVo.c then
		return acVo.c
	end
	return 0
end



function acNljjVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end


function acNljjVoApi:showRewardDialog(rewardlist,layerNum,rewardPromptStr,promptColor)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
	local titleStr=getlocal("activity_wheelFortune4_reward")
	local content={}
	for k,v in pairs(rewardlist) do
		table.insert(content,{award=v})                        
	end
	acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,nil,content,false,layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false,promptColor)
end

function acNljjVoApi:refreshClear(activeName)
	local vo=self:getAcVo(activeName)
	vo.lastTime=base.serverTime
	vo.c=0
end

function acNljjVoApi:socketNljj(cmd,rand,rank,refreshFunc)
	local lastPoint=self:getPoint()
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
				self:updateData(sData.data[self.name])
			end
			local reward={}
			local report
			if sData and sData.data and sData.data.report then
				report=sData.data.report
			end

			if rank then
				local vo=self:getAcVo()
				for k,v in pairs(vo.activeCfg.rankReward) do
					if rank>=v[1][1] and rank<=v[1][2] then
						local item=FormatItem(v[2],nil,true)
						for kk,vv in pairs(item) do
							table.insert(reward,vv)
							G_addPlayerAward(vv.type,vv.key,vv.id,vv.num,nil,true)
						end
						break
					end
				end
			else
				if sData and sData.data and sData.data.reward then
					local item=FormatItem(sData.data.reward)
					for k,v in pairs(item) do
						table.insert(reward,v)
						G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
				end
			end

			-- 设置log
			local nowPoint=self:getPoint()
			if rand then
				local oneReport={}
				oneReport[1]=1
				if rand==3 then
					oneReport[1]=10
				end
				oneReport[2]=sData.data.reward
				oneReport[3]=sData.ts
				oneReport[4]=nowPoint-lastPoint
				if self.report[self.name] and self.report[self.name]==1 then
					self:setLog(oneReport)
				end
			end

			if refreshFunc then
				refreshFunc(reward,report,nowPoint-lastPoint)
			end
		end
	end
	socketHelper:activityNljj(cmd,rand,rank,callBack)
end

function acNljjVoApi:getRewardTime()
	local vo=self:getAcVo()
	if vo and vo.et then
		return vo.et-24*3600,vo.et
	end
end

function acNljjVoApi:getRankRewardState()
	local acVo=self:getAcVo()
	if acVo and acVo.r then
		return acVo.r
	end
	return 0
end

function acNljjVoApi:acIsStop()
	local vo=self:getAcVo()
	if vo and base.serverTime<(vo.et-24*3600) then
		return false
	end
	return true
end


function acNljjVoApi:getPoint()
	local vo=self:getAcVo()
	if vo and vo.p then
		return vo.p
	end
	return 0
end

function acNljjVoApi:getV()
	local vo=self:getAcVo()
	if vo and vo.v then
		return vo.v
	end
	return 0
end

function acNljjVoApi:getPer()
	local vo=self:getAcVo()
	local powerLayer=vo.activeCfg.powerLayer
	local nowV=self:getV()
	local totalPer
	local lastPer
	local nowCent
	for k,v in pairs(powerLayer) do
		if nowV>=v[1] and nowV<=v[2] then
			totalPer=v[2]-v[1]
			nowCent=k
			if k~=1 then
				totalPer=totalPer+1
				lastPer=v[1]-1
			else
				lastPer=v[1]
			end
			break
		end
	end
	print("nowV,totalPer",nowV,totalPer)
	return math.floor((nowV-lastPer)/totalPer*100),nowCent
end

function acNljjVoApi:getRankLimit()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.rankLimit
	end
	return 500
end

function acNljjVoApi:getMyrank()
	local vo=self:getAcVo()
	local rank
	if vo and vo.ranklist then
		local uid=playerVoApi:getUid()
		for k,v in pairs(vo.ranklist) do
			if v[1]==uid then
				rank=k
			end
		end
	end
	return rank
end

function acNljjVoApi:socketRankList(cmd,refreshFunc)
	local function callBack(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:updateSpecialData(sData)
			end
			if sData and sData.data and sData.data[self.name] then
				self:updateSpecialData(sData.data[self.name])
			end

			if refreshFunc then
				refreshFunc()
			end
		end
	end
	local vo=self:getAcVo()

	if vo and vo.lastTs then
		local startT=self:getRewardTime()
		-- 结束是否调过排行榜(10秒延时)
		if vo.lastTs-startT>=0 then -- 是
			if refreshFunc then
				refreshFunc()
			end
			return
		elseif base.serverTime>startT then
			socketHelper:activityNljj(cmd,nil,nil,callBack)
			return
		end
	end
	socketHelper:activityNljj(cmd,nil,nil,callBack)
end

function acNljjVoApi:isReaward( )
	local score = self:getPoint()
	local playerList = self:getRankList()
	local uid = playerVoApi:getUid()
	for k,v in pairs(playerList) do
		-- print("v[2].......",v[2],playeName,v[3],score)
		if tonumber(v[1]) ==tonumber(uid) and tonumber(v[3]) ==score then
			-- self:setRank(k)
			return true
		end
	end
	return false
end

function acNljjVoApi:getRankList()
	local vo=self:getAcVo()
	if vo and vo.ranklist then
		return vo.ranklist
	end
	return {}
end

function acNljjVoApi:setLog(report)
	local acVo = self:getAcVo()
	if acVo.log==nil then
		acVo.log={}
	end
	table.insert(acVo.log,1,report)
	if SizeOfTable(acVo.log)>10 then
		table.remove(acVo.log)
	end
end

function acNljjVoApi:getLog(refreshFunc)
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
		local cmd="active.nengliangjiejing.getlog"
		socketHelper:activityNljj(cmd,nil,nil,callback)
	else
		if refreshFunc then
			refreshFunc()
		end
	end
end

function acNljjVoApi:showLogRecord(layerNum)
	local acVo = self:getAcVo()
	if acVo.log==nil or SizeOfTable(acVo.log)==0 then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_nljj_logcare"),30)
        do return end
	end

	local record={}
	for k,v in pairs(acVo.log) do
		local color=G_ColorWhite
		if v[1]==10 then
			color=G_ColorYellowPro
		end
		local desc=getlocal("activity_nljj_recordDes",{v[1],v[4]})
		local reward=FormatItem(v[2],nil,true)

		table.insert(record,{award=reward,time=v[3],desc=desc,colorTb={color}})
	end

    local function confirmHandler()
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),record,false,layerNum+1,confirmHandler,true,10,30,nil,nil,true)
end

function acNljjVoApi:showAllreward(layerNum)
	local acVo = self:getAcVo()
	if not acVo then
		return 
	end
	local record={}
	for k,v in pairs(acVo.activeCfg.reward) do

		local color=G_ColorWhite
		local desc=getlocal("activity_nljj_rewardDes",{k})
		local reward=FormatItem(v,nil,true)

		table.insert(record,{award=reward,time=nil,desc=desc,colorTb={color}})
	end

    local function confirmHandler()
    end
    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
    acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,736),CCRect(130, 50, 1, 1),getlocal("local_war_help_title9"),record,false,layerNum+1,confirmHandler,true,10,30,nil,true,true,true)
end

function acNljjVoApi:isAddHuangguang(key,num)
	local vo=self:getAcVo()
	local flick=vo.activeCfg.flick
	local filckItem=FormatItem(flick)
	for k,v in pairs(filckItem) do
		if v.key==key and v.num==num then
			return true
		end

	end
	return false
end

function acNljjVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt-86400)
		str=getlocal("activity_timeLabel").."\n"..timeStr
	end

	return str
end

function acNljjVoApi:getRewardTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local rewardTimeStr=activityVoApi:getActivityRewardTimeStr(vo.acEt-86400,60,86400)
		str=getlocal("recRewardTime").."\n"..rewardTimeStr
	end
	return str
end

function acNljjVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
	spriteController:addTexture("public/activeCommonImage1.png")
end

function acNljjVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
	spriteController:removeTexture("public/activeCommonImage1.png")
end

function acNljjVoApi:clearAll()
	self.report={}
end


