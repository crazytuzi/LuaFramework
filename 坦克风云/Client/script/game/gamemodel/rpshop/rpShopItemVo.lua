rpShopItemVo={}
function rpShopItemVo:new(id,buyNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.id=id
	nc.buyNum=tonumber(buyNum)
	local type=string.sub(id,1,1)
	nc.type=type
	local shopCfg
	if(type=="i")then
		shopCfg=rpShopCfg.pShopItems
	else
		shopCfg=rpShopCfg.aShopItems
	end
	nc.cfg=shopCfg[id]
	if(nc.buyNum>nc.cfg.buynum)then
		nc.buyNum=nc.cfg.buynum
	end
	return nc
end

function rpShopItemVo:update(buyNum)
	self.buyNum=buyNum
	if(self.buyNum>self.cfg.buynum)then
		self.buyNum=self.cfg.buynum
	end
end