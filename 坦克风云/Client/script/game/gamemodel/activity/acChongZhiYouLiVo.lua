acChongZhiYouLiVo = activityVo:new()

function acChongZhiYouLiVo:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acChongZhiYouLiVo:updateSpecialData(data)
	if data.activeTitle then
		self.acName =data.activeTitle
	end
	if data.addGemCondition then --充值的金币数量(限制)
		self.rechargeMone = data.addGemCondition
	end
	if data.addGemsNum then --返还的金币数(限制)
		self.recMone =data.addGemsNum
	end
    if data.n then --最后一次领奖凌晨时间戳
    	self.hadRecTime = data.n
    end

    if data.v then --已充值的金币数
    	self.hadRechargeMone = data.v
    end

    if data.t then --重置充值金币的凌晨时间戳
    	self.lastTime = data.t
    end

    if self.addRechargeMone == nil then
    	self.addRechargeMone =0
    end
end
