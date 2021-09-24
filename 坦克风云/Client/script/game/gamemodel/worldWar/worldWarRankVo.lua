worldWarRankVo={}
function worldWarRankVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function worldWarRankVo:initWithData(id,name,server,rank,value,power)
	self.id=id
	self.name=name or ""
	self.server=server or ""
	self.rank=rank
	self.value=value or 0 --积分赛是排行分，淘汰赛是战力
	self.power=power or 0 --战力
end