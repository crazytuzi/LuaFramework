acArmamentsUpdateVo=activityVo:new()
function acArmamentsUpdateVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acArmamentsUpdateVo:updateSpecialData(data)
    if data ~=nil then
    	
    end
end