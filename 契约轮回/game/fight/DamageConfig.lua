-- 
-- @Author: LaoY
-- @Date:   2018-08-14 10:16:58
-- 

enum.DAMAGE.DAMAGE_EXP = 1000

DamageConfig = {}
-- enum.DAMAGE = {

-- 		DAMAGE_MISS = 1, -- 闪避

-- 		DAMAGE_BLOOD = 2, -- 正常减血

-- 		DAMAGE_CRIT = 3, -- 暴击

-- 		DAMAGE_HEART = 4, -- 会心一击

-- 		DAMAGE_HEAL = 5, -- 回血

-- 		DAMAGE_PURIFY = 6, -- 净化
	--  DAMAGE_ABSORB = 7, -- 吸收
	--  DAMAGE_BLOCK = 8, -- 格挡
	--DAMAGE_REFLECT=9-反弹
	--DAMAGE_KILL=10-斩杀
	--DAMAGE_FIRE=11--火属性攻击
	--DAMAGE_BLEED=12--流血
	--DAMAGE_UNYIELD=13-不屈
	--DAMAGE_LEECH=14--吸血
	--DAMAGE_IMMUNE=15--免疫
	
-- 	},

-- 艺术字
-- 策划不用管这个
DamageConfig.ArtFontConfig = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {key = "",name = "damage1"},
	[enum.DAMAGE.DAMAGE_MISS] = {key = "e",name = "buff"},
	[enum.DAMAGE.DAMAGE_CRIT] = {key = "v",name = "damage2"},
	[enum.DAMAGE.DAMAGE_HEART] = {key = "k",name = "damage7"},
	[enum.DAMAGE.DAMAGE_HEAL] = {key = "+",name = "damage5"},
	[enum.DAMAGE.DAMAGE_PURIFY] = {key = "j",name = "damage8"},
	[enum.DAMAGE.DAMAGE_ABSORB] = {key = "h",name = "damage9"},
	[enum.DAMAGE.DAMAGE_REFLECT] = {key = "f",name = "damage2"},
	[enum.DAMAGE.DAMAGE_FIRE] = {key = "h",name = "damage10"},	
	[enum.DAMAGE.DAMAGE_BLOCK] = {key = "f",name = "damage6"},
	[enum.DAMAGE.DAMAGE_BLEED] = {key = "l",name = "blood"},	
	[enum.DAMAGE.DAMAGE_UNYIELD] = {key = "b",name = "damage11"},	
	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {key = "m",name = "damage4"},
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {key = "m",name = "damage4"},	
	[enum.DAMAGE.DAMAGE_PET_HEART] = {key = "m",name = "damage4"},	
	[enum.DAMAGE.DAMAGE_PET_HEAL] = {key = "+",name = "damage5"},
	[enum.DAMAGE.DAMAGE_KILL] = {key = "z",name = "buff"},
	[enum.DAMAGE.DAMAGE_LEECH] = {key = "x",name = "damage5"},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {key = "m",name = "buff"},

	
}

DamageConfig.MainRoleArtFontConfig = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {key = "-",name = "blood"},
	[enum.DAMAGE.DAMAGE_BLEED] = {key = "l",name = "blood"},
	[enum.DAMAGE.DAMAGE_MISS] = {key = "e",name = "buff"},
	[enum.DAMAGE.DAMAGE_CRIT] = {key = "v",name = "damage2"},
	[enum.DAMAGE.DAMAGE_HEART] = {key = "k",name = "damage7"},
	[enum.DAMAGE.DAMAGE_HEAL] = {key = "+",name = "damage5"},
	[enum.DAMAGE.DAMAGE_PURIFY] = {key = "j",name = "damage8"},
	[enum.DAMAGE.DAMAGE_ABSORB] = {key = "h",name = "damage9"},
	[enum.DAMAGE.DAMAGE_REFLECT] = {key = "f",name = "damage2"},
	[enum.DAMAGE.DAMAGE_FIRE] = {key = "h",name = "damage10"},	
	[enum.DAMAGE.DAMAGE_BLOCK] = {key = "f",name = "damage6"},
	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {key = "",name = "damage1"},
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {key = "",name = "damage1"},	
	[enum.DAMAGE.DAMAGE_PET_HEART] = {key = "",name = "damage1"},	
	[enum.DAMAGE.DAMAGE_EXP] = {key = "jy+",name = "exp_float"},
	[enum.DAMAGE.DAMAGE_PET_HEAL] = {key = "+",name = "damage5"},
	[enum.DAMAGE.DAMAGE_UNYIELD] = {key = "b",name = "damage11"},	
	[enum.DAMAGE.DAMAGE_KILL] = {key = "z",name = "buff"},	
	[enum.DAMAGE.DAMAGE_IMMUNE] = {key = "m",name = "buff"},
	[enum.DAMAGE.DAMAGE_LEECH] = {key = "x",name = "damage5"},
}

--测试伤害类型 不是测试状态就注释这行
-- DamageConfig.TestDamageType = enum.DAMAGE.DAMAGE_LEECH

--随机偏移角度
DamageConfig.RandomList = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_BLEED] = {0},
	[enum.DAMAGE.DAMAGE_MISS] = {0},
	[enum.DAMAGE.DAMAGE_CRIT] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_HEART] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_HEAL] = {0},
	[enum.DAMAGE.DAMAGE_PURIFY] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_ABSORB] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_BLOCK] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_REFLECT] = {0},	
	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},	
	[enum.DAMAGE.DAMAGE_PET_HEART] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_FIRE] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_PET_HEAL] = {0},	
	[enum.DAMAGE.DAMAGE_UNYIELD] = {0},
	[enum.DAMAGE.DAMAGE_KILL] = {0},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {0},
	[enum.DAMAGE.DAMAGE_LEECH] = {0},
}

DamageConfig.MainRoleRandomList = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {0},
	[enum.DAMAGE.DAMAGE_BLEED] = {0},
	[enum.DAMAGE.DAMAGE_MISS] = {0},
	[enum.DAMAGE.DAMAGE_CRIT] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_HEART] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_HEAL] = {0},
	[enum.DAMAGE.DAMAGE_PURIFY] = {0},
	[enum.DAMAGE.DAMAGE_EXP] = {0},
	[enum.DAMAGE.DAMAGE_ABSORB] = {0},
	[enum.DAMAGE.DAMAGE_BLOCK] = {0},
	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},	
	[enum.DAMAGE.DAMAGE_PET_HEART] = {-15,-13,-11,-9,-7,-5,-3,-1,0,1,3,5,7,9,11,13,15},	
	[enum.DAMAGE.DAMAGE_PET_HEAL] = {0},
	[enum.DAMAGE.DAMAGE_REFLECT] = {0},	
	[enum.DAMAGE.DAMAGE_UNYIELD] = {0},
	[enum.DAMAGE.DAMAGE_FIRE] = {0},
	[enum.DAMAGE.DAMAGE_KILL] = {0},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {0},
	[enum.DAMAGE.DAMAGE_LEECH] = {0},
}

--主角飘字配置
DamageConfig.MainRoleHurtConfig = {
	MaxCount 	= 20,			-- 最多同时存在个数
	CD	 		= 0.1,			-- 两段飘字的时间间隔
	ExpCd 		= 0.1, 			-- 温泉加经验时间间隔
}


-- 新加类型需加 ①
-- 分开主角和其他
--[[
	@author LaoY
	@des	攻击者和受击目标夹角对应的 飘字角度 两段位移角度
	@key 	table key值，攻击者和目标夹角区间值
	@value 	table value
			table[1] 表示第一段与正y轴的夹角
			table[2] 表示第二段与正y轴的夹角
--]]
DamageConfig.DirList = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {
		[{0,90}] 	= {45,150},
		[{91,180}] 	= {120,180},
		[{181,270}] 	= {240,180},
		[{271,360}] 	= {300,220},
	},
	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {
		[{0,90}] 	= {40,150},
		[{91,180}] 	= {160,180},
		[{181,270}] 	= {240,180},
		[{271,360}] 	= {310,220},
	},
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {
		[{0,90}] 	= {45,0},
		[{91,180}] 	= {135,0},
		[{181,270}] 	= {225,0},
		[{271,360}] 	= {315,0},
	},
	[enum.DAMAGE.DAMAGE_PET_HEART] = {
		[{0,90}] 	= {45,0},
		[{91,180}] 	= {135,0},
		[{181,270}] 	= {225,0},
		[{271,360}] 	= {315,0},
	},

	[enum.DAMAGE.DAMAGE_CRIT] = {
		[{0,90}] 	= {45,90},
		[{91,180}] 	= {135,90},
		[{181,270}] 	= {225,270},
		[{271,360}] 	= {315,270},
	},
	[enum.DAMAGE.DAMAGE_FIRE] = {
		[{0,90}] 	= {45,90},
		[{91,180}] 	= {135,90},
		[{181,270}] 	= {225,270},
		[{271,360}] 	= {315,270},
	},
	[enum.DAMAGE.DAMAGE_HEART] = {
		[{0,90}] 	= {45,90},
		[{91,180}] 	= {135,90},
		[{181,270}] 	= {225,270},
		[{271,360}] 	= {315,270},
	},
	[enum.DAMAGE.DAMAGE_BLOCK] = {
		[{0,90}] 	= {45,90},
		[{91,180}] 	= {135,90},
		[{181,270}] 	= {225,270},
		[{271,360}] 	= {315,270},
	},
	[enum.DAMAGE.DAMAGE_MISS] = {
		[{0,90}] 	= {45,90},
		[{91,180}] 	= {135,90},
		[{181,270}] 	= {225,270},
		[{271,360}] 	= {315,270},
	},
	[enum.DAMAGE.DAMAGE_ABSORB] = {
		[{0,90}] 	= {45,90},
		[{91,180}] 	= {135,90},
		[{181,270}] 	= {225,270},
		[{271,360}] 	= {315,270},
	},
	[enum.DAMAGE.DAMAGE_HEAL] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_PET_HEAL] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_REFLECT] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_BLEED] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_UNYIELD] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_KILL] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_LEECH] = {
		[{0,360}] 	= {0,0},
	},
}
-- DamageConfig.DirList[enum.DAMAGE.DAMAGE_HEART] = DamageConfig.DirList[enum.DAMAGE.DAMAGE_CRIT]
-- DamageConfig.DirList[enum.DAMAGE.DAMAGE_BLOCK] = DamageConfig.DirList[enum.DAMAGE.DAMAGE_CRIT]
-- DamageConfig.DirList[enum.DAMAGE.DAMAGE_MISS] = DamageConfig.DirList[enum.DAMAGE.DAMAGE_CRIT]
-- DamageConfig.DirList[enum.DAMAGE.DAMAGE_ABSORB] = DamageConfig.DirList[enum.DAMAGE.DAMAGE_CRIT]
DamageConfig.DirList[enum.DAMAGE.DAMAGE_HEAL] = DamageConfig.DirList[enum.DAMAGE.DAMAGE_CRIT]

-- 主角两段位移角度
DamageConfig.MainRoleDirList = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_CRIT] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_FIRE] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},

	[enum.DAMAGE.DAMAGE_MISS] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},

	[enum.DAMAGE.DAMAGE_EXP] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {
		[{0,90}] 	= {40,150},
		[{91,180}] 	= {160,180},
		[{181,270}] 	= {240,180},
		[{271,360}] 	= {310,220},
	},
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {
		[{0,90}] 	= {45,0},
		[{91,180}] 	= {135,0},
		[{181,270}] 	= {225,0},
		[{271,360}] 	= {315,0},
	},
	[enum.DAMAGE.DAMAGE_PET_HEART] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_HEART] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_BLOCK] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_MISS] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_ABSORB] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
	},
	[enum.DAMAGE.DAMAGE_HEAL] = {
		[{0,360}] 	= {0,0},
		--[{91,180}] 	= {135,180},
		--[{181,270}] 	= {225,180},
		--[{271,360}] 	= {315,225},
		},
	[enum.DAMAGE.DAMAGE_PET_HEAL] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_REFLECT] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_BLEED] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_UNYIELD] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_KILL] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {
		[{0,360}] 	= {0,0},
	},
	[enum.DAMAGE.DAMAGE_LEECH] = {
		[{0,360}] 	= {0,0},
	},
}
-- DamageConfig.MainRoleDirList[enum.DAMAGE.DAMAGE_CRIT] = DamageConfig.MainRoleDirList[enum.DAMAGE.DAMAGE_BLOOD]

-- 新加类型需加 ②
-- 分开主角和其他
-- 各个伤害类型运动的轨迹{1.5,1.0}
-- 不要的模块注释掉
DamageConfig.ActionList = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {	-- 其他人掉血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.1, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 2,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {2,2,1,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.8,0.5},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_CRIT] = {	-- 其他人掉血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	
	[enum.DAMAGE.DAMAGE_HEART] = {	-- 其他人掉血
		start_scale = 4,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {4,3,2,1,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.8,0.5},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_FIRE] = {	-- 其他人掉血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.1, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 2,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {2,2,1,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.8,0.5},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_MISS] = {	-- 主角miss
		fadein_time = 0.1, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		move_front_scale = {3,1.5},	-- 移动前倍数变化
		move_front_scale_time = 0.3,		-- 倍数时间（多段总和）

		move_length = 80,
		move_time = 0.3,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1

		move_delay_time = 0.5,			-- 移动后停留

		
		move_after_scale = {1.5,1.5},	-- 移动后倍数变化
		move_after_scale_time = 0,

		fly_length = 0,
		fly_time = 0,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填

		fadeout_time = 0.2,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_HEAL] = {	-- 回复
		start_scale = 0.7,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 100,
		move_time = 0.3,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 2,				-- 加速速率 可不填，需要≥1
		move_scale = {0.7,0.9},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 80,
		fly_time = 0.2,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.9,0.7},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {	-- 宠物攻击掉血
		start_scale = 1.5,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.2, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 200,
		move_time = 0.4,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 5,				-- 加速速率 可不填，需要≥1
		move_scale = {1.5,1.3,1.3,1},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 150,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,1},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {	-- 宠物暴击
		start_scale = 0.8,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 3,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 330,
		move_time = 0.4,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 5,				-- 加速速率 可不填，需要≥1
		move_scale = {0.8,1,1.3,1},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 150,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,1},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PET_HEART] = {	-- 宠物会心
		start_scale = 0.8,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 3,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 330,
		move_time = 0.4,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 5,				-- 加速速率 可不填，需要≥1
		move_scale = {0.8,1,1.3,1},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 150,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,1},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PET_HEAL] = {	-- 宠物回复
		start_scale = 0.7,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 100,
		move_time = 0.3,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 2,				-- 加速速率 可不填，需要≥1
		move_scale = {0.7,0.9},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 80,
		fly_time = 0.2,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.9,0.7},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PURIFY] = {	-- 净化
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_ABSORB] = {	-- 吸收
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_BLOCK] = {	-- 格挡
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_REFLECT] = {	-- 反弹
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_BLEED] = {	-- 流血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_UNYIELD] = {	-- 不屈
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_KILL] = {	-- 斩杀
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {	-- 免疫
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_LEECH] = {	-- 吸血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

} 
--DamageConfig.ActionList[enum.DAMAGE.DAMAGE_CRIT] = DamageConfig.ActionList[enum.DAMAGE.DAMAGE_BLOOD]
--回血
DamageConfig.ActionList[enum.DAMAGE.DAMAGE_HEART] = DamageConfig.ActionList[enum.DAMAGE.DAMAGE_CRIT]


-- 主角飘字配置
DamageConfig.MainRoleActionList = {
	[enum.DAMAGE.DAMAGE_BLOOD] = {	-- 主角掉血
		fadein_time = 0.3, 			-- 渐入时间
		fadein_type = 3,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		--move_front_scale = {1.0,1.0},	-- 移动前倍数变化
		--move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 70,
		move_time = 0.35,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		
		move_scale = {0.5,1.4,1.8,2,1.4,0.8},			-- 移动缩放
		
		move_delay_time = 0,			-- 移动后停留

		
		--move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		--move_after_scale_time = 0.2,

		fly_length =20,
		fly_time = 0.25,      --第二段移动时间
		fly_delay_time = 0.1,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_CRIT] = {	-- 其他人暴击
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1.2,1},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_FIRE] = {	-- 其他人暴击
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PURIFY] = {	-- 净化
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_ABSORB] = {	-- 吸收
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_BLOCK] = {	-- 格挡
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_REFLECT] = {	-- 反弹
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_HEART] = {	-- 会心
		start_scale = 1,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 50,
		move_time = 0.2,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1
		move_scale = {1,1.2},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 100,
		fly_time = 0.25,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 3,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.5,				-- 渐出时间
		fadeout_type = 3,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_MISS] = {	-- 主角miss
		fadein_time = 0.1, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		move_front_scale = {3,1.5},	-- 移动前倍数变化
		move_front_scale_time = 0.3,		-- 倍数时间（多段总和）

		move_length = 80,
		move_time = 0.3,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1

		move_delay_time = 0.5,			-- 移动后停留

		
		move_after_scale = {1.5,1.5},	-- 移动后倍数变化
		move_after_scale_time = 0,

		fly_length = 0,
		fly_time = 0,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填

		fadeout_time = 0.2,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	
	[enum.DAMAGE.DAMAGE_HEAL] = {	-- 回复
		start_scale = 0.7,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 100,
		move_time = 0.3,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 2,				-- 加速速率 可不填，需要≥1
		move_scale = {0.7,0.9},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 80,
		fly_time = 0.2,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.9,0.7},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PET_BLOOD] = {	-- 宠物攻击掉血
		start_scale = 1.5,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.2, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 200,
		move_time = 0.4,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 5,				-- 加速速率 可不填，需要≥1
		move_scale = {1.5,1.3,1.3,1},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 150,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,1},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	
	[enum.DAMAGE.DAMAGE_PET_CRIT] = {	-- 宠物暴击
		start_scale = 0.8,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 3,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 330,
		move_time = 0.4,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 5,				-- 加速速率 可不填，需要≥1
		move_scale = {0.8,1,1.3,1},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 150,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,1},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PET_HEART] = {	-- 宠物会心
		start_scale = 0.8,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 3,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 330,
		move_time = 0.4,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 5,				-- 加速速率 可不填，需要≥1
		move_scale = {0.8,1,1.3,1},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 150,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,1},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_PET_HEAL] = {	-- 宠物回复
		start_scale = 0.7,			-- 开始的缩放值,不填默认是1

		fadein_time = 0, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = {1.1,1.0},	-- 移动前倍数变化
		-- move_front_scale_time = 0.1,		-- 倍数时间（多段总和）

		move_length = 100,
		move_time = 0.3,
		move_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 2,				-- 加速速率 可不填，需要≥1
		move_scale = {0.7,0.9},			-- 移动缩放

		move_delay_time = 0,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 80,
		fly_time = 0.2,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {0.9,0.7},				-- 第二段移动的缩放

		fadeout_time = 0.4,				-- 渐出时间
		fadeout_type = 1,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	-- 温泉加经验
	[enum.DAMAGE.DAMAGE_EXP] = {	-- 主角miss
		offset_x = 0, 				-- 开始位置偏移x值，不填默认是0
		offset_y = 50,				-- 开始位置偏移y值，不填默认是0
		fadein_time = 0, 			-- 渐入时间
		fadein_type = 3,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		move_front_scale = {1.0},	-- 移动前倍数变化
		move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 80,
		move_time = 0.4,
		move_ease_type = 2,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 3,				-- 加速速率 可不填，需要≥1

		move_delay_time = 0.5,			-- 移动后停留

		
		move_after_scale = {1.0,1.0},	-- 移动后倍数变化
		move_after_scale_time = 0,

		fly_length = 50,
		fly_time = 0.3,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填

		fadeout_time = 0.2,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},

	[enum.DAMAGE.DAMAGE_BLEED] = {	-- 流血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_UNYIELD] = {	-- 不屈
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_KILL] = {	-- 斩杀
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_IMMUNE] = {	-- 免疫
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},
	[enum.DAMAGE.DAMAGE_LEECH] = {	-- 吸血
		start_scale = 2,			-- 开始的缩放值,不填默认是1

		fadein_time = 0.08, 			-- 渐入时间
		fadein_type = 1,			-- 渐入类型 1 直接渐入；2 和scale并行渐入；3和move渐入

		-- 倍数变化列表：初始倍数，初始倍数——>第一段——>第二段...——>结束倍数
		-- 可以填单个数字代表 默认倍数(1)——>结束倍数
		-- move_front_scale = 5,	-- 移动前倍数变化
		-- move_front_scale_time = 0,		-- 倍数时间（多段总和）

		move_length = 150,
		move_time = 0.3,
		move_ease_type = 3,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		move_ease_rate = 1,				-- 加速速率 可不填，需要≥1
		move_scale = {3,3,2,1,1,1,1,1,1,1,1,1},			-- 移动缩放

		move_delay_time = 0.4,			-- 移动后停留

		
		-- move_after_scale = {1.1,1.0},	-- 移动后倍数变化
		-- move_after_scale_time = 0.2,

		fly_length = 200,
		fly_time = 0.4,
		fly_delay_time = 0,			
		fly_ease_type = 1,				-- 加速类型 不填或者1.无； 2.先慢后快；3.先快后慢
		fly_ease_rate = 2,				-- 加速速率 可不填
		fly_scale = {1,0.8},				-- 第二段移动的缩放

		fadeout_time = 0.6,				-- 渐出时间
		fadeout_type = 2,				-- 1按顺序渐出；2和移动渐出；3和停止时间渐出
	},


}
-- 回血
-- DamageConfig.MainRoleActionList[enum.DAMAGE.DAMAGE_HEAL] = DamageConfig.MainRoleActionList[enum.DAMAGE.DAMAGE_BLOOD]

DamageConfig.GetEaseActionType = function(action,ease_type,rate)
	if not ease_type or ease_type == 1 then
		return action
	end
	rate = rate or 2
	if ease_type == 2 then
		return cc.EaseIn(action,rate)
	elseif ease_type == 3 then
		return cc.EaseOut(action,rate)
	else
		return action
	end
end

DamageConfig.GetDir = function(angle,damage_type,is_main_role)
	local list = is_main_role and DamageConfig.MainRoleDirList[damage_type] or DamageConfig.DirList[damage_type]
	list = list or {}
	for dir_info,v in pairs(list) do
		if angle >= dir_info[1] and angle <= dir_info[2] then
			return v
		end
	end
	return {45,0}
end

DamageConfig.GetActionConfig = function(damage_type,is_main_role)
	local config = is_main_role and DamageConfig.MainRoleActionList or DamageConfig.ActionList
	if config then
		return config[damage_type]
	end
end

DamageConfig.GetOffsetAngle = function(damage_type,is_main_role)
	local config = is_main_role and DamageConfig.MainRoleRandomList[damage_type] or DamageConfig.RandomList[damage_type]
	if config then
		return config[math.random(#config)]
	end
	return 0
end


for k,v in pairs(DamageConfig.ArtFontConfig) do
    LayerManager:GetInstance():GetDamageLayerByFont(v.name)
end
for k,v in pairs(DamageConfig.MainRoleArtFontConfig) do
    LayerManager:GetInstance():GetDamageLayerByFont(v.name)
end