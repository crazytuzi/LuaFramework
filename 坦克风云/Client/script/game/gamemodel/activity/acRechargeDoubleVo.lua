acRechargeDoubleVo=activityVo:new()
function acRechargeDoubleVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.rewardTb={}		--领取双倍奖励的情况，e.g.: {"p50":0,"p8400":-8400,"p460":460}，key是p加上各个档次充值的金币数，value为0表示不可领取，value>0表示可领取，value<0表示已领取
	return nc
end

function acRechargeDoubleVo:updateSpecialData(data)
	local dataTb=data.d
	if(dataTb)then
		for k,v in pairs(dataTb) do
			self.rewardTb[k]=tonumber(v)
		end
	end
	-- local vo=activityVoApi:getActivityVo("firstRecharge")
	-- if(vo and vo.hasData==true and activityVoApi:isStart(vo))then
	-- 	self.over=true
	-- else
	-- 	self.over=false
	-- end
	local storeCfg=G_getPlatStoreCfg()
	local allGet=true
	for k,v in pairs(storeCfg.gold) do
		local key="p"..v
		if(self.rewardTb[key]==nil or self.rewardTb[key]>=0)then
			allGet=false
			break
		end
	end
	if(allGet==true)then
		self.over=true
	end

	if(eventDispatcher:hasEventHandler("activity.firstRechargeComplete",self.onActivityChangeListener)==false)then
		eventDispatcher:addEventListener("activity.firstRechargeComplete",self.onActivityChangeListener)
	end
end

function acRechargeDoubleVo:onActivityChangeListener(event,data)
	-- local vo=activityVoApi:getActivityVo("firstRecharge")
	-- local selfVo=acRechargeDoubleVoApi:getAcVo()
	-- if(vo and vo.hasData==true and activityVoApi:isStart(vo))then
	-- 	selfVo.over=true
	-- else
	-- 	selfVo.over=false
	-- end
end

function acRechargeDoubleVo:onRechargeSuccess(gem)
	if(self.rewardTb==nil)then
		do return end
	end
	if(gem and gem>0)then
		local key="p"..gem
		if(self.rewardTb[key]==nil or self.rewardTb[key]==0)then
			self.rewardTb[key]=tonumber(gem)
			activityVoApi:updateShowState(self)
		end
	end
end

function acRechargeDoubleVo:clear()
	eventDispatcher:removeEventListener("activity.firstRechargeComplete",self.onActivityChangeListener)
end
