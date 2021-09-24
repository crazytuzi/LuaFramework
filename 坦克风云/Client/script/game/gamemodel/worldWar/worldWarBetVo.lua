--玩家自己每一轮的送花记录
worldWarBetVo={}

function worldWarBetVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function worldWarBetVo:init(data)
	self.type=data[1]			--1是NB赛, 2是SB赛
	self.roundID=data[2]		--献花的轮次ID
	self.battleID=data[3]		--献花的场次ID
	self.playerID=data[4]		--投注的选手ID
	self.times=data[5] or 0		--投注的次数
	self.hasGet=data[6]			--是否已经领取
end