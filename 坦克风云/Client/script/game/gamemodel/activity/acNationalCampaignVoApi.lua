acNationalCampaignVoApi={}

function acNationalCampaignVoApi:getAcVo()
	return activityVoApi:getActivityVo("nationalCampaign")
end

function acNationalCampaignVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acNationalCampaignVoApi:updateShow()
    local vo=self:getAcVo()
    activityVoApi:updateShowState(vo)
end


function acNationalCampaignVoApi:getDestoryRate()
	local acVo=self:getAcVo()
	if acVo and acVo.destoryRate then
		return acVo.destoryRate
	end
	return 0
end
function acNationalCampaignVoApi:getDestoryDownRate()
	local acVo=self:getAcVo()
	if acVo and acVo.destoryRateDown then
		return acVo.destoryRateDown
	end
	return 0
end

function acNationalCampaignVoApi:getExpAddRate()
	local acVo=self:getAcVo()
	if acVo and acVo.expAdd then
		return acVo.expAdd
	end
	return 0
end

function acNationalCampaignVoApi:getAcCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.buyCfg then
		return acVo.buyCfg
	end
	return {}
end

function acNationalCampaignVoApi:getGiftCfgByID(id)
	local cfg = acNationalCampaignVoApi:getAcCfg()
	if cfg and type(cfg)=="table" and SizeOfTable(cfg)>0 then
		for k,v in pairs(cfg) do
			if k == id and v then
				return v
			end
		end
	end
	return {}
end

function acNationalCampaignVoApi:getAcHasBuyCfg()
	local acVo=self:getAcVo()
	if acVo and acVo.hasBuyCfg then
		return acVo.hasBuyCfg
	end
	return {}
end
-- 根据id获取折扣礼包的已购买个数
function acNationalCampaignVoApi:getBuyCountById(pid)
	local acCfg = self:getAcHasBuyCfg()
	if acCfg ~= nil and type(acCfg)=="table" then
		for k,v in pairs(acCfg) do
			if k == pid and v and v[1] then
				return v[1]
			end
		end
	end
	return 0
end

function acNationalCampaignVoApi:addBuyCountById(pid)
	local acVo=self:getAcVo()
	local index = self:getUpdateIndex()
	local hadBuy = false
	if acVo and acVo.hasBuyCfg and type(acVo.hasBuyCfg)=="table" then
		for k,v in pairs(acVo.hasBuyCfg) do
			if k == pid then
				hadBuy=true
				if v then
					if v[2] and v[2]~=index then
						acVo.hasBuyCfg[k]={0,index}
					else
						local addNum = v[1]+1
						acVo.hasBuyCfg[k]={addNum,v[2]}
					end
				end
			end
		end

		if hadBuy==false then
			acVo.hasBuyCfg[pid]={1,index}
		end
	end
end
function acNationalCampaignVoApi:updateHadBuyNum()
	local acVo=self:getAcVo()
	local index = self:getUpdateIndex()
	local hadBuy = false
	if self.buyIDCfg and type(self.buyIDCfg)=="table" then
		for k,v in pairs(self.buyIDCfg) do
			if v then
				local giftCfg = self:getGiftCfgByID(v)
				if giftCfg then
					local pid = giftCfg.gift
					if acVo.hasBuyCfg[pid] and acVo.hasBuyCfg[pid][2] and acVo.hasBuyCfg[pid][2]==index then
					else
						acVo.hasBuyCfg[pid]={0,index}
					end 
				end
			end
		end
	end
end

function acNationalCampaignVoApi:setbuyIDCfg(data)
	self.buyIDCfg = data
end
function acNationalCampaignVoApi:getbuyIDCfg()
	return self.buyIDCfg
end

--刷新道具的次数
function acNationalCampaignVoApi:setUpdateIndex( index )
	self.updateIndex=index
end
function acNationalCampaignVoApi:getUpdateIndex()
	return self.updateIndex
end

--下次刷新道具的时间
function acNationalCampaignVoApi:setUpdateTime(time)
	self.updateTime=time
end
function acNationalCampaignVoApi:getUpdateTime()
	return self.updateTime
end

function acNationalCampaignVoApi:canReward()
	return false
end