bookmarkVo={}
function bookmarkVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function bookmarkVo:initWithData(id,type,name,x,y,t)
	self.id=id
	self.type=type
	self.name=name
	self.x=x
	self.y=y
	self.t = t or 0--t 时间戳，如果没有 默认赋值 0
end