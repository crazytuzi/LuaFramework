--淘汰赛的数据
worldWarBattleVo={}
function worldWarBattleVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function worldWarBattleVo:init(data,player1,player2)
	self.id1=data[1]												--选手1的ID
	--选手1的数据
	if player1 then
		self.player1=player1
	else
		self.player1=worldWarVoApi:getPlayer(self.id1)
	end
	self.id2=data[2]												--选手2的ID
	--选手2的数据
	if player2 then
		self.player2=player2
	else
		self.player2=worldWarVoApi:getPlayer(self.id2)
	end
	self.winnerID=data[3]											--获胜者的ID
	if(self.winnerID==self.id1)then									--获胜者的数据
		self.winner=self.player1
	elseif(self.winnerID==self.id2)then
		self.winner=self.player2
	else
		self.winner=nil
	end
	self.resultTb=data[4] or {}										--比赛结果, 三局两胜, 每一局的获胜者ID
	if(data[5] and type(data[5])=="string") then
		self.landType=Split(data[5],",")
	else
		self.landType=data[5] or {}									--地形
	end	
	self.strategy=data[6] or {{1,2,3},{1,2,3}}						--此轮战斗的战术
	self.roundID=data[7]											--比赛所属的轮次
	self.battleID=data[8]											--比赛在组内的ID
	self.report={{},{},{}}											--3场战斗战报
	self.type=data[9] 												--类型，1大师，2精英

end