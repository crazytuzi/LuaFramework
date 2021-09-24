--玩家自己每一轮的送花记录
serverWarPersonalBetVo={}

function serverWarPersonalBetVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarPersonalBetVo:init(data)
	self.roundID=data[1]		--献花的轮次ID
	self.groupID=data[2]		--给胜者组献花是1, 给败者组献花是2
	self.battleID=data[3]		--献花的场次ID
	self.playerID=data[4]		--投注的选手ID
	self.times=data[5] or 0		--投注的次数
	self.hasGet=data[6]			--是否已经领取
end