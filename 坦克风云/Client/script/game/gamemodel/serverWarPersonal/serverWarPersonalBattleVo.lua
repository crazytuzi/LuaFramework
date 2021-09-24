--每场比赛的数据
serverWarPersonalBattleVo={}
function serverWarPersonalBattleVo:new(roundID,groupID,battleID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.roundID=roundID											--比赛所属的轮次
	nc.groupID=groupID											--比赛是胜者组还是败者组
	nc.battleID=battleID										--比赛在组内的ID
	return nc
end

function serverWarPersonalBattleVo:init(data)
	self.id1=data[1]												--选手1的ID
	self.player1=serverWarPersonalVoApi:getPlayer(self.id1)			--选手1的数据
	self.id2=data[2]												--选手2的ID
	self.player2=serverWarPersonalVoApi:getPlayer(self.id2)			--选手2的数据
	self.winnerID=data[3]											--获胜者的ID
	if(self.winnerID=="")then
		self.winnerID=nil
	end
	if(self.winnerID==self.id1)then									--获胜者的数据
		self.winner=self.player1
	elseif(self.winnerID==self.id2)then
		self.winner=self.player2
	else
		self.winner=nil
	end
	self.resultTb=data[4] or {}										--比赛结果, 三局两胜, 每一局的获胜者ID
	if(self.resultTb=="")then
		self.resultTb={}
	end
	self.landformTb=data[5] or {}									--地形
	self.report={{},{},{}}											--3场战斗战报
end