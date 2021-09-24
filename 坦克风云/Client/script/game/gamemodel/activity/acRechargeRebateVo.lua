acRechargeRebateVo=activityVo:new()

function acRechargeRebateVo:updateSpecialData(data)
	self.acEt=self.et
	
    if self.c < 0 then
        self.over = true
    else
        self.over = false
    end

    if self.discount==nil then
    	self.discount=activityCfg.rechargeRebate.discount
    end
    if data.reward then
        local award=FormatItem(data.reward)
        if award and award[1] and award[1].num then
        	self.discount=award[1].num
        end
    end

end