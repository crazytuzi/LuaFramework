--[[
战旗配置文件
wangshuai
]]

_G.ZhanFlagModelConfig = {
	-- A旗子
	[6] = {
		modelId = 90100024, -- 模型id
		name = "域外邪族战旗",
		reborn_time = 1000, -- 刷新时间
		cast_time = 2000, -- 采集时间
		distance = 20, -- 采集距离
		flagHeight = 50, -- 旗子高度
		camp = 6, -- 所属阵营

	},
	-- B旗子
	[7] = {
		modelId = 90100024,
		name = "大千世界战旗",
		reborn_time = 1000,
		cast_time = 2000,
		distance = 20,
		flagHeight = 50, -- 旗子高度
		camp = 7,
	},
};

_G.ZhChFlagConfig = {
	-- 旗子 A
	[61] = {
		id = 61;
		x = -366, 
		y = -184,
		r = 20, -- 采集半径
		dir = 3,
		camp = 6;
	},
	[62] = {
		id = 62;
		x = 348,
		y = -163,
		r = 20,
		dir = 3,
		camp = 6;
	},	
	-- 旗子 B		
	[71] = {
		id = 71;
		x = -368,
		y = 120,
		r = 20,
		dir = 3,
		camp = 7;
	},
	[72] = {
		id = 72;
		x = 351,
		y = 146,
		r = 20,
		dir = 3,
		camp = 7;
	},
	-- 特殊1
	[1] = {
		id = 1;
		x = -462,
		y = 476,
		r = 20,
		dir = 3,
		camp = 0;
	},
	-- 2
	[2] = {
		id = 2;
		x = 374,
		y = -444,
		r = 20,
		dir = 3,
		camp = 0;
	},
};

_G.ZhChFlagUpPoint = {
 	-- A
	[6] = {
		x= -3,
		y= 600,
		r = 40,
	},
	-- B
	[7] = {
		x= 18,
		y= -581,
		r = 40,
	},
}

-- 旗使点！
_G.ZhChMonsterPoint = {
	-- 特殊1
	[11] = {
		x = -420,
		y = 424,
	},
	-- 特殊2
	[12] = {
		x = 445,
		y = -410,
	},
}