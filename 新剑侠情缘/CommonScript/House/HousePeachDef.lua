House.tbPeach = House.tbPeach or {};
local tbPeach = House.tbPeach;

-----------------------------
tbPeach.FAIRYLAND_MAP_TEMPLATE_ID = 4200; -- 幻境地图id
tbPeach.SEED_ITEM_ID              = 9504; -- 种子道具id
tbPeach.WATER_BOTTLE_ITEM_ID      = 9505; -- 水壶道具id
tbPeach.FERTILIZE_ITEM_ID         = 9506; -- 肥料道具id

tbPeach.PEACH_FURNITRUE_ID = 20001; -- 桃树家具id

tbPeach.PEACH_BRINGUP_IN_VALUE_GROUP = 137; -- 护持日期存储
tbPeach.PEACH_BRINGUP_IN_VALUE_KEY   = 5; -- 护持日期存储

tbPeach.WATER_BOTTLE_INT_VALUE_COUNT = 1; -- 浇水次数
tbPeach.WATER_BOTTLE_INT_VALUE_DAY   = 2; -- 浇水日期
tbPeach.WATER_BOTTLE_MAX_USE_COUNT   = 5; -- 水壶最大浇水次数

tbPeach.WATER_STATE_SAPLING_COUNT = 2; -- 浇水次数 成长为树苗
tbPeach.WATER_STATE_TREE_COUNT    = 4; -- 浇水次数 成长为桃花树
tbPeach.WATER_STATE_MATRUE_COUNT  = 5; -- 浇水次数 成熟

tbPeach.FAIRYLAND_MAX_ENTER_PLAYER          = 2; -- 幻境最大进入人数
tbPeach.FAIRYLAND_BRINGUP_TEAM_MEMBER_COUNT = 2; -- 幻境护持时队伍人数

tbPeach.FAIRYLAND_ORG_TREE_COUNT = 1; -- 幻境初始桃花树数
tbPeach.FAIRYLAND_MAX_TREE_COUNT = 6; -- 幻境最大桃花树数

tbPeach.PEACH_STATE_SEEDLING = 1; -- 幼苗状态
tbPeach.PEACH_STATE_SAPLING  = 2; -- 树苗状态
tbPeach.PEACH_STATE_TREE     = 3; -- 树状态
tbPeach.PEACH_STATE_MATRUE   = 4; -- 成熟状态

-- 浇水次数对应的桃花树状态
tbPeach.PEACH_STATE_WATER_MAP = {
	[0] = tbPeach.PEACH_STATE_SEEDLING;
	[1] = tbPeach.PEACH_STATE_SEEDLING;
	[2] = tbPeach.PEACH_STATE_SAPLING;
	[3] = tbPeach.PEACH_STATE_SAPLING;
	[4] = tbPeach.PEACH_STATE_TREE;
	[5] = tbPeach.PEACH_STATE_MATRUE;
};


-- 各阶段家具装饰资源
tbPeach.PEACH_STATE_RES = {
	[tbPeach.PEACH_STATE_SEEDLING] = "Scenes/Meshes/sn_jiayuan/Prefabs/taoshu01_a.prefab";
	[tbPeach.PEACH_STATE_SAPLING]  = "Scenes/Meshes/sn_jiayuan/Prefabs/taoshu02_a.prefab";
	[tbPeach.PEACH_STATE_TREE]     = "Scenes/Meshes/sn_jiayuan/Prefabs/taoshu03_a.prefab";
	[tbPeach.PEACH_STATE_MATRUE]   = "Scenes/Meshes/sn_jiayuan/Prefabs/taoshu03_a.prefab";
};

-- 各阶段NPC templateId. NPC类型为 FairylandPeach
tbPeach.PEACH_STATE_NPC_TEMPLATE = {
	[tbPeach.PEACH_STATE_SEEDLING] = 3239;
	[tbPeach.PEACH_STATE_SAPLING]  = 3240;
	[tbPeach.PEACH_STATE_TREE]     = 3241;
	[tbPeach.PEACH_STATE_MATRUE]   = 3241;
};

-- 幻境桃花树位置
tbPeach.FAIRYLAND_TREE_POS = {
	{5513,2324},
	{5109,2488},
	{4714,2234},
	{4849,1544},
	{5355,1478},
	{5660,1972},
};

-- 幻境双人护持时位置和方向 {nX, nY, nDir}
tbPeach.FAIRYLAND_BRINGUP_POS_DIR = {
	{{4988, 2424, 10}, {5208, 2386, 56}},
	{{4988, 2424, 10}, {5208, 2386, 56}},
	{{4640, 2106, 6}, {4857, 2167, 54}},
	{{4757, 1651, 25}, {4987, 1449, 54}},
	{{5251, 1455, 14}, {5427, 1416, 54}},
	{{5741, 1887, 54}, {5578, 2023, 20}},
};


tbPeach.FAIRYLAND_BRINGUP_SKILL = 1083; -- 护持动作id
tbPeach.FAIRYLAND_BRINGUP_TIME = 10; -- 护持时长
tbPeach.FAIRYLAND_BRINGUP_EFFECTID = 1062; -- 护持时人特效
tbPeach.FAIRYLAND_INVITE_TIMEOUT = 60; -- 幻境邀请有效时长

-- 桃花树，按养成的桃花树数算
tbPeach.FAIRYLAND_TREE_MATRUE_AWARD = {
	[2] = {{"item", 9543, 1}};
	[4] = {{"item", 9544, 1}};
	[6] = {{"item", 9545, 1}};
};

-- 养成奖励的领取前置限制，
tbPeach.FAIRYLAND_TREE_AWARD_PRE = {
	[4] = 2; -- 领4前需先领2
	[6] = 4;
};

tbPeach.FERTILIZER_FRIEND_IMITY_AWARD = 200; -- 施肥亲密度奖励
tbPeach.WATER_FRIEND_IMITY_AWARD      = 100; -- 浇水亲密度奖励
tbPeach.FAIRYLAND_BRINGUP_AWARD       = {{"Contrib", 100}, {"BasicExp", 30}}; -- 护持奖励

-- 幻境家具配置
tbPeach.FAIRYLAND_FURNITURE_SETTING = {
	{nTemplate = 4501, nPosX = 5182, nPosY = 2080, nRotation = 315};
	--{nTemplate = 1511, nPosX = 5268, nPosY = 5059, nRotation = 360};
	--{nTemplate = 1511, nPosX = 5068, nPosY = 4873, nRotation = 90};
};

tbPeach.FAIRYLAND_EFFECT_POS = {5182, 2080}; -- 特效位置

-- 幻境特效配置，idx 为树的数量
tbPeach.FAIRYLAND_TREE_EFFECT_ID = {
	[2] = 9268;
	[4] = 9269;
	[6] = 9270;
};

assert(#tbPeach.FAIRYLAND_TREE_POS >= tbPeach.FAIRYLAND_MAX_TREE_COUNT, "tree position must greater than max tree count");

function tbPeach:GetHousePeachState(nWaterCount, nWaterDay)
	local nToday = Lib:GetLocalDay();
	if nWaterDay == nToday then
		nWaterCount = math.max(nWaterCount - 1, 0);
	end

	return tbPeach.PEACH_STATE_WATER_MAP[nWaterCount] or tbPeach.PEACH_STATE_MATRUE;
end