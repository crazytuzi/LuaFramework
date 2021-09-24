--异次元战场的地块数据
dimensionalWarGroundVo={}

function dimensionalWarGroundVo:new(x,y,data)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.xIndex=x
	nc.yIndex=y
	nc.explode=tonumber(data[1]) or 0			--地块是否已经爆炸, 0正常，1将要爆炸，2已经爆炸
	nc.surviver=tonumber(data[2]) or 0			--地块上的幸存人数
	nc.zombie=tonumber(data[3]) or 0 			--地块上的僵尸人数
	nc.trap=tonumber(data[4]) or 0 				--地块上的陷阱数
	return nc
end

function dimensionalWarGroundVo:update(data)
	self.explode=tonumber(data[1]) or 0
	self.surviver=tonumber(data[2]) or 0
	self.zombie=tonumber(data[3]) or 0
	self.trap=tonumber(data[4]) or 0
end