platWarEventVo={}
function platWarEventVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function platWarEventVo:initWithData(id,type,time,message,width,height,color)
    self.id=id
	self.type=tonumber(type)
    self.time=tonumber(time) or 0
	self.message=tostring(message) or ""
	self.width=tonumber(width) or 0
	self.height=tonumber(height) or 0
    self.color=color
end