localWarRankVo={}
function localWarRankVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.rank=0
    self.aid=0
    self.name=""
    self.point=0
    return nc
end

function localWarRankVo:initWithData(tb)
	if tb then
		if tb.rank then
			self.rank=tb.rank
		end
		if tb.aid then
			self.aid=tb.aid
		end
		if tb.name then
			self.name=tb.name
		end
		if tb.point then
			self.point=tb.point
		end
	end
end
