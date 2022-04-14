--
-- @Author: LaoY
-- @Date:   2019-12-10 16:14:21
--

--[[
	模型带特效的节点配置
	key:模型的资源名字
		key:节点名字
			name:特效名字
			show_type:显示类型，1.都加载 2.只加载自己 3超过一定数量不加载 4.场景不显示UI显示
			load_lv:等级越高，加载优先级越高。用于所有模型带的特效排序
			show_lv:别人的显示等级，1 是显示低级 2显示中级 3显示高级。
			scale：UI上的所放置值（副手有用）
--]]
ModelEffectConfig = {

----------------------------------------------------坐骑----------------------------------------------------------
	-- 哆哆小鸡
	["model_mount_10001"] = {
		-- 节点1
		["Bip001 Spine"] = {
			-- 特效1
			{name = "effect_mount_10001_Bip001_Spine",show_type = 4,load_lv =1,scale = 1},

		},
		["Bone003"] = {
			-- 特效1
			{name = "effect_mount_10001_Bone003",show_type = 2,load_lv = 1,scale = 1},

		},

	},


	-- 雪地猛犸
	["model_mount_10002"] = {
		["Bone004"] = {
			{name = "effect_mount_10002_Bone004",show_type = 2,load_lv = 1,scale = 1},
		},
		["Bip002 L UpperArm"] = {
			{name = "effect_mount_10002_Bip002_L_UpperArm",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bip002 R UpperArm"] = {
			{name = "effect_mount_10002_Bip002_R_UpperArm",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bone016"] = {
			{name = "effect_mount_10002_Bone016",show_type = 2,load_lv = 3,scale = 1},
		},
	},
	
	
	-- 永生之潘
	["model_mount_10003"] = {
		["Bip02 Head"] = {
			{name = "effect_mount_10003_Bip02_Head",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bone004"] = {
			{name = "effect_mount_10003_Bone004",show_type = 1,load_lv = 1,scale = 1},
		},
	},
	

	-- 月渎枭狼
	["model_mount_10004"] = {
		["Bip001 L UpperArm"] = {
			{name = "effect_mount_10004_Bip001_L_UpperArm",show_type = 1,load_lv = 1,scale = 1},
		},
		["Bip001 R UpperArm"] = {
			{name = "effect_mount_10004_Bip001_R_UpperArm",show_type = 1,load_lv = 1,scale = 1},
		},
		["Bip001 Spine"] = {
			{name = "effect_mount_10004_bip001_spine1",show_type = 4,load_lv = 1,scale = 1},
		},
	},
	
	-- 奥术冰狮
	["model_mount_10005"] = {
		["Bip01 Head"] = {
			{name = "effect_mount_10005_Bip01_Head",show_type = 1,load_lv = 1,scale = 1},
		},
		["Bone019"] = {
			{name = "effect_mount_10005_Bone019",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bone022"] = {
			{name = "effect_mount_10005_Bone022",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bone011"] = {
			{name = "effect_mount_10005_Bone011",show_type = 2,load_lv = 1,scale = 1},
		},
		["Bone015"] = {
			{name = "effect_mount_10005_Bone015",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bip01 Pelvis"] = {
			{name = "effect_mount_10005_Bip01_Pelvis",show_type = 4,load_lv = 3,scale = 1},
		},
	},
	-- 荒原怒龙
	["model_mount_10006"] = {
		["Bip001 Neck1"] = {
			{name = "effect_mount_10006_Bip001_Neck1",show_type = 2,load_lv = 3,scale = 1},
		},

	},
	-- 毁灭钢龙
	["model_mount_10007"] = {
		["Bip001 Xtra01"] = {
			{name = "effect_mount_10007_Bip001_Xtra01",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bone005"] = {
			{name = "effect_mount_10007_Bone005",show_type = 1,load_lv = 1,scale = 1},
		},
		["Bone012"] = {
			{name = "effect_mount_10007_Bone012",show_type = 1,load_lv = 1,scale = 1},
		},
		["Bip001 Xtra0204"] = {
			{name = "effect_mount_10007_Bip001_Xtra0204",show_type = 2,load_lv = 1,scale = 1},
		},

	},
	-- 冰晶梦魇
	["model_mount_10008"] = {
		["Bip02 L Toe0"] = {
			{name = "effect_mount_10008_Bip02_L_Toe0",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bip02 R Toe0"] = {
			{name = "effect_mount_10008_Bip02_R_Toe0",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bip02 L Finger01"] = {
			{name = "effect_mount_10008_Bip02_L_Finger01",show_type = 2,load_lv = 1,scale = 1},
		},
		["Bip02 R Finger01"] = {
			{name = "effect_mount_10008_Bip02_R_Finger01",show_type = 2,load_lv = 1,scale = 1},
		},
		["Bone009"] = {
			{name = "effect_mount_10008_Bone009",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone009(mirrored)"] = {
			{name = "effect_mount_10008_Bone009_mirrored",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 旅行狮鹫
	    ["model_mount_20001"] = {
		["Bone014"] = {
			{name = "effect_mount_20001_bone014",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone019"] = {
			{name = "effect_mount_20001_bone019",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone022"] = {
			{name = "effect_mount_20001_bone022",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bone017"] = {
			{name = "effect_mount_20001_bone017",show_type = 4,load_lv = 1,scale = 1},
		},

	},
	-- 冰霜巨龙
	    ["model_mount_20002"] = {
		["Bip001 Head"] = {
			{name = "effect_mount_20002_Bip001_Head",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone002"] = {
			{name = "effect_mount_20002_Bone002",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone002(mirrored)"] = {
			{name = "effect_mount_20002_Bone002_mirrored",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone017"] = {
			{name = "effect_mount_20002_Bone017",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 混沌巨像
	    ["model_mount_20003"] = {
		["Bip001 L UpperArm"] = {
			{name = "effect_mount_20003_Bip001_L_UpperArm",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bip001 R UpperArm"] = {
			{name = "effect_mount_20003_Bip001_R_UpperArm",show_type = 4,load_lv = 1,scale = 1},
		},
		["Bip001"] = {
			{name = "effect_mount_20003_Bip001",show_type = 1,load_lv = 3,scale = 1},
		},

	},	
	-- 黄金雄狮
	    ["model_mount_20004"] = {
		["Bone005"] = {
			{name = "effect_mount_20004_Bone005",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone007"] = {
			{name = "effect_mount_20004_Bone007",show_type = 1,load_lv = 3,scale = 1},
		},
	},		
	
	-- 蓝色跑车
	    ["model_mount_30001"] = {
		["Bone001"] = {
			{name = "effect_mount_30001_Bone001",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone002"] = {
			{name = "effect_mount_30001_Bone002",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone003"] = {
			{name = "effect_mount_30001_Bone003",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone004"] = {
			{name = "effect_mount_30001_Bone004",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone_ride"] = {
			{name = "effect_mount_30001_Bone_ride",show_type = 4,load_lv = 3,scale = 1},
		},
	},	
	-- 力矩号
	    ["model_mount_30002"] = {
		["Bone001"] = {
			{name = "effect_mount_30002_Bone001",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone002"] = {
			{name = "effect_mount_30002_Bone002",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone003"] = {
			{name = "effect_mount_30002_Bone003",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone004"] = {
			{name = "effect_mount_30002_Bone004",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone_ride"] = {
			{name = "effect_mount_30002_Bone_ride",show_type = 4,load_lv = 3,scale = 1},
		},
	},		
	-- 超离子号
	    ["model_mount_30003"] = {
		["Bone001"] = {
			{name = "effect_mount_30003_Bone001",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone003"] = {
			{name = "effect_mount_30003_Bone003",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone004"] = {
			{name = "effect_mount_30003_Bone004",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone006"] = {
			{name = "effect_mount_30003_Bone006",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone007"] = {
			{name = "effect_mount_30003_Bone007",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone008"] = {
			{name = "effect_mount_30003_Bone008",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone009"] = {
			{name = "effect_mount_30003_Bone009",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone010"] = {
			{name = "effect_mount_30003_Bone010",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone_ride"] = {
			{name = "effect_mount_30003_Bone_ride",show_type = 2,load_lv = 3,scale = 1},
		},
	},			
	-- 亚特拉斯号
	    ["model_mount_30004"] = {
		["Bone001"] = {
			{name = "effect_mount_30004_Bone001",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone002"] = {
			{name = "effect_mount_30004_Bone002",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone003"] = {
			{name = "effect_mount_30004_Bone003",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone004"] = {
			{name = "effect_mount_30004_Bone004",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone005"] = {
			{name = "effect_mount_30004_Bone005",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone006"] = {
			{name = "effect_mount_30004_Bone006",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone007"] = {
			{name = "effect_mount_30004_Bone007",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone008"] = {
			{name = "effect_mount_30004_Bone008",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone_ride"] = {
			{name = "effect_mount_30004_Bone_ride",show_type = 1,load_lv = 3,scale = 1},
		},
	},		






----------------------------------------------------界面副手----------------------------------------------------------
	-- 燃烬（界面）
	    ["model_hand_10001"] = {
		["hand_root"] = {
			{name = "effect_hand_91001_hand_root",show_type = 2,load_lv = 3,scale = 3},
		},
	},
	-- 北境诅咒（界面）
	    ["model_hand_10002"] = {
		["hand_root"] = {
			{name = "effect_hand_91002_hand_root",show_type = 2,load_lv = 3,scale = 3},
		},
	},	
	-- 灼目（界面）
	    ["model_hand_10003"] = {
		["hand_root"] = {
			{name = "effect_hand_91003_hand_root",show_type = 2,load_lv = 3,scale = 2},
		},
	},		
	-- 恶魔之手（界面）
	    ["model_hand_10004"] = {
		["hand_root"] = {
			{name = "effect_hand_91004_hand_root",show_type = 2,load_lv = 3,scale = 2.5},
		},
	},	
	-- 恶魔之手（界面）
	    ["model_hand_10017"] = {
		["hand_root"] = {
			{name = "effect_hand_91004_hand_root",show_type = 2,load_lv = 3,scale = 2.5},
		},
	},	
	-- 无心之觞（界面）
	    ["model_hand_10005"] = {
		["hand_root"] = {
			{name = "effect_hand_91005_hand_root",show_type = 2,load_lv = 3,scale = 4},
		},
	},	
	-- 无心之觞（界面）
	    ["model_hand_10018"] = {
		["hand_root"] = {
			{name = "effect_hand_91005_hand_root",show_type = 2,load_lv = 3,scale = 4},
		},
	},	
	-- 魔焰（界面）
	    ["model_hand_10006"] = {
		["hand_root"] = {
			{name = "effect_hand_91006_hand_root",show_type = 2,load_lv = 3,scale = 3.5},
		},
	},	
	-- 谶言（界面）
	    ["model_hand_10007"] = {
		["hand_root"] = {
			{name = "effect_hand_91007_hand_root",show_type = 2,load_lv = 3,scale = 4},
		},
	},		
	-- 无限手套（界面）
	    ["model_hand_10008"] = {
		["hand_root"] = {
			{name = "effect_hand_91008_hand_root",show_type = 2,load_lv = 3,scale = 4},
		},
	},			
	-- 黄金左手（界面）
	    -- ["model_hand_10009"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91009_hand_root",show_type = 2,load_lv = 3,scale = 3},
		-- },
	-- },	
	-- 蓝钻（界面）
	    -- ["model_hand_10010"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91010_hand_root",show_type = 2,load_lv = 3,scale = 3},
		-- },
	-- },		
	-- 幻影手套（界面）
	    -- ["model_hand_10011"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91011_hand_root",show_type = 2,load_lv = 3,scale = 3},
		-- },
	-- },			
	-- 钢铁侠（界面）
	    ["model_hand_10012"] = {
		["hand_root"] = {
			{name = "effect_hand_91012_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 紫狼（界面）
	    ["model_hand_10013"] = {
		["hand_root"] = {
			{name = "effect_hand_91013_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 猫拳（界面）
	    -- ["model_hand_10014"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91014_hand_root",show_type = 2,load_lv = 3,scale = 3},
		-- },
	-- },




----------------------------------------------------男副手----------------------------------------------------------	
	-- 燃烬（男）
	    ["model_hand_91001"] = {
		["hand_root"] = {
			{name = "effect_hand_91001_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},
	-- 北境诅咒（男）
	    ["model_hand_91002"] = {
		["hand_root"] = {
			{name = "effect_hand_91002_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 灼目（男）
	    ["model_hand_91003"] = {
		["hand_root"] = {
			{name = "effect_hand_91003_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 恶魔之手（男）
	    ["model_hand_91004"] = {
		["hand_root"] = {
			{name = "effect_hand_91004_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 恶魔之手（男）
	    ["model_hand_91017"] = {
		["hand_root"] = {
			{name = "effect_hand_91004_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 无心之觞（男）
	    ["model_hand_91005"] = {
		["hand_root"] = {
			{name = "effect_hand_91005_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 无心之觞（男）
	    ["model_hand_91018"] = {
		["hand_root"] = {
			{name = "effect_hand_91005_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 魔焰（男）
	    ["model_hand_91006"] = {
		["hand_root"] = {
			{name = "effect_hand_91006_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 谶言（男）
	    ["model_hand_91007"] = {
		["hand_root"] = {
			{name = "effect_hand_91007_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 无限手套（男）
	    ["model_hand_91008"] = {
		["hand_root"] = {
			{name = "effect_hand_91008_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},			
	-- 黄金左手（男）
	    -- ["model_hand_91009"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91009_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },	
	-- 蓝钻（男）
	    -- ["model_hand_91010"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91010_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },		
	-- 幻影手套（男）
	    -- ["model_hand_91011"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91011_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },			
	-- 钢铁侠（男）
	    ["model_hand_91012"] = {
		["hand_root"] = {
			{name = "effect_hand_91012_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 紫狼（男）
	    ["model_hand_91013"] = {
		["hand_root"] = {
			{name = "effect_hand_91013_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 猫拳（男）
	    -- ["model_hand_91014"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91014_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },
	



----------------------------------------------------女副手----------------------------------------------------------
	-- 燃烬（女）
	    ["model_hand_92001"] = {
		["hand_root"] = {
			{name = "effect_hand_91001_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},
	-- 北境诅咒（女）
	    ["model_hand_92002"] = {
		["hand_root"] = {
			{name = "effect_hand_91002_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 灼目（女）
	    ["model_hand_92003"] = {
		["hand_root"] = {
			{name = "effect_hand_91003_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 恶魔之手（女）
	    ["model_hand_92004"] = {
		["hand_root"] = {
			{name = "effect_hand_91004_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 恶魔之手（女）
	    ["model_hand_92017"] = {
		["hand_root"] = {
			{name = "effect_hand_91004_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 无心之觞（女）
	    ["model_hand_92005"] = {
		["hand_root"] = {
			{name = "effect_hand_91005_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 无心之觞（女）
	    ["model_hand_92018"] = {
		["hand_root"] = {
			{name = "effect_hand_91005_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 魔焰（女）
	    ["model_hand_92006"] = {
		["hand_root"] = {
			{name = "effect_hand_91006_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 谶言（女）
	    ["model_hand_92007"] = {
		["hand_root"] = {
			{name = "effect_hand_91007_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 无限手套（女）
	    ["model_hand_92008"] = {
		["hand_root"] = {
			{name = "effect_hand_91008_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},			
	-- 黄金左手（女）
	    -- ["model_hand_92009"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91009_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },	
	-- 蓝钻（女）
	    -- ["model_hand_92010"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91010_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },		
	-- 幻影手套（女）
	    -- ["model_hand_92011"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91011_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },			
	-- 钢铁侠（女）
	    ["model_hand_92012"] = {
		["hand_root"] = {
			{name = "effect_hand_91012_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},		
	-- 紫狼（女）
	    ["model_hand_92013"] = {
		["hand_root"] = {
			{name = "effect_hand_91013_hand_root",show_type = 2,load_lv = 3,scale = 1},
		},
	},	
	-- 猫拳（女）
	    -- ["model_hand_92014"] = {
		-- ["hand_root"] = {
			-- {name = "effect_hand_91014_hand_root",show_type = 2,load_lv = 3,scale = 1},
		-- },
	-- },






	----------------------------------------------------神兵----------------------------------------------------------
	-- 含光雷电
	    ["model_weapon_r_10000"] = {
		["weapon-root"] = {
			{name = "effect_weapon_r_10001_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},

	-- 含光雷电
	    ["model_weapon_r_10001"] = {
		["weapon-root"] = {
			{name = "effect_weapon_r_10001_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 霜之哀伤
	    ["model_weapon_r_10002"] = {
		["weapon-root"] = {
			{name = "effect_weapon_r_10002_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 血色黎明
	    ["model_weapon_r_10003"] = {
		["weapon-root"] = {
			{name = "effect_weapon_r_10003_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 诸神黄昏
	    ["model_weapon_r_10004"] = {
		["weapon-root"] = {
			{name = "effect_weapon_r_10004_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 七度空间
	    ["model_weapon_r_10005"] = {
		["weapon-root"] = {
			{name = "effect_weapon_r_10005_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},
	-- 破碎虚空
	    ["model_weapon_r_10006"] = {
		["Bone_weapon"] = {
			{name = "effect_weapon_r_10006_weapon-root",show_type = 1,load_lv = 3,scale = 1},
		},
	},



----------------------------------------------------法宝----------------------------------------------------------
	-- 默认法宝
	    ["model_fabao_10000"] = {
		["Bone001"] = {
			{name = "effect_fabao_10000_Bone001",show_type = 2,load_lv = 3,scale = 1},
		},
	},

	-- 异星魔仆
	    ["model_fabao_10001"] = {
		["Bone005"] = {
			{name = "effect_fabao_10001_Bone005",show_type = 2,load_lv = 3,scale = 1},
		},	
		["Bone005(mirrored)"] = {
			{name = "effect_fabao_10001_Bone005",show_type = 2,load_lv = 3,scale = 1},
		},		
		["Bone001"] = {
			{name = "effect_fabao_10001_Bone001",show_type = 2,load_lv = 3,scale = 1},
		},					
	},
	-- 远古光核
	    ["model_fabao_10002"] = {
		["Bone003"] = {
			{name = "effect_fabao_10002_Bone003",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone005"] = {
			{name = "effect_fabao_10002_Bone005",show_type = 2,load_lv = 3,scale = 1},
		},					
	},
	-- 魔龙宝珠
	    ["model_fabao_10003"] = {
		["Bone014 1"] = {
			{name = "effect_fabao_10003_Bone014",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone015"] = {
			{name = "effect_fabao_10003_Bone014",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone016"] = {
			{name = "effect_fabao_10003_Bone014",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone006"] = {
			{name = "effect_fabao_10003_Bone006",show_type = 4,load_lv = 3,scale = 1},
		},		
		["Dummy001"] = {
			{name = "effect_fabao_10003_Dummy001",show_type = 4,load_lv = 3,scale = 1},
		},	
	},
	-- 通晓水晶
	    ["model_fabao_10004"] = {
		["Bone012"] = {
			{name = "effect_fabao_10004_Bone012",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone007"] = {
			{name = "effect_fabao_10004_Bone007",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone010"] = {
			{name = "effect_fabao_10004_Bone010",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone020"] = {
			{name = "effect_fabao_10004_Bone020",show_type = 2,load_lv = 3,scale = 1},
		},		
		["Bone003"] = {
			{name = "effect_fabao_10004_Bone003",show_type = 2,load_lv = 3,scale = 1},
		},	
		["Bone004"] = {
			{name = "effect_fabao_10004_Bone003",show_type = 4,load_lv = 3,scale = 1},
		},	
		["Bone005"] = {
			{name = "effect_fabao_10004_Bone003",show_type = 4,load_lv = 3,scale = 1},
		},	
		["Bone014"] = {
			{name = "effect_fabao_10004_Bone014",show_type = 4,load_lv = 3,scale = 1},
		},	
		["Bone022"] = {
			{name = "effect_fabao_10004_Bone022",show_type = 4,load_lv = 3,scale = 1},
		},	
		["model_fabao_10004"] = {
			{name = "effect_fabao_10004_Dummy002",show_type = 2,load_lv = 3,scale = 1},
		},	
	},
	-- 时之沙漏
	    ["model_fabao_10005"] = {
		["Bone001"] = {
			{name = "effect_fabao_10005_Bone001",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone002"] = {
			{name = "effect_fabao_10005_Bone002",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone003"] = {
			{name = "effect_fabao_10005_Bone003",show_type = 4,load_lv = 3,scale = 1},
		},
		["Dummy002"] = {
			{name = "effect_fabao_10005_Dummy002",show_type = 2,load_lv = 3,scale = 1},
		},		
		["Dummy001"] = {
			{name = "effect_fabao_10005_Dummy001",show_type = 2,load_lv = 3,scale = 1},
		},		
	},
	-- 钢铁之魂
	    ["model_fabao_10006"] = {	
		["Dummy001"] = {
			{name = "effect_fabao_10006",show_type = 2,load_lv = 3,scale = 1},
		},		
	},
	-- 黎明之光
	    ["model_fabao_10010"] = {
		["Bone001"] = {
			{name = "effect_fabao_10010_Bone001",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone004"] = {
			{name = "effect_fabao_10010_Bone004",show_type = 2,load_lv = 3,scale = 1},
		},
		["Bone005"] = {
			{name = "effect_fabao_10010_Bone004",show_type = 2,load_lv = 3,scale = 1},
		},
	},
	-- 神后金盏
	    ["model_fabao_10015"] = {
		["Bone001"] = {
			{name = "effect_fabao_10015_Bone001",show_type = 2,load_lv = 3,scale = 1},
		},
	},
----------------------------------------------------男翅膀----------------------------------------------------------
	-- 默认翅膀
	    ["model_wing_10000"] = {
	    ["Bone001"] = {
			{name = "effect_wing_10000_Bone001",show_type = 2,load_lv = 3,scale = 1},
	    },		
	    ["Bone002"] = {
			{name = "effect_wing_10000_Bone002",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone005"] = {
			{name = "effect_wing_10000_Bone005",show_type = 2,load_lv = 3,scale = 1},
	    },	
	    ["Bone007"] = {
			{name = "effect_wing_10000_Bone007",show_type = 1,load_lv = 3,scale = 1},
	    },

	},
	-- 泰坦光羽
	    ["model_wing_11001"] = {
		["Bone005"] = {
			{name = "effect_wing_11001_Bone005",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone008"] = {
			{name = "effect_wing_11001_Bone008",show_type = 1,load_lv = 3,scale = 1},
		},
	
	},
	-- 仙林幽羽
	    ["model_wing_11002"] = {
		["Bone002"] = {
			{name = "effect_wing_11002_Bone002",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone007"] = {
			{name = "effect_wing_11002_Bone007",show_type = 1,load_lv = 3,scale = 1},
		},
	
	},
	-- 魔鸢巨翼
	    ["model_wing_11003"] = {
	    ["Bone002"] = {
			{name = "effect_wing_11003_Bone002",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone015"] = {
			{name = "effect_wing_11003_Bone015",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone018"] = {
			{name = "effect_wing_11003_Bone018",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone001"] = {
			{name = "effect_wing_11003_Bone001",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone028"] = {
			{name = "effect_wing_11003_Bone028",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone007"] = {
			{name = "effect_wing_11003_Bone007",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone031"] = {
			{name = "effect_wing_11003_Bone031",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone006"] = {
			{name = "effect_wing_11003_Bone006",show_type = 1,load_lv = 3,scale = 1	    },
	    },	
	},
	-- 圣灵羽翼
	    ["model_wing_11004"] = {
	    ["Bone015"] = {
			{name = "effect_wing_11004_Bone015",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone020"] = {
			{name = "effect_wing_11004_Bone020",show_type = 1,load_lv = 3,scale = 1	    },
	    },	
	},
	-- 马赫动力
	    ["model_wing_11005"] = {
	    ["Bone009"] = {
			{name= "effect_wing_11005_Bone009",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone011"] = {
			{name= "effect_wing_11005_Bone011",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone019"] = {
			{name= "effect_wing_11005_Bone019",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone023"] = {
			{name= "effect_wing_11005_Bone023",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone005"] = {
			{name= "effect_wing_11005_Bone005",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone026"] = {
			{name= "effect_wing_11005_Bone026",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone009(mirrored)"] = {
			{name= "effect_wing_11005_Bone009_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone011(mirrored)"] = {
			{name= "effect_wing_11005_Bone011_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone019(mirrored)"] = {
			{name= "effect_wing_11005_Bone019_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone023(mirrored)"] = {
			{name= "effect_wing_11005_Bone023_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone005(mirrored)"] = {
			{name= "effect_wing_11005_Bone005_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone007(mirrored)"] = {
			{name= "effect_wing_11005_Bone007_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone029"] = {
			{name= "effect_wing_11005_Bone029",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone028"] = {
			{name= "effect_wing_11005_Bone028",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Dummy001"] = {
			{name= "effect_wing_11005_Dummy001",show_type = 1,load_lv = 3,scale = 1},
	    },

	},
	-- 凝羽魔翼
	    ["model_wing_11006"] = {
	    ["Bone028(mirrored)"] = {
			{name = "effect_wing_11006_Bone028_mirrored",show_type = 1,load_lv = 3,scale = 1	    },
	    },
	    ["Bone028"] = {
			{name = "effect_wing_11006_Bone028",show_type = 1,load_lv = 3,scale = 1	    },
	    },	
	},







----------------------------------------------------女翅膀----------------------------------------------------------
	-- 泰坦光羽
	    ["model_wing_12001"] = {
		["Bone008"] = {
			{name = "effect_wing_12001_Bone008",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone002"] = {
			{name = "effect_wing_12001_Bone002",show_type = 4,load_lv = 3,scale = 1},
		},
		["Bone005"] = {
			{name = "effect_wing_12001_Bone005",show_type = 1,load_lv = 3,scale = 1},
			{name = "effect_wing_12001_Bone005_01",show_type = 1,load_lv = 3,scale = 1},
		},	
	},
	-- 仙林幽羽
	    ["model_wing_12002"] = {
		["Bone002"] = {
			{name = "effect_wing_12002_Bone002",show_type = 1,load_lv = 3,scale = 1},
		},
		["Bone007"] = {
			{name = "effect_wing_12002_Bone007",show_type = 1,load_lv = 3,scale = 1},
		},
	
	},
	-- 魔鸢巨翼
	    ["model_wing_12003"] = {
	    ["Bone003"] = {
			{name = "effect_wing_12003_Bone003",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone015"] = {
			{name = "effect_wing_12003_Bone015",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone018"] = {
			{name = "effect_wing_12003_Bone018",show_type = 4,load_lv = 3,scale = 1},
	    },
	    ["Bone001"] = {
			{name = "effect_wing_12003_Bone001",show_type = 4,load_lv = 3,scale = 1},
	    },
	    ["Bone007"] = {
			{name = "effect_wing_12003_Bone007",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone028"] = {
			{name = "effect_wing_12003_Bone028",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone031"] = {
			{name = "effect_wing_12003_Bone031",show_type = 4,load_lv = 3,scale = 1},
	    },
	    ["Bone006"] = {
			{name = "effect_wing_12003_Bone001_Bone006",show_type = 4,load_lv = 3,scale = 1},
	    },
	},	
	-- 圣灵羽翼
	    ["model_wing_12004"] = {
	    ["Bone015"] = {
			{name = "effect_wing_12004_Bone015",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone021"] = {
			{name = "effect_wing_12004_Bone021",show_type = 1,load_lv = 3,scale = 1},
	    },	
	
	},
	-- 马赫动力
	["model_wing_12005"] = 
	{
	    ["Bone009"] = {
			{name = "effect_wing_12005_Bone009",show_type = 4,load_lv = 3,scale = 1},
	    },
	    ["Bone011"] = {
		{name = "effect_wing_12005_Bone011",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone019"] = {
			{name = "effect_wing_12005_Bone019",show_type = 4,load_lv = 3,scale = 1},
	    },
	    ["Bone023"] = {
			{name = "effect_wing_12005_Bone023",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone005"] = {
			{name = "effect_wing_12005_Bone005",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone007"] = {
			{name = "effect_wing_12005_Bone007",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone026"] = {
			{name = "effect_wing_12005_Bone026",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone009(mirrored)"] = {
			{name = "effect_wing_12005_Bone009_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone011(mirrored)"] = {
			{name = "effect_wing_12005_Bone011_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone019(mirrored)"] = {
			{name = "effect_wing_12005_Bone019_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone023(mirrored)"] = {
			{name = "effect_wing_12005_Bone023_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone005(mirrored)"] = {
			{name = "effect_wing_12005_Bone005_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone007(mirrored)"] = {
			{name = "effect_wing_12005_Bone007_mirrored",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Bone028"] = {
			{name = "effect_wing_12005_Bone028",show_type = 1,load_lv = 3,scale = 1},
	    },
	    ["Dummy001"] = {
			{name = "effect_wing_12005_Dummy001",show_type = 1,load_lv = 3,scale = 1},
	    },

	},

	-- 凝羽魔翼
    ["model_wing_12006"] = 
    {
	    ["Bone005"] = {
			{name = "effect_wing_12006_Bone005",show_type = 2,load_lv = 3,scale = 1},
		},
	    ["Bone005(mirrored)"] = {
			{name = "effect_wing_12006_Bone005_mirrored",show_type = 1,load_lv = 3,scale = 1},
		},
	    ["Bone010"] = {
			{name = "effect_wing_12006_Bone010",show_type = 1,load_lv = 3,scale = 1},
		},
	    ["Bone014"] = {
			{name = "effect_wing_12006_Bone014",show_type = 4,load_lv = 3,scale = 1},
		},

	    ["Bone016(mirrored)"] = {
			{name = "effect_wing_12006_Bone016_mirrored",show_type = 4,load_lv = 3,scale = 1},
		},
	},	
}




-- 测试代码

-- for abName,node_list in pairs(ModelEffectConfig) do
-- 	for node_name,effect_list in pairs(node_list) do
-- 		for k,effect in pairs(effect_list) do
-- 			effect.show_type = 3
-- 		end
-- 	end
-- end