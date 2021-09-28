-- 战斗vo
FightVo =BaseClass()
function FightVo:__init(msg)
	self.msg = msg or {} -- 战斗消息
	
	self.id = 0
	self.fightId = 0
	self.fightType = 0 --攻击类型
	self.fightDirection = 0 --攻击朝向
	self.fightTarget = 0 --攻击目标
	self.owherId = 0 --主人ID
	
	self.targetType = 0 --攻击目标类型 1玩家 2怪物 3伙伴
	self.targetId = 0 --目标唯一标识

	self.fighter = nil
	self.target = nil
	self.pos = nil
end

function FightVo.Clone( fightVo )
	local vo = FightVo.New()
	copyToClass(fightVo, vo)
	return vo
end
