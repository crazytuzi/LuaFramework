localWarFeatRankVo={}
function localWarFeatRankVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.rank=0
    self.name=""
    self.power=0
    self.point=0
    return nc
end

function localWarFeatRankVo:initWithData(tb)
	if tb then
		if tb.rank then
			self.rank=tb.rank
		end
		if tb.name then
			self.name=tb.name
		end
		if tb.power then
			self.power=tonumber(tb.power)
		end
		if tb.point then
			self.point=tonumber(tb.point)
		end
	end
end
