--
-- @Author: LaoY
-- @Date:   2019-04-25 10:36:54
--

-- 详细说明见 FightConfig
local config = {
	--猫动作配置
	[701000] = {
		skill_id 	= {701000,701100,701200,701300},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_bigger_bianshenhudun",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_10001_bigger_bianshenqianxuli",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[701001] = {
		skill_id 	= {701001,701101,820001},
		-- 0.3
		action_time = 1.100,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.100, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.5,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.5,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_attack01",
				start_time=0.24,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.24,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[701011] = {
		skill_id 	= {701011,701012,701013,820002},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_attack02",
				start_time=0.35,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_10001_attack02_jianqi",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		-- camera_infos =  
		-- {
			-- {
				-- shake_start_time = 0.2,       --开始震动的时间
				-- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =1,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[701021] = {
		skill_id 	= {701021,701022,701023,820003},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_skil01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_10001_skil01_longjuanfeng",
				start_time=0.56,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--波比动作配置
	
	[702000] = {
		skill_id 	= {702000,702100,702200,702300},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10002_bigger",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			-- {
				-- name = "effect_pet_10001_bigger_bianshenqianxuli",
				-- start_time=0,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[702001] = {
		skill_id 	= {702001,702101,820007},
		-- 0.3
		action_time = 0.967,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.967, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10002_attack01",
				start_time=0.34,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.34,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[702011] = {
		skill_id 	= {702011,702012,702013,820008},
		-- 0.3
		action_time = 0.967,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.967, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10002_attack02",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.4,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[702021] = {
		skill_id 	= {702021,702022,702023,820009},
		-- 0.3
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.167, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10002_skill01",
				start_time=0.35,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 200,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.35,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--雷霆咆哮动作配置
	[703000] = {
		skill_id 	=  {703000,703100,703200,703300},
		-- 0.3
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.167, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_bigger",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},

		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[703001] = {
		skill_id 	= {703001,703101,820010},
		-- 0.3
		action_time = 1.767,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.767, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.1,0.3},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_attack02",
				start_time=0,				--特效开始时间
				play_count = 1,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[703011] = {
		skill_id 	= {703011,703012,703013,820011},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_attack01_fx",
				start_time=0.47,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[703021] = {
		skill_id 	= {703021,703022,703023,820012},
		-- 0.3
		action_time = 1.5,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.5, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "model_pet_10003_show_daiji",
				start_time=0.11,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "model_pet_10003_show_leipi",
				start_time=0.43,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			-- {
				-- name = "effect_pet_10003_show_leipi",
				-- start_time=0,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--熔岩魔蟹动作配置
	[704000] = {
		skill_id 	=  {704000,704100,704200,704300},
		-- 0.3
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.167, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10004_bigger",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			-- {
				-- name = "effect_pet_10001_bigger_bianshenqianxuli",
				-- start_time=0,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[704001] = {
		skill_id 	= {704001,704101,820013},
		-- 0.3
		action_time = 1.00,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.00, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_model_pet_10004_attack01",
				start_time=0.02,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.1,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =4,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[704011] = {
		skill_id 	= {704011,704012,704013,820014},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_model_pet_10004_attack02",
				start_time=0.12,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =2,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[704021] = {
		skill_id 	= {704021,704022,704023,820015},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10004_skill01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--断罪者动作配置
	[705000] = {
		skill_id 	= {705000,705100,705200,705300},
		-- 0.3
		action_time = 1.3,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10005_bigger",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},

		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[705001] = {
		skill_id 	= {705001,705101,820016},
		-- 0.3
		action_time = 1.067,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.067, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10005_attack01",
				start_time=0.2,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[705011] = {
		skill_id 	= {705011,705012,705013,820017},
		-- 0.3
		action_time = 1.467,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.467, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10005_attack02",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[705021] = {
		skill_id 	= {705021,705022,705023,820018},
		-- 0.3
		action_time = 1.667,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.667, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10005_skill01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},


	--巨神兵动作配置
	[706000] = {
		skill_id 	= {706000,706100,706200,706300},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_bigger_bianshenhudun",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_10001_bigger_bianshenqianxuli",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[706001] = {
		skill_id 	= {706001,706101,820019},
		-- 0.3
		action_time = 1.100,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.100, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[706011] = {
		skill_id 	= {706011,706012,706013,820020},
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.733, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "model_pet_10003_show_daiji",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[706021] = {
		skill_id 	= {706021,706022,706023,820021},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10001_attack02_jianqi",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--暗夜狼人动作配置
	[707000] = {
		skill_id 	= {707000,707100,707200,707300},
		-- 0.3
		action_time = 2.133,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 2.133, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20002_bigger",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			-- {
				-- name = "effect_pet_10001_bigger_bianshenqianxuli",
				-- start_time=0,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[707001] = {
		skill_id 	= {707001,707101,820022},
		-- 0.3
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.167, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20001_attack02",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		-- camera_infos =  
		-- {
			-- {
				-- shake_start_time = 0.4,       --开始震动的时间
				-- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =1,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[707011] = {
		skill_id 	= {707011,707012,707013,820023},
		-- 0.3
		action_time = 1.2,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.2, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20002_attack02",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		-- camera_infos =  
		-- {
			-- {
				-- shake_start_time = 0.2,       --开始震动的时间
				-- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =1,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[707021] = {
		skill_id 	= {707021,707022,707023,820024},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20002_skill01",
				start_time=0.5,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--小红羊动作配置
	[708000] = {
		skill_id 	= {708000,708100,708200,708300},
		-- 0.3
		action_time = 0.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.833, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[708001] = {
		skill_id 	= {708001,708101,820004},
		-- 0.3
		action_time = 1.000,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.000, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
			-- {
				-- name = "effect_pet_20003_attack01_dandao",
				-- start_time=0.3,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },
			-- {
				-- name = "effect_pet_20003_attack01_skill01",
				-- start_time=0,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },			
			
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[708011] = {
		skill_id 	= {708011,708012,708013,820005},
		-- 0.3
		action_time = 0.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time =0.833, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_attack02",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[708021] = {
		skill_id 	= {708021,708022,708023,820006},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			-- {
				-- name = "effect_pet_20003_skill01",
				-- start_time=0,				--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			-- },
			{
				name = "effect_pet_20003_skill01_baozha",
				start_time=0.523,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 400,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},
	--美人鱼剧情动作配置
	[99000] = {
		skill_id 	= {99000},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_bigger",
				start_time=0.45,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},


	--美人鱼动作配置
	[709000] = {
		skill_id 	= {709000,709100,709200,709300},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_bigger",
				start_time=0.45,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},


	[709001] = {
		skill_id 	= {709001,709101,709002,709102,820025,99004,99006},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_attack01",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[709011] = {
		skill_id 	= {709011,709012,709013,99008},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.55,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.55,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_attack02",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 3,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[709021] = {
		skill_id 	= {709021,709022,709023,99011},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time =1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_skill01",
				start_time=0.3,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[820026] = {
		skill_id 	= {820026},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.55,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.55,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_attack01",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[820027] = {
		skill_id 	= {820027},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time =1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20005_skill01",
				start_time=0.3,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	--洛克人动作配置
	[710000] = {
		skill_id 	= {710000,710100,710200,710300},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20004_bigger",
				start_time=0.06,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_20004_bigger_kuo",
				start_time=0.34,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[710001] = {
		skill_id 	= {710001,710101,820028},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20004_attack01",
				start_time=0.02,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[710011] = {
		skill_id 	= {710011,710012,710013,820029},
		-- 0.3
		action_time = 1.7,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.7, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20004_attack02",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[710021] = {
		skill_id 	= {710021,710022,710023,820030},
		-- 0.3
		action_time = 1.667,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.667, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20004_skill01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_20004_skill01_daoguang",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},

		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

--洛克人动作配置
	[711000] = {
		skill_id 	= {711000,711100,711200,711300},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "Bigger",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10007_bigger",
				start_time=0.06,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_10007_bigger_kuo",
				start_time=0.34,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[711001] = {
		skill_id 	= {711001,711101},
		-- 0.3
		action_time = 1,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10007_attack01",
				start_time=0.02,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[711011] = {
		skill_id 	= {711011,711012,711013},
		-- 0.3
		action_time = 1.7,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.7, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack2",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10007_attack02",
				start_time=0.4,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				-- distance = 300, 		--弹道距离 测试			
				-- time = 0.2, 			--弹道时间 测试
			},
		},
		
		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},

	[711021] = {
		skill_id 	= {711021,711022,711023},
		-- 0.3
		action_time = 1.667,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.667, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.52,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.52,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10007_skill01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
			{
				name = "effect_pet_10007_skill01_daoguang",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				distance = 300, 		--弹道距离 测试			
				time = 0.2, 			--弹道时间 测试
			},
		},

		camera_infos =  
		{
			{
				shake_start_time = 0.2,       --开始震动的时间
				shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =1,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},

		-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 12, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},
}

local function AddConfig()
	for k,v in pairs(config) do
		FightConfig.SkillConfig[k] = v
	end
end
AddConfig()

-- 单个配置对应多个
-- local function HandeMulConfig()
-- 	local t = {}
-- 	for skill_id,v in pairs(FightConfig.SkillConfig) do
-- 		local skill = v.skill_id
-- 		v.skill_id = skill_id
-- 		if skill and type(skill) == "table" then
-- 			t[skill_id] = skill
-- 		end
-- 	end

-- 	for skill_id,list in pairs(t) do
-- 		for k,_skill_id in pairs(list) do
-- 			FightConfig.SkillConfig[_skill_id] = clone(FightConfig.SkillConfig[skill_id])
-- 			FightConfig.SkillConfig[_skill_id].skill_id = _skill_id
-- 		end
-- 	end
-- end
-- HandeMulConfig()