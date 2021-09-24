--跨平台战每一个战场城市的数据
platWarCityVo={}

function platWarCityVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

--初始化城市数据
function platWarCityVo:init(data)
	self.lineID=tonumber(data[3]) 				--是哪条线上的
	self.pointID=tonumber(data[4])	 			--是这条线上的第几个点
	self.hp=tonumber(data[1]) or 0				--血量
	self.side=tonumber(data[2]) or 0			--属于哪一方, 1是红方2是蓝方
	for k,v in pairs(platWarCfg.mapAttr.cityPos) do
		if(v==self.pointID)then
			self.type=platWarCfg.mapAttr.cityType[k]
			break
		end
	end
	--如果是血量为0的城市, 那么side不用后台传的城市数据, 而是使用线路数据自己算一下
	if(self.type==0)then
		local lineInfo=platWarVoApi:getLineList()[self.lineID]
		if(lineInfo)then
			if(lineInfo[1]>=self.pointID)then
				self.side=1
			elseif(lineInfo[2]<=self.pointID)then
				self.side=2
			else
				self.side=0
			end
		else
			self.side=0
		end
	end
	self.maxHp=platWarCfg.mapAttr["cityBlood"..self.type] or 0		--最大血量
end

function platWarCityVo:getIconName()
	if(self.type==0)then
		return "platWar_cityIcon1.png"
	elseif(self.type==1)then
		return "platWar_cityIcon1.png"
	else
		return "platWar_cityIcon2.png"
	end
end