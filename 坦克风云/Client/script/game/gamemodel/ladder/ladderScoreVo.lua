ladderScoreVo={}
function ladderScoreVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.rtype=1--1各种大战，2非战斗带排名，3非战斗没排名,5
    nc.r=1--跨服战类型
    nc.st=0--时间戳
    nc.score1=0--我的积分
    nc.score2=0
    nc.addscore1=0--我的变更积分
    nc.addscore2=0--对方变更积分
    nc.id1=0--我的id
    nc.id2=0
    nc.name1=""--我的名字
    nc.name2=nil--对方的名字,如果nil，说明对方轮空
    nc.sid1=0--服务器id
    nc.sid2=0
    nc.rank=0--我或者我的军团的排名
    nc.username=""--为军团赢得荣誉的玩家名称
    nc.nb=nil--1,轮空
    return nc
end

--个人天梯积分明细，warname:大战名称，name1:我的名称，name2:对方名称，score1:我的天梯分，score2:他的天梯积分，addscore1:我变更的积分，addscore2:对方变更的积分，st:时间
function ladderScoreVo:initWithData(data)
	if data and data.s then
		self.rtype=data.s
	end
	if data and data.r then
		self.r=data.r
	end
	if data and data.t then
		self.st=data.t
	end
	if data and data.v1 then
		self.score1=data.v1
	end
	if data and data.v2 then
		self.score2=data.v2
	end
	if data and data.id1 then
		self.id1=data.id1
	end
	if data and data.id2 then
		self.id2=data.id2
	end
	if data and data.n1 then
		self.name1=data.n1
	end
	if data and data.n1 then
		self.username=data.n1
	end
	if data and data.n2 then
		self.name2=data.n2
	end
	if data and data.z1 then
		self.sid1=data.z1
	end
	if data and data.z2 then
		self.sid2=data.z2
	end
	if data and data.add1 then
		self.addscore1=data.add1
		if tostring(self.addscore1)=="-0" then
			self.addscore1=0
		end
	end
	if data and data.add2 then
		self.addscore2=data.add2
		if tostring(self.addscore2)=="-0" then
			self.addscore2=0
		end
	end
	if data and data.r1 then
		self.rank=data.r1
	end
	if data and data.nb then
		self.nb=data.nb
	end
end
