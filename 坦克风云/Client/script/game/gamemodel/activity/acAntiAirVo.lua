--打飞机活动的vo
acAntiAirVo=activityVo:new()

function acAntiAirVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acAntiAirVo:updateSpecialData(data)
	if data.p then
		self.curShowList=data.p			--本次六个奖励的大小
	end
	if(data.r)then						 --本次已经抽到的奖励
		self.getRewardList={}
		for k,v in pairs(data.r) do
			local reward=v[1]
			local key=v[2]
			reward=FormatItem(reward)[1]
			self.getRewardList[key]=reward
		end
	end
	if(data.t)then
		self.resetTs=tonumber(data.t)	   --上次重置免费次数的时间戳
	end
	if(data.v)then
		self.freeUsed=tonumber(data.v)	  --免费次数是否已经用过
	end
	if(data.showList)then
		self.showList=FormatItem(data.showList,nil,true)		     --奖池
	end
    if(data.cost1)then                      --单抽价格
        self.cost1=tonumber(data.cost1)
    end
    if(data.cost2)then
        self.cost2=tonumber(data.cost2)     --连抽价格
    end
    if(data.flick)then
        self.flickerTb=data.flick           --带光圈的奖励
    end
end
