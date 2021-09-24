satelliteSearchVo={}

function satelliteSearchVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function satelliteSearchVo:updateNum(info,ts)
    if info.times2  then
        self.raidNum=tonumber(info.times2) -- 叛军定位次数
    end
    if info.times1 then
        self.goldNum=tonumber(info.times1) -- 金矿定位次数
    end
    if info.times then
        self.commonNum=tonumber(info.times) -- 普通目标定位次数
    end
    if info.times6 then
        self.omgn = tonumber(info.times6) --欧米伽小队定位次数
    end
    if ts then
        self.lastTime=ts
    end

end