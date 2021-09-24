acPhltVoApi={
	rewardLog=nil
}

function acPhltVoApi:getAcVo()
	if self.vo==nil then
		self.vo=activityVoApi:getActivityVo("phlt")
	end
	return self.vo
end

function acPhltVoApi:getActiveName()
	return "phlt"
end

function acPhltVoApi:getVersion()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.version or 1
	end
	return 1 --默认
end

function acPhltVoApi:getTimeStr()
	local str=""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.acEt)
		str=getlocal("activity_timeLabel")..":".."\n"..timeStr
	end

	return str
end

function acPhltVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acPhltVoApi:isToday()
	local isToday=false
	local vo=self:getAcVo()
	if vo and vo.t then
		isToday=G_isToday(vo.t)
	end
	return isToday
end

function acPhltVoApi:canReward()
	local vo=self:getAcVo()
	if vo==nil then
		return false
	end
	local flag=self:canExchange()
	local isFree=0
	if self:isToday()==false then
		self:resetFreeLottery()
		isFree=self:isFreeLottery()
	end
	if flag==true or isFree==1 then
		return true
	end
	return false
end

function acPhltVoApi:getHexieReward()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg and base.hexieMode==1 then
		local hxcfg=acVo.activeCfg.hxcfg
		if hxcfg then
			return FormatItem(hxcfg.reward)[1]
		end
	end
	return nil
end

function acPhltVoApi:canExchange(isBigReward)
	local shop=self:getShop()
	local buyLog=self:getBuyBlog()
	local myPoint=self:getPoint()
	for k,v in pairs(shop) do
		local buyNum=buyLog[k] or 0
		if tonumber(v.needPt)<=myPoint and tonumber(buyNum)<tonumber(v.limit) then
			if isBigReward and isBigReward==true then
				if v.isflick and tonumber(v.isflick)==1 then
					return true
				end
			else
				return true
			end
		end
	end
	return false
end

function acPhltVoApi:getLotteryCost()
	local cost1,cost2=0,0
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		cost1=vo.activeCfg.cost
		cost2=vo.activeCfg.mulCost
	end
	return cost1,cost2
end

function acPhltVoApi:getMultiNum()
	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		return vo.activeCfg.mul or 5
	end
	return 5
end

function acPhltVoApi:resetFreeLottery()
	local vo=self:getAcVo()
	if vo and vo.free then
		vo.free=nil
	end
end

function acPhltVoApi:isFreeLottery()
	local flag=1
	local vo=self:getAcVo()
	if vo then
		if vo.free and vo.free>=1 then
			flag=0
		end
	end
	return flag
end

function acPhltVoApi:getRewardPool()
	local acVo=self:getAcVo()
	if acVo and acVo.activeCfg then
		return FormatItem(acVo.activeCfg.bShowList,nil,true),FormatItem(acVo.activeCfg.sShowList,nil,true)
	end
	return {},{}
end

function acPhltVoApi:getShop()
	local vo=self:getAcVo()
	if vo and vo.activeCfg and vo.activeCfg.shop then
		return vo.activeCfg.shop
	end
	return {}
end

function acPhltVoApi:getSortShop()
	local trueShop={}

	local vo=self:getAcVo()
	if vo and vo.activeCfg then
		local shop=self:getShop()
		local buyLog=self:getBuyBlog()
		local myPoint=self:getPoint()
		for k,v in pairs(shop) do
			local index=tonumber(RemoveFirstChar(k))
			local limit=v.limit
			local buyNum=buyLog[k] or 0
			if buyNum>=limit then
				index=index+10000
			elseif myPoint<v.needPt then
				index=index+1000
			end
			local subTb={index=index,id=k}
			table.insert(trueShop,subTb)
		end
		local function sortFunc(a,b)
			return a.index<b.index
		end
		table.sort(trueShop,sortFunc)
	end
	return trueShop
end

function acPhltVoApi:getPoint()
	local acVo=self:getAcVo()
	if acVo then
		return acVo.n or 0
	end
	return 0
end

function acPhltVoApi:getBuyBlog()
	local acVo=self:getAcVo()
	if acVo then
		return acVo.tbox or {}
	end
	return {}
end

--格式化抽奖记录
function acPhltVoApi:formatLog(data,addFlag)
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
	local time=data[3] or base.serverTime
	local point=data[4] or 0
	local succ=data[5] or 0
	local lcount=SizeOfTable(self.rewardLog)
	if lcount>=10 then
		for i=10,lcount do
			table.remove(self.rewardLog,i)
		end
	end
	if addFlag and addFlag==true then
    	table.insert(self.rewardLog,1,{num=num,reward=rewardlist,succ=succ,time=time,point=point})
	else
	    table.insert(self.rewardLog,{num=num,reward=rewardlist,succ=succ,time=time,point=point})
	end
end

function acPhltVoApi:getRewardLog()
	return self.rewardLog
end

function acPhltVoApi:acPhltRequest(args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				if sData.data.phlt then
					self:updateData(sData.data.phlt)
				end
				local rewardlist={}
				local num=1
				local point=0
				local hxReward
				if sData.data.clientReward then --奖励
					num=sData.data.clientReward[1]
					local rewards=sData.data.clientReward[2]
					for k,v in pairs(rewards) do
						local reward=FormatItem(v,nil,true)[1]
						table.insert(rewardlist,reward)
						G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
					end
					hxReward=self:getHexieReward()
					if hxReward then
						hxReward.num=hxReward.num*num
						G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
					end
					if self.rewardLog then
						self:formatLog(sData.data.clientReward,true)
					end
					point=sData.data.clientReward[4] or 0
				end
				if sData.data.log then --日志
					self.rewardLog={}
					for k,v in pairs(sData.data.log) do
						self:formatLog(v)
					end
				end
				local action=args.action
				if action and callback then
					if action==1 then
						if sData.data.big and sData.data.pt then --抽奖成功失败的数据
							callback(sData.data.big,sData.data.pt,point,rewardlist,hxReward)				
						end
					else
						callback()
					end
				end
				eventDispatcher:dispatchEvent("phlt.refreshTip",{})	
			end
		end
	end
	socketHelper:acPhltRequest(args,requestHandler)
end

function acPhltVoApi:addActivieIcon()
	spriteController:addPlist("public/activeCommonImage1.plist")
    spriteController:addTexture("public/activeCommonImage1.png")
end

function acPhltVoApi:removeActivieIcon()
	spriteController:removePlist("public/activeCommonImage1.plist")
    spriteController:removeTexture("public/activeCommonImage1.png")
end

function acPhltVoApi:isEnd()
	local vo=self:getAcVo()
	if vo and base.serverTime<vo.et then
		return false
	end
	return true
end

function acPhltVoApi:clearAll()
	self.rewardLog=nil
	self.vo=nil
end