allianceGiftVo={}
function allianceGiftVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceGiftVo:initWithData(data)
    
	if data.agift then
		self.giftTb = data.agift
	end
	if not self.giftTb then
		self.giftTb = {}
	end

	if data.glevel then
		self.level = data.glevel
	end
	if not self.level then
		self.level = 1
	end

	if data.gexp then
		self.exp = data.gexp
	end
	if not self.exp then
		self.exp = 0
	end

end

function allianceGiftVo:clearGiftTb( )
	self.giftTb = {}
end