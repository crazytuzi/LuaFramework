acStormRocketVo=activityVo:new()
function acStormRocketVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.lastTime=0
	self.partTb={}

	for i=1,acStormRocketVoApi.partNum do
		self.partTb[i]=0
	end
	return nc
end

function acStormRocketVo:updateSpecialData(data)
	if(data.d and data.d.ts)then
		self.lastTime=tonumber(data.d.ts)
	end
	if(data.t and type(data.t)=="table")then
		for i=1,acStormRocketVoApi.partNum do
			if(data.t["part"..i])then
				self.partTb[i]=tonumber(data.t["part"..i])
			else
				self.partTb[i]=0
			end
		end
	end
	if(data.reward)then
		local cfg=data.reward
		if(cfg.tankId)then
			acStormRocketVoApi.rewardTank=(tonumber(cfg.tankId) or tonumber(RemoveFirstChar(cfg.tankId)))
		end
		if(cfg.gemCost)then
			acStormRocketVoApi.gemCost=tonumber(cfg.gemCost)
		end
		if(cfg.gemCost_10)then
			acStormRocketVoApi.tuhaoCost=tonumber(cfg.gemCost_10)
		end
		if(cfg.buyGemCost)then
			acStormRocketVoApi.buyGemCost=tonumber(cfg.buyGemCost)
		end
		if(cfg.buyPartNum)then
			acStormRocketVoApi.buyPartNum=tonumber(cfg.buyPartNum)
		end
		if(cfg.vipMulti)then
			acStormRocketVoApi.vipMulti=cfg.vipMulti
		end
	end
end
