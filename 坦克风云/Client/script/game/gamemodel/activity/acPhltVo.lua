acPhltVo=activityVo:new()
function acPhltVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acPhltVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if data.t then --上次抽奖时间，用于跨天
            self.t=data.t
        end
        if data.tbox then --兑换的数据
            self.tbox=data.tbox
        end
        if data.fn then --免费次数
            self.free=data.fn
        end
        if data.n then --熟练度
            self.n=data.n
        end
    end
end