acJunzipaisongVo=activityVo:new()
function acJunzipaisongVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acJunzipaisongVo:updateSpecialData(data)
	if data.version then
		self.version = data.version
	end
	if data.cost then
		self.cost = data.cost
	end
	if data.mulCost then
		self.mulCost = data.mulCost
	end
	if self.lastTime == nil then
		self.lastTime = 0
	end
	if data.t then
    	self.lastTime =data.t
    end

    if self.circleList == nil then
    	self.circleList = {}
    end
    if data.circleList ~=nil then
    	self.circleList = data.circleList
    end

    if self.showlist == nil then
    	self.showlist = {}
    end
    if data.showlist ~=nil then
    	self.showlist = data.showlist
    end
end
