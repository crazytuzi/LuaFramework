
-- 场景对象类型
-- SceneObjType = {
-- 	Unknown = 0,
-- 	Role = 1,										-- 角色
-- 	Monster = 2,									-- 怪物
-- 	FallItem = 3,									-- 掉落物
-- 	GatherObj = 4,									-- 采集物
-- 	ServerEffectObj = 6,							-- 服务端场景特效
-- 	ShenShi = 9,									-- 战场神石

-- 	MainRole = 20,									-- 主角
-- 	SpriteObj = 30,									-- 精灵
-- 	Npc = 31,										-- NPC
-- 	Door = 32,										-- 传送点
-- 	Decoration = 33,								-- 装饰物
-- 	EffectObj = 34,									-- 特效
-- 	TruckObj = 35,									-- 镖车
-- 	EventObj = 36, 									-- 世界事件物品
-- 	PetObj = 37, 									-- 宠物
-- 	MultiMountObj = 38,								-- 双人坐骑
-- 	GoddessObj = 39,								-- 女神
-- 	FightMount = 40,								-- 战斗坐骑
-- 	JumpPoint = 41,									-- 跳跃点
-- 	Trigger = 42,									-- 触发物
-- 	MingRen = 43, 									-- 名人堂
-- }

-- 部件
-- SceneObjPart = {
-- 	Main = 0,										-- 主体
-- 	Weapon = 1,										-- 武器
-- 	Weapon2 = 2,									-- 武器2
-- 	Wing = 3,										-- 翅膀
-- 	Mount = 4,										-- 坐骑
-- 	Particle = 5,									-- 特效
-- 	Halo = 6,										-- 光环
-- 	FightMount = 7,									-- 战斗坐骑
-- 	BaoJu = 8,										-- 宝具
-- }


return {
	budget_cfg = {
		{min_fps = 15, budget = 1000},
		{min_fps = 20, budget = 2000},
		{min_fps = 25, budget = 2500},
	},
	payloads_cfg = {
		{obj_type = 1,  part = 8, payload = 200, priority = 3},				--角色-宝具
		{obj_type = 1,  part = 6, payload = 400, priority = 4},				--角色-光环
		{obj_type = 6,  part = 0, payload = 500, priority = 1},				--服务端场景特效
		{obj_type = 20, part = 8, payload = 500, priority = 7},				--主角-宝具
		{obj_type = 20, part = 6, payload = 500, priority = 8},				--主角-光环
		{obj_type = 30, part = 6, payload = 400, priority = 5},				--精灵-光环

	},
}