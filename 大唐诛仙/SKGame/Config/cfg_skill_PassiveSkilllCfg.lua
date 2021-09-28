--[[
	un32PassiveSkillID:int#被动技能ID
	name:string#名称
	des:string#描述
	iconID:int#Icon
	level:int#等级
	levelMax:int#等级上限
	eReleaseWay:int#施放朝向
0 是 没有目标
1 是 有目标无锁
2 是 有目标锁定
3 是 自动
	n32UpgradeLevel:int#对应等级
	n32UseMP:int#消耗MP
	n32UseHP:int#消耗HP
	n32UseCP:int#消耗CP
	n32Cooldown:int#冷却时间
	eRangeType:int#射程触发类型
0 是 都可以使用
1 是 近战
2 是 远程
	lePassiveSkillTriggerType:int[]#触发条件
1 是 按时间
2 是 攻击时
3 是 受攻击
4 是 受击
5 是 死亡
6 是 技能攻击
7 是 技能使用
8 是 目标死亡
9 是 普攻之前
10 是 普攻之后
11 是 普攻伤害
12 是 技能伤害
13 是 移动
14 是 治疗时15 是 碰撞到技能释放者填是列表，格式如同：[ID1;ID2;ID3]
	n32TriggerRate:int#触发概率
	n32TriggerInterval:int#触发频率
	bIfAffectBuilding:int#对建筑有效
	bIfAffectRole:int#对角色有效
	bIfAffectMonster:int#对NPC有效
	ePassiveSkillTargetType:int#技能触发时所选择的目标类型
	bIfEffectOnDis:int#死亡是否移除
	asStartSkillModelList:int[]#被动挂载时触发的主动技能效果(启动被动技能状态的时候)
	asEndSkillModelList:int[]#被动卸载时触发的主动技能效果（消除被动技能状态的时候）
	asSkillModelList:int[]#触发后接续的主动技能效果
	lPassitiveEffectList:int[]#触发后接续的被动技能效果
	PassitiveRunningPartical:string[]#被动技能运行特效
	bIfHasStartEffect:int#是否具有启动特效
	PassitiveStartPartical:string[]#被动技能启动特效
	bIfHasReleaseEffect:int#是否具有触发特效
	PassitiveReleasePartical:string[]#被动技能触发特效
	bIfSendColdDown:int#是否向客户端发送冷却消息
]]

local cfg={
	[2170]={
		un32PassiveSkillID=2170,
		name="仙术",
		des="对冻伤状态的目标造成额外伤害",
		iconID=2170,
		level=1,
		levelMax=5,
		eReleaseWay=0,
		n32UpgradeLevel=0,
		n32UseMP=0,
		n32UseHP=0,
		n32UseCP=0,
		n32Cooldown=0,
		eRangeType=0,
		lePassiveSkillTriggerType={2},
		n32TriggerRate=100000,
		n32TriggerInterval=0,
		bIfAffectBuilding=2,
		bIfAffectRole=1,
		bIfAffectMonster=1,
		ePassiveSkillTargetType=2,
		bIfEffectOnDis=2,
		asStartSkillModelList={23},
		asEndSkillModelList={24},
		asSkillModelList={},
		lPassitiveEffectList={},
		PassitiveRunningPartical={},
		bIfHasStartEffect=0,
		PassitiveStartPartical={},
		bIfHasReleaseEffect=0,
		PassitiveReleasePartical={},
		bIfSendColdDown=0
	},
	[2180]={
		un32PassiveSkillID=2180,
		name="玲珑心",
		des="对冻伤、冰冻、减速抵抗概率提高",
		iconID=2180,
		level=1,
		levelMax=5,
		eReleaseWay=0,
		n32UpgradeLevel=0,
		n32UseMP=0,
		n32UseHP=0,
		n32UseCP=0,
		n32Cooldown=0,
		eRangeType=0,
		lePassiveSkillTriggerType={3},
		n32TriggerRate=100000,
		n32TriggerInterval=0,
		bIfAffectBuilding=2,
		bIfAffectRole=1,
		bIfAffectMonster=1,
		ePassiveSkillTargetType=2,
		bIfEffectOnDis=2,
		asStartSkillModelList={25},
		asEndSkillModelList={26},
		asSkillModelList={},
		lPassitiveEffectList={},
		PassitiveRunningPartical={},
		bIfHasStartEffect=0,
		PassitiveStartPartical={},
		bIfHasReleaseEffect=0,
		PassitiveReleasePartical={},
		bIfSendColdDown=0
	},
	[2190]={
		un32PassiveSkillID=2190,
		name="体魄",
		des="提高生命上限",
		iconID=2190,
		level=1,
		levelMax=5,
		eReleaseWay=0,
		n32UpgradeLevel=0,
		n32UseMP=0,
		n32UseHP=0,
		n32UseCP=0,
		n32Cooldown=0,
		eRangeType=0,
		lePassiveSkillTriggerType={},
		n32TriggerRate=100000,
		n32TriggerInterval=0,
		bIfAffectBuilding=2,
		bIfAffectRole=1,
		bIfAffectMonster=1,
		ePassiveSkillTargetType=1,
		bIfEffectOnDis=2,
		asStartSkillModelList={27},
		asEndSkillModelList={28},
		asSkillModelList={},
		lPassitiveEffectList={},
		PassitiveRunningPartical={},
		bIfHasStartEffect=0,
		PassitiveStartPartical={},
		bIfHasReleaseEffect=0,
		PassitiveReleasePartical={},
		bIfSendColdDown=0
	},
	[2200]={
		un32PassiveSkillID=2200,
		name="冰璃剑法",
		des="法术技能伤害提高，技能CD增加",
		iconID=2200,
		level=1,
		levelMax=5,
		eReleaseWay=0,
		n32UpgradeLevel=0,
		n32UseMP=0,
		n32UseHP=0,
		n32UseCP=0,
		n32Cooldown=0,
		eRangeType=0,
		lePassiveSkillTriggerType={},
		n32TriggerRate=100000,
		n32TriggerInterval=0,
		bIfAffectBuilding=2,
		bIfAffectRole=1,
		bIfAffectMonster=1,
		ePassiveSkillTargetType=1,
		bIfEffectOnDis=2,
		asStartSkillModelList={29},
		asEndSkillModelList={30},
		asSkillModelList={},
		lPassitiveEffectList={},
		PassitiveRunningPartical={},
		bIfHasStartEffect=0,
		PassitiveStartPartical={},
		bIfHasReleaseEffect=0,
		PassitiveReleasePartical={},
		bIfSendColdDown=0
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg