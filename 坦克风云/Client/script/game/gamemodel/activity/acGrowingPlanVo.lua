acGrowingPlanVo=activityVo:new()
function acGrowingPlanVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acGrowingPlanVo:updateSpecialData(data)
    for k,v in pairs(data) do
        print("acGrowingPlanVo:updateSpecialData=",k,v)
    end
end