acDiscountVo=activityVo:new()

function acDiscountVo:updateSpecialData(data)
    if self.props == nil then
        self.props = {}
    end
	if data.props ~= nil then
    	self.props = data.props
    end

    if self.maxCount ==nil then
        self.maxCount = {}
    end
    if data.maxCount ~= nil then
    	self.maxCount = data.maxCount
    end
    if data.version ~= nil then
        self.version = data.version 
    end
end