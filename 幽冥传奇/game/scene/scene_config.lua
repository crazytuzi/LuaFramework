
Config.SCENE_TILE_WIDTH = 48
Config.SCENE_TILE_HEIGHT = 32
Config.PICK_ITEM_CD = 0.23	--捡物品冷却
Config.SCENE_TILE_DIAGONAL = math.sqrt(Config.SCENE_TILE_WIDTH * Config.SCENE_TILE_WIDTH 
	+ Config.SCENE_TILE_HEIGHT * Config.SCENE_TILE_HEIGHT)

DigOreSceneId = 290	--挖矿场景
AutoDoTaskLv = 300	--自动做任务等级
AutoDoTaskTimeSpace = 	2--自动做任务间隔(单位/秒)

-- 场景类型
SceneType = {
	Common    = 0,									-- 普通场景
	Activity  = 1,									-- 活动
	Fubun     = 2,									-- 副本场景
	Practice  = 3,									-- 挂机场景
	Hotspring = 4,									-- 温泉场景
	Heaven    = 5,									-- 九天冰宫
	Hell      = 6,									-- 深渊烈域
	Special   = 7,									-- 特殊刷怪场景
	DigOre    = 8,									-- 挖矿场景
}

-- 恶名等级
EvilColorList = {
	NAME_COLOR_WHITE = 0,							-- 白色
	NAME_COLOR_RED_1 = 1,							-- 红色1
	NAME_COLOR_RED_2 = 2,							-- 红色2
	NAME_COLOR_RED_3 = 3,							-- 红色3
	NAME_COLOR_MAX = 4,
}

PKNameColorType = {
	PKColorType_Normal = 0,			-- 正常颜色
	PKColorType_Yellow = 1,			-- 黄色
	PKColorType_Brown = 2,			-- 褐色
	PKColorType_Red = 3,			-- 红色
	PKColorType_Orange = 4,			-- 橙色
	PKColorType_Green = 5,			-- 绿色
	PKColorType_Blue = 6,			-- 蓝色
	PKColorType_Purple = 7,			-- 紫色
}

--阵营场景对应关型
CampSceneIdList = {
	[GameEnum.ROLE_CAMP_1] = 110,
	[GameEnum.ROLE_CAMP_2] = 109,
	[GameEnum.ROLE_CAMP_3] = 111,
}

EntityType = {
	Role = 0,										-- 角色
	Monster = 1,									-- 怪物
	Npc = 2,										-- NPC
	FallItem = 3,									-- 掉落物
	Pet = 4,										-- 宠物
	Fire = 5,										-- 火
	Mine = 6,										-- 矿物，采集对象
	Defender = 7,									-- 防御设施,采集对象
	Plant = 8,										-- 植物,采集对象
	Transfer = 9,									-- 传送门
	Landscape = 10,									-- 场景的坐标点
	Effect = 11,									-- 特效
	GatherMonster = 12,								-- 采集怪
	DisplayMonster = 13,							-- 显示怪
	Hero = 14,										-- 英雄
	Totem = 15,										-- 图腾怪
	Humanoid = 16,									-- 人形怪
	ActorSlave = 17,								-- 玩家的随从，比如马车
	OfflineActor = 18,								-- 离线玩家
	Saparation = 19,								-- 分身
}

function IsMonsterByEntityType(entity_type)
	if entity_type == EntityType.Monster 
		or entity_type == EntityType.GatherMonster 
		or entity_type == EntityType.DisplayMonster 
		or entity_type == EntityType.Totem
		or entity_type == EntityType.Humanoid then
		return true
	end

	return false
end

-- 场景对象类型
SceneObjType = {
	Unknown = -1,
	Role = 0,										-- 角色
	Monster = 1,									-- 怪物
	Npc = 2,										-- NPC
	FallItem = 3,									-- 掉落物
	Pet = 4,										-- 宠物
	Transfer = 9,									-- 传送门
	EffectObj = 11,									-- 特效

	Decoration = 33,								-- 装饰物
	
	MainRole = 50,									-- 主角
	SpecialObj = 51,								-- 特殊对象
	FenShenObj = 101,								--分身
	DirOreObj = 102,								--矿工小号
	-- 客户端维护
	FireObj = 100,										-- 烈焰神力
}

-- 内部层次定义
InnerLayerType = {
	Select = 10,									-- 选圈层
	Shadow = 11,									-- 阴影层
	BuffEffectDown = 30,							-- buff效果层(下层)
	Mount = 40,										-- 坐骑层
	BiaocheCircle = 35,								-- 镖车光圈层

	ZsPetDown = 43,									-- 萌宠层(下层)
	PhantomDown = 44,								-- 幻影层(下层)
	ChibangDown = 46,								-- 翅膀层(下层)
	WuqiDown = 48,									-- 武器层(下层)
	HandDown = 49,									-- 幻影层(上层)
	Main = 50,										-- 主体层
	DouLi = 51,										-- 斗笠
	WuqiUp = 52,									-- 武器层(上层)
	HuTiBuff = 53,									-- 护体类buff效果层；在翅膀之下
	HandUp = 54,									-- 幻影层(上层)
	ChibangUp = 55,									-- 翅膀层(上层)
	PhantomUp = 56,									-- 幻影层(上层)
	ExcavateBoss = 57, 								-- 挖掘boss
	ZhenQi = 58, 									-- 真气

	BuffEffectUp = 60,								-- buff效果层(上层)
	AttackEffect = 78,								-- 攻击特效
	UpLevel = 79,									-- 升级光环
	MountHead = 80,									-- 坐骑头

	AutoEffect = 90,								-- 自动挂机/寻路
	TaskMark = 100,									-- 任务标记层
	Name = 101,										-- 名字
	ZsPetUp = 102,									-- 萌宠层(上层)
	HpBoard = 103,									-- 血条
	Title = 104,									-- 称号
	Talk = 300,										-- 说话
	Face = 300,										-- 表情
}

-- 不缩放的层次
NotScaleLayer = {
	[InnerLayerType.TaskMark] = true,
	[InnerLayerType.Name] = true,
	[InnerLayerType.HpBoard] = true,
}

-- 帧时长
FrameTime = {
	Stand = 0.2,
	Move = 0.07,
	Run = 0.047,
	Atk = 0.055,
	Dead = 0.15,
	Hit = 0.15,
	Wait = 0.25,
	RoleStand = 0.22,
	Effect = 0.1,
	Decoration = 0.15,
	Door = 0.1,
	ModuleEffect = 0.12,
	Skill = 0.08,
}

Config.ATTACK_PALY_TIME = FrameTime.Atk * 7	--role每次攻击动画的播放时间
Config.ATTACK_MOSTER_PALY_TIME = FrameTime.Atk * 6		--默认每次攻击动画的播放时间
Config.ATTACK_FENSHEN_MOSTER_PALY_TIME = 0
-- 场景对象状态
SceneObjState = {
	Stand = "stand",								-- 站立
	Move = "move",									-- 移动
	Run = "run",									-- 跑步
	Dead = "dead",									-- 死亡
	Atk = "atk",									-- 攻击
	Hit = "hit",									-- 被打
	Wait = "wait",									-- 攻击等待
}

ZoneType = {
	ShadowBegin = 97,								-- 阴影区起始值'a'
	ShadowDelta = 97 - ZONE_TYPE_BLOCK,				-- 阴影区差值'a' - '0'
}

-- 选择类型
SelectType = {
	All = 0,										-- 全部
	Friend = 1,										-- 友方
	Enemy = 2,										-- 敌方
	Alive = 3,										-- 活着的
}

-- 角色武器层次 [职业][动作][方向] (true:上层，false:下层)
RoleWuqiLayer = {
	-- 上 = 0, 右上 = 1, 右, 右下, 下, 左下, 左, 左上
	[0] = {
		[SceneObjState.Stand] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Move] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Run] = {[0] = false, true, true, true, true, true, false, false,},
		[SceneObjState.Dead] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Atk] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Hit] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Wait] = {[0] = false, true, true, true, true, false, false, false,},
	},
	[GameEnum.ROLE_PROF_1] = {
		[SceneObjState.Stand] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Move] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Run] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Dead] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Atk] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Hit] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Wait] = {[0] = false, true, true, true, true, false, false, false,},
	},
	[GameEnum.ROLE_PROF_2] = {
		[SceneObjState.Stand] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Move] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Run] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Dead] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Atk] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Hit] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Wait] = {[0] = false, true, true, true, true, false, false, false,},
	},
	[GameEnum.ROLE_PROF_3] = {
		[SceneObjState.Stand] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Move] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Run] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Dead] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Atk] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Hit] = {[0] = false, true, true, true, true, false, false, false,},
		[SceneObjState.Wait] = {[0] = false, true, true, true, true, false, false, false,},
	},
}

-- 同屏显示人数
SceneAppearRoleCount = {
	Max = 30,
	Min = 5,
}
