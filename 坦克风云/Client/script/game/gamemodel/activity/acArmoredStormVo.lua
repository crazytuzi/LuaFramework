acArmoredStormVo=activityVo:new()
function acArmoredStormVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acArmoredStormVo:updateSpecialData(data)
       -- 配置
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end

    if data.t then -- 完成进度
        self.t1=data.t
    end
    if data.v then
        self.v=data.v
    end
    if data.r2 then -- 领取
        self.r2=data.r2
    end
    if data.r1 then
        self.r1=data.r1
    end

end