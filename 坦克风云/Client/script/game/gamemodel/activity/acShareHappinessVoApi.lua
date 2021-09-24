acShareHappinessVoApi = {
    giftList=nil,
}

function acShareHappinessVoApi:getAcVo()
	return activityVoApi:getActivityVo("shareHappiness")
end

function acShareHappinessVoApi:gradeCfg()
	local  tmpStoreCfg=G_getPlatStoreCfg()
    local gold = tmpStoreCfg["gold"]
    return gold
end

-- 充值一共有多少个档次
function acShareHappinessVoApi:gradeNums()
	local cfg = self:gradeCfg() 
	if cfg ~= nil then
	    return SizeOfTable(cfg)
	end
	return 0
end

function acShareHappinessVoApi:getGrade(money)
	local cfg = self:gradeCfg() 
	if cfg ~= nil then
	    for k,v in pairs(cfg) do
	    	if tonumber(v) == tonumber(money) then
	    		return k
	    	end
	    end
	end
	return 0
end

function acShareHappinessVoApi:getAcCfg()
	local acVo = self:getAcVo()
    if acVo ~= nil then
    	return acVo.reward
    end
    return nil
end

function acShareHappinessVoApi:getReward(index)
	local cfg = self:getAcCfg()
	if cfg ~= nil then
		return cfg[index]
	end
	return nil
end

function acShareHappinessVoApi:getPropReward(index)
	local reward = self:getReward(index)
	if reward ~= nil then
		for k,v in pairs(reward.p[1]) do
			if k ~= "index" then
				return k,v
			end
		end
	end
	return nil,0
end

function acShareHappinessVoApi:canReward()
	local giftPackage = self:getGiftList()
	local len = 0
	if giftPackage ~= nil then
	   len = SizeOfTable(giftPackage)
	end
	if len > 0 then
		return true
	end
	return false
end

-- 当前处于哪个阶段
function acShareHappinessVoApi:getCurrentPhase()
	local vo = self:getAcVo()
	if vo and tonumber(vo.st) <= tonumber(base.serverTime) and tonumber(base.serverTime) >= tonumber(vo.acEt) and tonumber(base.serverTime) < tonumber(vo.et) then
    	return 2
    end
	return 1
end


-- 获取所有的可领取的礼包
function acShareHappinessVoApi:getGiftList()
	return self.giftList
end

function acShareHappinessVoApi:removeGift()
	if self.giftList ~= nil then
		for k,v in pairs(self.giftList) do
			if base.serverTime >= v.st + 86400 then
				table.remove(self.giftList,k)
			end
		end
		self:afterGiftListChanged()
	end
end

function acShareHappinessVoApi:addGift(gift)
	if gift ~= nil then
		if self.giftList == nil then
			self.giftList = {}
		end
		table.insert(self.giftList, gift)
		self:afterGiftListChanged()
	end
end

function acShareHappinessVoApi:updateListData(data)
	if data ~= nil then
        self.giftList = data
        self:afterGiftListChanged()
    end
end

function acShareHappinessVoApi:afterGiftListChanged()
	if self.giftList ~= nil then
		local function sortFunc(a,b)
			if tonumber(a.st) > tonumber(b.st) then
				return true
			end
			return false
		end
	    table.sort(self.giftList, sortFunc)

	    local len = SizeOfTable(self.giftList)
		if len > 50 then
			local moreLen = len - 50
			for i=1,moreLen do
				table.remove(self.giftList)
			end
		end
	end

    local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end
-- 玩家充值后为自己直接发放分享礼包，并且添加分享信息
function acShareHappinessVoApi:addGiftAfterRecharge(addMoney)
	if addMoney > 0 and self:getCurrentPhase() == 1 then
		local grade = self:getGrade(addMoney)
		local reward = self:getReward(tonumber(grade))
		if reward ~= nil then
		    local awardTab=FormatItem(reward,true)
		    for k,v in pairs(awardTab) do
		        G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num))
		    end
		    G_showRewardTip(awardTab, true)
		end
	end
end

function acShareHappinessVoApi:getGiftListFromServer(callback)
	local function getListSuccess(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	local acVo = self:getAcVo()
        	if acVo ~= nil then
        		self:updateListData(sData.data)
		        if callback ~= nil then
		        	callback()
		        end
		    end
        end

    end
    socketHelper:getShareHappinessList(getListSuccess,1)
end

