acGwkhVo=activityVo:new()

function acGwkhVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.hasReward=nil			--是否领取过奖励
	return nc
end

function acGwkhVo:updateSpecialData(data)
	if data then
		if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
		if data.atb then
			self.hasRewardTotal=data.atb
		end
		if data.dtb then
			self.hasRewardToday=data.dtb
		end
		if data.jdata then
			self.goldCost=data.jdata
		end
	end

end