--每场比赛的数据
serverWarTeamBattleVo={}

function serverWarTeamBattleVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function serverWarTeamBattleVo:init(data)
	self.id1=data[1]												--公会1的ID
	self.alliance1=serverWarTeamVoApi:getTeam(self.id1)				--公会1的数据
	self.id2=data[2]												--公会2的ID
	self.alliance2=serverWarTeamVoApi:getTeam(self.id2)				--公会2的数据
	self.winnerID=data[3]											--获胜者的ID
	if(self.winnerID==self.id1)then									--获胜者的数据
		self.winner=self.alliance1
	elseif(self.winnerID==self.id2)then
		self.winner=self.alliance2
	else
		self.winner=nil
	end
	self.roundID=data[4]											--比赛所属的轮次
	self.battleID=data[5]											--比赛在组内的ID, abcde...
end