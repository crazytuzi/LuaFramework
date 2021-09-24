acSeikoStoneShopVo = activityVo:new()

function acSeikoStoneShopVo:new()
	local nc = {}

	nc.version=0 --当前版本
	nc.propsCfg={} --精工石商店购买道具的配置数据
	nc.exchangeData={} --当前已兑换道具的次数数据
	nc.buyItem=""--购买需要消耗的道具
	setmetatable(nc,self)
	self.__index = self

	return nc
end

--解析来自服务器的活动配置数据
function acSeikoStoneShopVo:updateSpecialData(data)
	if data then
		if data.version then
			self.version=data.version
		end
		if data.props then
			self.propsCfg=data.props
		end
		if data.buyitem then
			self.buyItem=data.buyitem
		end
		if data.items then
			self.exchangeData=data.items
		end
	end
end