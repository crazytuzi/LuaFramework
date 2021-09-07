
-- 攻击类型
AtkType = {
	Normal = 0,											-- 普攻
	Skill = 1,											-- 技能
}

-- 攻击缓存
AtkCache = {
	is_valid = false,									-- 是否有效
	atk_type = AtkType.Normal,							-- 攻击类型
	skill_id = 0,
	x = 0,
	y = 0,
	dir = 0,
	is_specialskill = false,
	special_distance = 0,
	target_obj = nil,
	target_obj_id = COMMON_CONSTS.INVALID_OBJID,
	range = 0,
	offset_range = 0,
	monster_range = 0,
	next_sync_pos_time = 0
}

-- 移动结束类型
MoveEndType = {
	Normal = 0,
	Fight = 1,											-- 使用AtkCache战斗
	AttackTarget = 2,									-- 攻击指定目标
	ClickNpc = 3,
	NpcTask = 4,										-- npc任务
	FightByMonsterId = 5,								-- 根据怪物id找怪战斗
	Gather = 6,											-- 采集
	GatherById = 7,										-- 根据采集id采集
	PickItem = 8,										-- 拾取掉落物
	Auto = 9,											-- 自动挂机
	FollowObj = 10,										-- 寻找目标后跟随
	EventObj = 11,										-- 抓鬼
	PickAroundItem = 12,								-- 拾取周伟掉落物
	EnterStoryFb = 13,									-- 进入剧情副本
	DoNothing = 14,										-- 去到某标点不做任何事
}

-- 移动类型
MoveType = {
	Pos = 0,											-- 移动到某个位置
	Obj = 1,											-- 移动到某个对象
	Fly = 2,											-- 直接飞到某个位置
}

-- 移动缓存
MoveCache = {
	cant_fly = false,
	is_valid = false,
	is_move_scan = false,
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
	param1 = 0,
	param2 = 0,
	monster_range = 0,
}

-- 挂机类型
GuajiType = {
	None = 0,											-- 非挂机
	HalfAuto = 1,										-- 半自动挂机
	Auto = 2,											-- 自动挂机
	Monster = 3,										-- 指定怪
	Follow = 4,											-- 跟随目标
}

-- 挂机缓存
GuajiCache = {
	guaji_type = GuajiType.None,
	target_obj = nil,
	target_obj_id = COMMON_CONSTS.INVALID_OBJID,
	is_click_select = false,
	monster_id = 0,
	event_guaji_type = GuajiType.None,					-- 主界面上的Event事件
}
