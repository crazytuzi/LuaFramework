acHongchangyuebingVo=activityVo:new()
function acHongchangyuebingVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.lastTime=0
	self.partTb={}
	for i=1,acHongchangyuebingVoApi.partNum do
		self.partTb[i]=0
	end
	return nc
end

function acHongchangyuebingVo:updateSpecialData(data)
	if(data.d and data.d.ts)then
		self.lastTime=tonumber(data.d.ts)
	end
	if(data.t and type(data.t)=="table")then
		for i=1,acHongchangyuebingVoApi.partNum do
			if(data.t["part"..i])then
				self.partTb[i]=tonumber(data.t["part"..i])
			else
				self.partTb[i]=0
			end
		end
	end
	if(data.reward)then
		print(G_Json.encode(data.reward))
		local cfg=data.reward
		if(cfg.tankId)then
			acHongchangyuebingVoApi.rewardTank=(tonumber(cfg.tankId) or tonumber(RemoveFirstChar(cfg.tankId)))
		end
		if(cfg.gemCost)then
			acHongchangyuebingVoApi.gemCost=tonumber(cfg.gemCost)
			if(cfg.mulc)then
				acHongchangyuebingVoApi.tuhaoCost=tonumber(cfg.gemCost)*cfg.mulc
			end
		end
		
		if(cfg.buyGemCost)then
			acHongchangyuebingVoApi.buyGemCost=tonumber(cfg.buyGemCost)
		end
		if(cfg.buyPartNum)then
			acHongchangyuebingVoApi.buyPartNum=tonumber(cfg.buyPartNum)
		end
		if(cfg.vipMulti)then
			acHongchangyuebingVoApi.vipMulti=cfg.vipMulti
		end
		if data.version then
			self.version = data.version
		end
	end
	if data.report then
		self.tankActionData =data.report
	end
end