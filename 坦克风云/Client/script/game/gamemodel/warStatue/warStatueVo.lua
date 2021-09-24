warStatueVo={}

function warStatueVo:new(sid)
	local nc={
		sid=sid,
		hero={}, --激活的将领的数据
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function warStatueVo:initWithData(statue)
	if statue==nil then
		do return end
	end
	if statue then
		self.hero=statue
	end
end

function warStatueVo:updateData(statue)
	if statue then
		for k,v in pairs(statue) do
			self.hero[k]=v
		end
	end
end