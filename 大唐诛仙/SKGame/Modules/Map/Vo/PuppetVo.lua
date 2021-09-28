PuppetVo =BaseClass(LuaModel)
PuppetVo.Type = {
	NONE = 0, 
	NPC = 1,  --npc
	PLAYER = 2,--玩家
	MONSTER = 3, --怪物
	PET = 7,  --宠物
	Door = 5,  --传送门
	Collect =6, --采集
	Summon =4, --召唤兽
	DropItem = 8 , --掉落物品
}
function PuppetVo:__init()
	self.eid = 0 -- 实例id (玩家使用 playerId)
	self.guid = "" --1全局编号
	self.name = ""  --3单位名称
	self.type = PuppetVo.Type.NONE --4单位类型
	self.state = 0 --14单位状态
	self.position = Vector3.zero -- 15位置
	self.direction = Vector3.zero -- 16朝向

	self.hpMaxPanel = 0 -- 最大HP
	self.mpMaxPanel = 0 -- 最大MP
	self.p_attackPanel = 0 -- 物理攻击
	self.m_attackPanel = 0 -- 法术攻击
	self.p_damagePanel = 0 -- 物理防御
	self.m_damagePanel = 0 -- 法术防御
	self.critPanel = 0 -- 暴击
	self.toughPanel = 0 -- 韧性
	self.moveSpeedPanel = 0 -- 移动速度

	self.dmgDeepPer = 0 -- 伤害加深
	self.dmgReductPer = 0 -- 伤害减免
	self.dmgCritPer = 0 -- 伤害暴击
	self.strength = 0 -- 力量
	self.intelligence = 0 -- 智慧
	self.endurance = 0 -- 耐力
	self.spirit = 0 -- 灵力
	self.lucky = 0 -- 幸运
	self.battleValue = 0 -- 战斗力
	self.hp = 0 -- 当前HP
	self.mp = 0 -- 当前MP
	self.hpMax = 0 -- 当前最大HP
	self.mpMax = 0 -- 当前最大MP
	self.moveSpeed = 0 -- 当前移动速度
	
	self.level = 0 -- 等级
	
	self.mId = "" -- 模型资源 id
end

function PuppetVo:IsBoss()
	return self.monsterType == MonsterVo.Type.Boss
end
function PuppetVo:IsHuman()
	return self.type == PuppetVo.Type.PLAYER
end
function PuppetVo:IsMonster()
	return self.type == PuppetVo.Type.MONSTER
end
function PuppetVo:IsSummonThing()
	return self.type == PuppetVo.Type.Summon
end

function PuppetVo:UpdateSkill( vo )
	-- 待处理
end

function PuppetVo:__delete()
	self.type = PuppetVo.Type.NONE
end