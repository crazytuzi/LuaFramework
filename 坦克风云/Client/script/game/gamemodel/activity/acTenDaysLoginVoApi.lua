acTenDaysLoginVoApi={}

function acTenDaysLoginVoApi:getAcVo()
	return activityVoApi:getActivityVo("tendayslogin")
end

function acTenDaysLoginVoApi:getAllGiftsVo()
	local vo=self:getAcVo()
	return vo.allGiftsVo
end

function acTenDaysLoginVoApi:getNewGiftsVo(id)
	local gifts=self:getAllGiftsVo()
	for k,v in pairs(gifts) do
		if tostring(v.id)==tostring(id) then
			return v
		end
	end
	return {}
end

function acTenDaysLoginVoApi:getReward(day,callback)
	local function onRequestEnd(fn,data)
		if base:checkServerData(data)==true then
			local allGiftsVo=self:getAllGiftsVo()
			allGiftsVo[day].num=1
			local vo=self:getAcVo()
			activityVoApi:updateShowState(vo)
			local reward=FormatItem(activityCfg.tendaysLogin.award[day].award) or {}
			for k,v in pairs(reward) do
				G_addPlayerAward(v.type,v.key,v.id,v.num)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:activeTenDaysReward(day,onRequestEnd)
end

function acTenDaysLoginVoApi:getNewGiftsNum()
	local gifts=self:getAllGiftsVo()
	return SizeOfTable(gifts)
end

function acTenDaysLoginVoApi:getLoginDay()
	local dayNum=(G_getWeeTs(base.serverTime)-G_getWeeTs(playerVoApi:getRegdate()))/86400+1
	return dayNum
end

function acTenDaysLoginVoApi:canReward()
	local flag=0
	local hasFlag=0
	local removeFlag=1
	local gifts=self:getAllGiftsVo()
	local loginDay=self:getLoginDay()
	if gifts then
		for k,v in pairs(gifts) do
			if v and v.num<=0 then
				removeFlag=0
				if loginDay>=k then
					hasFlag=1
				end
			end
		end
		if removeFlag==1 then
			flag=false
		elseif hasFlag==1 then
			flag=true
		end
		return flag
	else
		return false
	end
end

function acTenDaysLoginVoApi:getAwardStr(id)
	local newGiftsVo = self:getNewGiftsVo(id)
	local awardTab = newGiftsVo.award
	local str = getlocal("daily_lotto_tip_10")
	if awardTab then
		for k,v in pairs(awardTab) do
			if k==SizeOfTable(awardTab) then
				str = str .. v.name .. " x" .. v.num
			else
				str = str .. v.name .. " x" .. v.num .. ","
			end
		end
	end
	return str
end