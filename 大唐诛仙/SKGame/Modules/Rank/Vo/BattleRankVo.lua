BattleRankVo =BaseClass(InnerEvent)

function BattleRankVo:__init()
	self.rank = 0			--排名
	self.playerId = 0		--玩家编号
	self.playerName = nil	--玩家名称
	self.career = 0			--玩家职业
	self.level = 0			--玩家等级
	self.guildName = 0		--公会名称
	self.value = 0			--战力
end

