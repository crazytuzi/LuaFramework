--
-- @Author: LaoY
-- @Date:   2019-12-25 19:46:26
-- 机甲技能配置

-- 详细说明见 FightConfig
local config = {
	--机甲变身配置
	[910000] = {
		skill_id 	=  {910000},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "idle",			-- 动作名字
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
				name = "effect_machiaction_10002_bigger",
				start_time=0,				--特效开始时间
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
	[940001] = {
		skill_id 	= {940001},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.9, 					-- 动作检查融合的时间
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
				name = "effect_machiaction_10002_attack1",
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
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.55,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 15,               --1上下 2左右 3拉伸
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
	[930001] = {
		skill_id 	= {930001},
		-- 0.3
		action_time = 1.567,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.43,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.43,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.2,0.3,0.4,0.5,0.6},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10002_skill1",
				start_time=0,				--特效开始时间
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
			    shake_start_time = 0.43,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =10,          --震动的幅度 像素  
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
	[930002] = {
		skill_id 	= {930002},
		-- 0.3
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.167, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "skill2",			-- 动作名字
		hurt_action_time = 0,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.05,0.15,0.25,0.35,0.45,0.8},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}					
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10002_skill2",
				start_time=0,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =15,          --震动的幅度 像素  
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
	[930003] = {
		skill_id 	= {930003},
		-- 0.3
		action_time = 1.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.833, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.8,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.8,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		-- mul = {1,1.2,1.5,1.8},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10002_skill3",
				start_time=0,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =30,          --震动的幅度 像素  
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

	[911000] = {
		skill_id 	=  {911000},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "idle",			-- 动作名字
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
				name = "effect_machiaction_10002_bigger",
				start_time=0,				--特效开始时间
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
	[941001] = {
		skill_id 	= {941001},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.25,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.25,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0,0.3},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_attack1",
				start_time=0,				--特效开始时间
				play_count = 1,				--播放次数
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
	[931001] = {
		skill_id 	= {931001},
		-- 0.3
		action_time = 1.567,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.9, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.10,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.10,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.1,0.3,0.5,0.7,0.9,1.1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill1",
				start_time=0.47,				--特效开始时间
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
			    -- shake_start_time = 0.4,       --开始震动的时间
			    -- shake_lase_time = 0.3,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =15,          --震动的幅度 像素  
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
	[931002] = {
		skill_id 	= {931002},
		-- 0.3
		action_time = 1.1667,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.667, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.8,		-- 伤害飘字
		action_name = "skill2",			-- 动作名字
		hurt_action_time = 0.8,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		-- mul = {0.1,0.3,0.5,0.7,1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill2",
				start_time=0.11,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
			-- {
			    -- shake_start_time = 1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 1,               --1上下 2左右 3拉伸
				-- shake_max_range =20,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },	
			
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
	[931003] = {
		skill_id 	= {931003},
		-- 0.3
		action_time = 1.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.833, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.65,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.65,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.3,0.45,0.55,0.7,0.8,1,1.15},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill3",
				start_time=0,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =30,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
			{
			    shake_start_time = 1,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 1.1,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.3,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.5,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.7,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},		
			{
			    shake_start_time = 1.9,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 2.1,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 2.2,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
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

	[912000] = {
		skill_id 	=  {912000},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "idle",			-- 动作名字
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
				name = "effect_machiaction_10002_bigger",
				start_time=0,				--特效开始时间
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
	[942001] = {
		skill_id 	= {942001},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.25,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.25,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0,0.3},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_attack1",
				start_time=0,				--特效开始时间
				play_count = 1,				--播放次数
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
	[932001] = {
		skill_id 	= {932001},
		-- 0.3
		action_time = 1.567,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.9, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.10,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.10,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.1,0.3,0.5,0.7,0.9,1.1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill1",
				start_time=0.47,				--特效开始时间
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
			    -- shake_start_time = 0.4,       --开始震动的时间
			    -- shake_lase_time = 0.3,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =15,          --震动的幅度 像素  
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
	[932002] = {
		skill_id 	= {932002},
		-- 0.3
		action_time = 1.1667,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.667, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.8,		-- 伤害飘字
		action_name = "skill2",			-- 动作名字
		hurt_action_time = 0.8,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		-- mul = {0.1,0.3,0.5,0.7,1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill2",
				start_time=0.11,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
			-- {
			    -- shake_start_time = 1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 1,               --1上下 2左右 3拉伸
				-- shake_max_range =20,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },	
			
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
	[932003] = {
		skill_id 	= {932003},
		-- 0.3
		action_time = 1.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.833, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.65,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.65,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.3,0.45,0.55,0.7,0.8,1,1.15},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill3",
				start_time=0,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =30,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
			{
			    shake_start_time = 1,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 1.1,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.3,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.5,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.7,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},		
			{
			    shake_start_time = 1.9,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 2.1,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 2.2,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
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

	[913000] = {
		skill_id 	=  {913000},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "idle",			-- 动作名字
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
				name = "effect_machiaction_10002_bigger",
				start_time=0,				--特效开始时间
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
	[943001] = {
		skill_id 	= {943001},
		-- 0.3
		action_time = 1.333,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.333, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.25,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.25,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0,0.3},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_attack1",
				start_time=0,				--特效开始时间
				play_count = 1,				--播放次数
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
	[933001] = {
		skill_id 	= {933001},
		-- 0.3
		action_time = 1.567,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.9, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.10,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.10,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.1,0.3,0.5,0.7,0.9,1.1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill1",
				start_time=0.47,				--特效开始时间
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
			    -- shake_start_time = 0.4,       --开始震动的时间
			    -- shake_lase_time = 0.3,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =15,          --震动的幅度 像素  
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
	[933002] = {
		skill_id 	= {933002},
		-- 0.3
		action_time = 1.1667,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.667, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.8,		-- 伤害飘字
		action_name = "skill2",			-- 动作名字
		hurt_action_time = 0.8,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		-- mul = {0.1,0.3,0.5,0.7,1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill2",
				start_time=0.11,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
			-- {
			    -- shake_start_time = 1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 1,               --1上下 2左右 3拉伸
				-- shake_max_range =20,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },	
			
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
	[933003] = {
		skill_id 	= {933003},
		-- 0.3
		action_time = 1.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.833, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.65,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.65,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		mul = {0.3,0.45,0.55,0.7,0.8,1,1.15},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}				
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		},

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_machiaction_10001_skill3",
				start_time=0,				--特效开始时间
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
			    shake_start_time = 0.8,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =30,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
			{
			    shake_start_time = 1,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 1.1,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.3,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.5,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},
			{
			    shake_start_time = 1.7,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},		
			{
			    shake_start_time = 1.9,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 2.1,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
				start_angle = 0
			},	
			{
			    shake_start_time = 2.2,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 180,            --震动的角度  
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