arenaVo={}
function arenaVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end


function arenaVo:initData(arenatb)
    if arenatb~=nil then
        for k,v in pairs(arenatb) do
            if v~=nil then

                self[k]=v
                -- print("初始化数据",k,v)
                if k=="rewardtime" then
                    -- print("领奖时间",k,v[1],v[2])
                end
                if k=="troops" then
                    tankVoApi:clearTanksTbByType(5)
                    for k,v in pairs(v) do
                        if v[1]~=nil and v[2]~=nil then
                            local tid=RemoveFirstChar(v[1])
                            tankVoApi:setTanksByType(5,k,tonumber(tid),v[2])
                        end
                    end
                end
            end
        end
    end

    if self.oldRanking ==nil or self.oldRanking == 0 then
        self.oldRanking = self.ranking or 0
    end
    
end