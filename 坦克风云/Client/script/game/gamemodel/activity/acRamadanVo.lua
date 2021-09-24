acRamadanVo=activityVo:new()
function acRamadanVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acRamadanVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        -- if data.r then --各礼包数据
        --     self.r=data.r
        -- end
        --以下是三个奖励的领取标识
        if data.r1 then
            self.r1=data.r1
        end
        if data.r2 then
            self.r2=data.r2
        end
        if data.r3 then
            self.r3=data.r3
        end
        if data.v then --累计充值的金币数
            self.v=data.v
        end
    end
end