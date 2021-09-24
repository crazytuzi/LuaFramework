--玩家自己每一轮的送花记录
serverWarTeamBetVo={}

function serverWarTeamBetVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarTeamBetVo:init(data)
	self.roundID=data[1]		--献花的轮次ID
	self.battleID=data[2]		--献花的场次ID
	self.allianceID=data[3]		--投注的军团ID
	self.times=data[4] or 0		--投注的次数
	self.hasGet=data[5]			--是否已经领取
end