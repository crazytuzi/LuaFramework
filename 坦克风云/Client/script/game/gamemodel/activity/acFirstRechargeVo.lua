acFirstRechargeVo=activityVo:new()

function acFirstRechargeVo:updateSpecialData(data)
    if data.r then
    	self.r=data.r
    end

    if data.p then
    	self.p=data.p
    end

    if (self.c < 0 and self.r==nil) or (self.r and self.r==1) then
        self.over = true
        self.hasData = false
    end

    if data.totalPrice then
        self.totalPrice=data.totalPrice
    end
end