acChongzhisongliVo = activityVo:new()

function acChongzhisongliVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acChongzhisongliVo:updateSpecialData(data)
	if data~=nil then
		if data.v then
			self.alreadyCost =data.v --已充值的金币数 当天的
		end
		if data.reward then
			self.reward=data.reward  -- 奖励
		end
		if data.isreward then
			self.isreward = data.isreward -- 是否是大奖
		end
		if data.rule then
			self.rule = data.rule
		end
		if data.cost then
			self.cost = data.cost
		end

		if data.mark then
			self.hadAwardList =data.mark --领取过的列表
		end

		if data.flag then
			self.FlagList =data.flag --领过奖的标记列表
		end
	end
end