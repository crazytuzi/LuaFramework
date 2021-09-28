--[[
	un32SkillModelID:int#技能模块id
	eSkillModelType:int#技能类型
1  =  结算类技能模块
2  =  发射类技能模块
3  =  范围类技能模块
4  =  引导类技能模块
5  =  召唤物类技能模块
6  =  位移类技能模块
7  =  开关类技能模块
8  =  洗净类技能模块
9  =  链接类技能模块
10 =  Buffer类技能模块
	bIsCoolDown:int#是否开始计算CD
	n32TriggerRate:int#触发概率
	bIfAffectBuilding:int#对建筑有效
	bIfAffectRole:int#对角色有效
	bIfAffectMonster:int#对NPC有效
	bIsCanMove:int#是否可以在效果维持阶段移动
	bIsCanBreak:int#是否可以被其他的动作打断
	eTargetType:int#目标类型
1 = 自己
2  = 敌人
3  = 所有单位
	eBuffTarget:int#buff的目标对象
1 = 自己
2 = 目标
0 = 没有
	n32ReleaseTimeDelay:int#释放时间
	asSkillModelList:int[]#下层模块技能效果列表
	n32UseMp:int#消耗MP
	n32UseHp:int#消耗HP
	n32UseCP:int#消耗CP
	lPassitiveEffectList:int[]#开关的被动技能效果列表
	n32Delay:int#调用等待时间
]]

local cfg={
}

function cfg:Get( key )
	return cfg[key]
end
return cfg