acYdczVo=activityVo:new()
function acYdczVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acYdczVo:updateSpecialData(data)
    if data~=nil then
    	--活动配置数据
     	if data._activeCfg then
     		self.activeCfg=data._activeCfg
     	end
     	--活动数据
        if data.l then --奖励升级档位
            self.rewardLv=data.l
        end
        if data.ts then --本月充值的月末时间戳
            self.EOM=data.ts
        end
        local lastRecharge = self.recharge or 0
        if data.n then --本月充值金额
            self.recharge=data.n
        end
        if data.r then --本月奖励发放的档位
            self.rid=data.r
        end
        if data.z then --上次充值时的服务器时区（为了解决冬令时，夏令时修改时区的问题）
            self.lastZone=data.z
        end
        if self.activeCfg then
            local flag=acYdczVoApi:isCurrentMonth()
            if flag==false then
                acYdczVoApi:reset()
            end
            if self.recharge and self.recharge>=self.activeCfg.recharge then --充值金额已达到，则主动更新发放奖励的档位
                if lastRecharge<self.activeCfg.recharge or self.rid==0 then
                    self.rid=(self.rewardLv or 1)
                end
                acYdczVoApi:setRebelBuffActive() --叛军天眼生效
            end
        end
    end
end

function acYdczVo:reset()
    self.EOM=G_getEOM()
    self.recharge=0
    self.rid=0
end