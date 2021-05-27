
-- 攻击类型
AtkType = {
	Normal = 0,											-- 普攻
	Skill = 1,											-- 技能
}

-- 攻击源
ATK_SOURCE = {
	PLAYER = 1,	-- 玩家操作
	PROF_AUTO = 2,	-- 职业自动施放，不放浑身难受技能
	AUTO = 9,	-- 自动战斗逻辑
}

-- 攻击信息
AtkInfo = {
	skill_id = 0,	-- 攻击的技能id
	x = 0,	-- 目标位置x
	y = 0,	-- 目标位置y
	dir = nil,	-- 攻击方向 nil时会自动根据当前位置和目标位置计算攻击方向
	range = 0,
	offset_range = 0,

	target_obj_id = COMMON_CONSTS.INVALID_OBJID,	-- 目标对象id
	target_obj = nil,

	is_valid = false,	-- 是否有效
	atk_source = ATK_SOURCE.AUTO,	-- 攻击源
	record_time = 0,	-- 记录此次攻击信息的时间
}

-- 移动结束类型
MoveEndType = {
	Normal = 0,
	Fight = 1,											-- 使用AtkInfo战斗
	AttackTarget = 2,									-- 攻击指定目标
	ClickNpc = 3,
	NpcTask = 4,										-- npc任务
	FightByMonsterId = 5,								-- 根据怪物id找怪战斗
	CollectById = 6,									-- 采集
	PickItem = 7,										-- 拾取掉落物
	FightAuto = 8,										-- 自动战斗
	PracticeTP = 9,										-- 试炼寻路
	OtherOpt = 10,										-- 其它
	MapMove = 11,										-- 移动到小地图中的某个位置
	ExcavateBoss  = 12,									-- 挖掘BOSS
}

-- 显示寻路特效的移动结束类型
ShowFindPathEffMoveEndType = {
	[MoveEndType.ClickNpc] = true,
	[MoveEndType.NpcTask] = true,
	[MoveEndType.FightByMonsterId] = true,
	[MoveEndType.MapMove] = true,
	[MoveEndType.PracticeTP] = true,
}

-- 移动类型
MoveType = {
	Pos = 0,											-- 移动到某个位置
	Obj = 1,											-- 移动到某个对象
	Fly = 2,											-- 直接飞到某个位置
	AtkMove = 3,										-- 移动到某个攻击位置
}

-- 移动缓存
MoveCache = {
	is_valid = false,
	end_type = MoveEndType.Normal,
	move_type = MoveType.Pos,
	scene_id = 0,
	x = 0,
	y = 0,
	target_obj = nil,
	target_obj_id = COMMON_CONSTS.INVALID_OBJID,
	range = 0,											-- 目标范围
	offset_range = 0,									-- 误差范围
	task_id = 0,
	cross_scene = false,
	param1 = 0,
	param2 = 0,
	is_player_opting = false, -- 玩家正在操作主角移动
	last_player_opt_time = 0, -- 玩家最后操作主角移动的时间
	is_opting_me = false,  -- 新定义玩家操作（用于拾取）
}

PickCacheMoveCache = nil

-- 挂机类型
GuajiType = {
	None = 0,											-- 非挂机
	HalfAuto = 1,										-- 半自动挂机
	Auto = 2,											-- 自动挂机
	Monster = 3,										-- 指定怪
}

-- 清除挂机的原因
ClearGuajiCacheReason = {
	None = 0,											-- 无
	SceneChange = 1,									-- 场景改变
	PlayerOptMove = 2,									-- 玩家操作移动
}

-- 挂机缓存
GuajiCache = {
	guaji_type = GuajiType.None,
	target_obj = nil,
	target_obj_id = COMMON_CONSTS.INVALID_OBJID,
	old_target_obj_id = COMMON_CONSTS.INVALID_OBJID,
	monster_id = 0,
}
