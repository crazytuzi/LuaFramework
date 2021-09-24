eliteChallengeVo={}
function eliteChallengeVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function eliteChallengeVo:updateData(data)
	if data then
		-- 精英关卡总星
		if self.totalStar==nil then
			self.totalStar=0
		end
		if data.star then
			self.totalStar=tonumber(data.star) or 0
		end

		-- 上次重置的凌晨时间戳，第二天会根据此字段的值，自动重置resetnum为0,dailykill为{}
		if self.lastResetTime==nil then
			self.lastResetTime=0
		end
		if data.reset_at then
			self.lastResetTime=tonumber(data.reset_at) or 0
		end

		-- 今日重置次数，此数值是0时，不会返回此字段 ,请前台赋初值 0
		if self.resetnum==nil then
			self.resetnum=0
		end
		if data.resetnum then
			self.resetnum=tonumber(data.resetnum) or 0
		end
		
		-- 今日已通关的关卡，key是关卡id，请无视value值 ，此值是空table时，不会返回此字段，请前台赋上初始值 {}
		if self.dailykill==nil then
			self.dailykill={}
		end
		if data.dailykill then
			self.dailykill=data.dailykill or {}
		end

		-- 关卡对应的星星数
		if self.info==nil then
			self.info={}
		end
		if data.info then
			self.info=data.info or {}
		end
		
	end
end


