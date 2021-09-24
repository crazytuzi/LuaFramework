ladderRankVo={}
function ladderRankVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.id=0			--用户或者军团id
    nc.score=0		--用户或者军团积分
    nc.name=""		--用户或者军团名称
    nc.fight=0		--用户或者军团战力
    nc.sid=0			--所在服务器id
    nc.rank=0			--排名
    nc.servername="" 	--服务器名称
    return nc
end

--  id,得分，名称，战力，区服
function ladderRankVo:initWithData(data,rank)
	self.rank=rank
	if data then
		if data[1] then
			self.id=data[1]
		end
		if data[2] then
			self.score=data[2]
		end
		if data[3] then
			self.name=data[3]
		end
		if data[4] then
			self.fight=data[4]
		end
		if data[5] then
			self.sid=data[5]
			self.servername=GetServerNameByID(self.sid)
		end
	end
end
