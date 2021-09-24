acAutumnCarnivalVoApi = {}

function acAutumnCarnivalVoApi:getAcVo()
	return activityVoApi:getActivityVo("autumnCarnival")
end
function acAutumnCarnivalVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end
function acAutumnCarnivalVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end
function acAutumnCarnivalVoApi:getGiftCfgForShow()
	if self:isAutumn()==true then
		return activityCfg.autumnCarnival
	else
		return activityCfg.supplyIntercept
	end
end

function acAutumnCarnivalVoApi:getGiftCfgForShowByPid(pid)
	local cfg = self:getGiftCfgForShow()
	for k,v in pairs(cfg) do
		if k == pid then
			return v
		end
	end
	return nil
end

function acAutumnCarnivalVoApi:getSelfGifts()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.gifts
	end
	return nil
end

function acAutumnCarnivalVoApi:getGiftNum(pid)
	local gifts = self:getSelfGifts()
	if gifts ~= nil and type(gifts)=="table" then
		for k,v in pairs(gifts) do
			if k == pid then
				return v
			end
		end
	end
	return 0
end

function acAutumnCarnivalVoApi:openGift(pid,num)
	local hasNum = self:getGiftNum(pid)
	local acVo = self:getAcVo()
	if acVo and acVo.gifts and hasNum>=num then
		for k,v in pairs(acVo.gifts) do
			if k==pid then
				acVo.gifts[k] = v-num
			end
		end
	end

end

function acAutumnCarnivalVoApi:getChatCfg( ... )
	local acVo = self:getAcVo()
	if acVo and acVo.br then
		return acVo.br
	end
	return nil
end

function acAutumnCarnivalVoApi:isToChatMessegeByID(key,type)
	--br={p={p267,p89},}
	local chatCfg = self:getChatCfg()
	if chatCfg then
		for k,v in pairs(chatCfg) do
			if type==k and v then
				for m,n in pairs(v) do
					print(k,v,m,n)
					if n and n==key then
						return true
					end
				end
			end
		end
	end
	return false
end

--是否是中秋月饼版本 结束时间小于2014年9月10日0点 1410278400 返回为false 为通用版本
function acAutumnCarnivalVoApi:isAutumn()
	local acVo = self:getAcVo()
	if acVo and acVo.et then
		if acVo.et<=1410278400 then
			return true
		end
	end
	return false
end

function acAutumnCarnivalVoApi:canReward()
	local myGifts = self:getSelfGifts()
	local giftsCfg = self:getGiftCfgForShow()
	local canReward = false
	if myGifts and giftsCfg then
		for k,v in pairs(giftsCfg) do
			if myGifts[k] and myGifts[k]>0 then
				canReward = true
				return canReward
			end
		end
	end

	return canReward
end