acQmsdVo=activityVo:new()
function acQmsdVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acQmsdVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
   
    	if data.t then
    		self.lastTime =data.t
    	end
        
        if data.f then
            self.firstFree = data.f
        end

        if data.lh then
            self.chrisBoxes = data.lh
        end

        if data.tx then--是否已领取头像
            self.isGetedIcon = data.tx
        end

        if data.v then--个人当前充值数
            self.selfRechargeNums = data.v
        end
        if self.lastAllRechargeNums == nil then
            self.lastAllRechargeNums = 0
        end
        if data.c then--全服当前充值数
            if self.allRechargeNums then
                self.lastAllRechargeNums = self.allRechargeNums
            end
            self.allRechargeNums = data.c
        end

        if data.per then--个人当前已领奖记录
            self.selfGetedByGemsTb = data.per
        end
        if data.rd then--全服奖励 当前已领记录
            self.getedByGemsTb = data.rd
        end
    end
end