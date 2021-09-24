acWjdcVo=activityVo:new()
function acWjdcVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acWjdcVo:updateSpecialData(data)
    if data._activeCfg then
        self.activeCfg=data._activeCfg
    end

    --是否答题
	if data.v then
        self.v=tonumber(data.v)
    end
    if self.v==1 then
        self.over=true
    end

    if data.version then
    	self.version =data.version
    end

end
