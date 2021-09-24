acNationalCampaignVo=activityVo:new()
function acNationalCampaignVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acNationalCampaignVo:updateSpecialData(data)
	if data.buy then
		self.buyCfg=data.buy
	end

	if self.hasBuyCfg==nil then 
		self.hasBuyCfg={}
	end

	if data.v and type(data.v)=="table" then
		self.hasBuyCfg=data.v
	end

	if data.destoryRate  then
		self.destoryRate =data.destoryRate 
	end
	if data.destoryRateDown  then
		self.destoryRateDown =data.destoryRateDown 
	end
	if data.expAdd  then
		self.expAdd =data.expAdd 
	end

end