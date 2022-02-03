HomeworldConst = HomeworldConst or {}

HomeworldConst.Map_Id = 60009 -- 地图id

HomeworldConst.Map_Width = 1344  -- 格子区域宽度
HomeworldConst.Map_Height = 976  -- 格子区域高度

HomeworldConst.Tile_Width = 64   -- 格子宽度（对角线）
HomeworldConst.Tile_Height = 32  -- 格子高度（对角线）

HomeworldConst.Build_Width = 1440 -- 建筑主体宽度
HomeworldConst.Build_Height = 1779 -- 建筑主体宽度

HomeworldConst.Floor_Width = 60  -- 地板宽度
HomeworldConst.Floor_Height = 60  -- 地板宽度

-- 家具方向定义
HomeworldConst.Dir_Type = {
	Left = 1,
	Right = 2
}

-- 家具类型定义
HomeworldConst.Unit_Type = {
	Furniture = 1,	-- 家具
	WallAcc = 2, 	-- 墙饰
	Floor = 3, 		-- 地板
	Wall = 4,		-- 墙壁
	Carpet = 5		-- 地毯
}

-- 家园场景中单位的类型
HomeworldConst.Scene_Unit_Type = {
	Furniture = 1, -- 家具
	Role = 2, 	   -- 角色
	Pet = 3, 	   -- 宠物
}

-- 形象激活状态
HomeworldConst.Figure_State = {
	Lock = 1, -- 未解锁
	CanUnlock = 2, -- 可解锁
	Unlock = 3, -- 已解锁
}

-- 红点
HomeworldConst.Red_Index ={
	Visit = 1,  -- 被访问红点
	Suit = 2, 	-- 套装奖励
	Hook = 3, 	-- 挂机时长
	Figure = 4, -- 形象解锁
	PetEvent = 5,  -- 宠物事件红点 
}

-- 萌宠随机气泡
HomeworldConst.Pet_Arrow_Res = {
	[1] = "homeworld_1065",
	[2] = "homeworld_1066",
	[3] = "homeworld_1067",
	[4] = "homeworld_1068",
	[5] = "homeworld_1069",
}

-- 家园的类型
HomeworldConst.Type = {
	Myself = 1,  -- 我的家园
	Other = 2,   -- 别人的家园
	Preview = 3, -- 预览家园
}