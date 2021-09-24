--周年庆活动
acAnniversaryVoApi={}

function acAnniversaryVoApi:getAcVo()
	return activityVoApi:getActivityVo("anniversary")
end

function acAnniversaryVoApi:canReward()
	local acVo=self:getAcVo()
	if(acVo==nil)then
		return false
	end
	--如果游戏成就还没全领，就可以领奖
	if(acVo.gameReward and #acVo.gameReward<5)then
		return true
	end
	if(acVo.costCfg and acVo.costGem and acVo.costReward)then
		for k,v in pairs(acVo.costCfg) do
			if(acVo.costGem>v)then
				local flag=false
				for kk,vv in pairs(acVo.costReward) do
					if(vv==k)then
						flag=true
						break
					end
				end
				if(flag==false)then
					return true
				end
			end
		end
	end
	return false
end

--领奖
--param action: action=reward 是书的奖励, action=creward是消费的奖励
--param method: 要领取的是第几档奖励
function acAnniversaryVoApi:getReward(action,method,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.anniversary then
				local acVo=self:getAcVo()
				acVo:updateSpecialData(sData.data.anniversary)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:activityAnniversary(action,method,onRequestEnd)
end

--获取不同成就的描述
--param type: 1~5
function acAnniversaryVoApi:getTargetStr(type)
	if(type==1)then
		return getlocal("activity_anniversary_target1",{G_getDataTimeStr(playerVoApi:getRegdate(),true,false)})
	elseif(type==2)then
		if(playerVoApi:getPlayerAid() and playerVoApi:getPlayerAid()>0 and allianceVoApi:getSelfAlliance())then
			local allianceName=allianceVoApi:getSelfAlliance().name
			local joinTime=G_getDataTimeStr(allianceVoApi:getJoinTime(),true,false)
			return getlocal("activity_anniversary_target2",{joinTime,allianceName})
		else
			return getlocal("activity_anniversary_target2_1")
		end
	elseif(type==3)then
		local hours
		if(self:getAcVo().playTime>=3600)then
			hours=math.floor(self:getAcVo().playTime/3600)
		else
			hours=G_keepNumber(self:getAcVo().playTime/3600,2)
		end
		return getlocal("activity_anniversary_target3",{hours})
	elseif(type==4)then
		return getlocal("activity_anniversary_target4",{FormatNumber(self:getAcVo().rp)})
	elseif(type==5)then
		if(self:getAcVo().friendNum>0)then
			return getlocal("activity_anniversary_target5",{self:getAcVo().friendNum})
		else
			return getlocal("activity_anniversary_target5_1",{self:getAcVo().friendNum})
		end		
	else
		return ""
	end
end

function acAnniversaryVoApi:updateCostData()
	local acVo=self:getAcVo()
	if(acVo.lastBuy<G_getWeeTs(base.serverTime))then
		acVo.costGem=0
		acVo.costReward={}
	end
end