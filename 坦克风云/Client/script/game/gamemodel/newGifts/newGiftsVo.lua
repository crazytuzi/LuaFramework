newGiftsVo={}
function newGiftsVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function newGiftsVo:initWithData(id,num,award)
	self.id=id
	self.num=num
	self.award=award
end