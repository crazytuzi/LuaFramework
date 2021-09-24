acCrystalYieldVo=activityVo:new()
function acCrystalYieldVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acCrystalYieldVo:updateSpecialData(data)
    for k,v in pairs(data) do
        print("acCrystalYieldVo:updateSpecialData=",k,v)
    end
    if data.d then
    	self.d=data.d
    end
end


