acFirstRechargenewVo=activityVo:new()

function acFirstRechargenewVo:updateSpecialData(data)
    if self.c < 0 then
        self.over = true
    else
        self.over = false
    end
    if data.pvalue then
    	self.pvalue=tonumber(data.pvalue) or 0
    end
end