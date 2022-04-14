-- 
-- @Author: LaoY
-- @Date:   2018-07-26 16:06:20
-- 

FightConfig = FightConfig or {}

--普通技能
FightConfig.OrdinarySkill = {
	[1] = {
		101001,
		101002,
		101003,
		101004,

	},
	[2] = {
		201001,
		201002,
		201003,
		201004,
	},
}
-- 普工连击的时间
FightConfig.OrdinaryCombTime = 5.0
--技能公共CD
FightConfig.PublicCD 			= 0.2
FightConfig.PublicOrdinaryCD 	= 0.2

-- 特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
FightConfig.EffectType = {
	Pos = 1,
	Attack = 2,
	Hit = 3,
	Attack2Pos = 4,
	Hit2Pos = 5,

	-- 弹道技能
	BallisticPos 	= 11,
	BallisticDir 	= 12,
	BallisticTrack 	= 13,
	BallisticMulPos = 14,

	Hurt = 20,
}

--[[
	@author LaoY

	/*必要配置*/
	/*技能配置说明*/ 
	@param skill_id				技能id
	@param action_time			动作时间,可以不填。默认是获取动作时间播放
	
	/*非必要配置*/
	/*技能配置说明*/
	@param forward_time			动作前摇,前摇时间可以给打断
	@param fuse_time			动作检查融合的时间
	@param hurt_text_start_time	伤害飘字的时间
	@param action_name			技能对应动作名字
	@param hurt_action_time		受击动作开始的时间 怪物有效
	@param hurt_action_name		受击动作的名字	怪物有效 目前只有一个动作
	
	/*非必要配置*/
	/*特效说明*/ effect lua table
	@param name					特效名字
	@param start_time			特效开始时间
	@param play_time			播放时间，计算优先级高于播放次数
	@param play_count			播放次数
	@param root_type			父节点类型 1头、45左右手、6手、7脚底(模型根节点)、89左右脚、10腰部、14坐骑、15坐骑根节点、16翅膀、20场景层
	@param career				职业
	@param rotate_type			旋转角度类型,1根据角色旋转,2不旋转
	@param effect_type			特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
	@param offset				偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。
	@param distance 			弹道类型才有效，弹道距离
	@param time 				弹道类型才有效，弹道时间
	
	/*非必要配置*/
	/*摄像机震屏说明*/ camera_infos lua table
	@param shake_start_time   	开始震动的时间
    @param shake_lase_time    	震动的总时间 
	@param shake_type       	1上下 2左右 3拉伸
	@param shake_max_range     	震动的幅度 像素  
	@param shake_angle        	震动的角度  
	@param start_angle 			开始角度
	
	/*非必要配置*/
	/*受击变色*/ hit_color lua table
	@param color   				受击颜色
	@param time   				受击颜色变色时间
	@param scale   				受击颜色 菲涅尔倍数(广度)
	@param bias   				受击颜色 菲涅尔范围(亮度)
	
	/*非必要配置*/
	/*击退*/		repel	lua table
	@param distance   			击退距离
	@param time   				击退时间
	@param rate_type   			击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
	@param rate   				缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速

	/*非必要配置*/
	/*技能位移*/		slip	lua table
	@param distance   			位移距离
	@param type   				位移类型 1.到点 2.最多位移到目标点前方，不会穿过目标点
	@param start_time   		位移开始时间 不填默认为0
	@param time   				位移时间
	@param rate_type   			击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
	@param rate   				缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速

	/*非必要配置*/
	/*战斗音效*/		sound 	lua table 攻击音效 主角才生效
	@param id 					音效id
	@param time 				延迟多久播放
	@param type 				1.攻击音效 2.受击音效（暂无）
	
	/*非必要配置*/
	/*多段伤害配置*/
	@param mul 					多段伤害 {第一段延迟时间，第二段延迟时间...}
--]]
FightConfig.SkillConfig = {
	------******男剑客******------
	--普通攻击1
	[101001] = {
		skill_id 	= 101001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- mul = {0,0.5,1},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack01",
				start_time=0.1,				--特效开始时间
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
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 12, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},
	--普通攻击2
	[101002] = {
		skill_id 	= 101002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack02",
				start_time=0.06, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 13, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},	
	},
	--普通攻击3
	[101003] = {
		skill_id 	= 101003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			},
			
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =3,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 14, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},	

	--普通攻击4
	[101004] = {
		skill_id 	= 101004,
		action_time = 1.067,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.6, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.3,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =10,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的0角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 15, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[101005] = {
		skill_id 	= 101005,
		action_time = 1.1,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.6, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.25,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.45,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},
		mul = {0.1,0.25},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}


		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill01_shandian",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--不旋转 1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 100,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.46,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.45,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
			-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[101006] = {
		skill_id 	= 101006,
		action_time = 1.5,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 1, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.6,		-- 伤害飘字
		action_name = "skill2",		-- 动作名字
		hurt_action_time = 0.79,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill02_daoguangzhan",
				start_time=0.1, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 80,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.40,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		}, 
		camera_infos =  
		{
			{
			    shake_start_time = 0.55,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 9, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	
	--技能
	[101007] = {
		skill_id 	= 101007,
		action_time = 1.433,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 1.267, 				-- 动作前摇
		fuse_time = 1.1, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.55,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.55,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		mul = {0,0.1,0.2,0.3},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill03",
				start_time=0.17, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_male_skill03_feng",
				start_time=0.25, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.55,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 2,               --1上下 2左右 3拉伸
				shake_max_range =5,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 10, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[101008] = {
		skill_id 	= 101008,
		action_time = 1.533,				-- 动作时间,可以不填。默认是获取动作时间播放
		-- action_time = 2.033,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 1, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.58,		-- 伤害飘字
				--hurt_text_start_time = 0.18,0.34,1.017		-- 伤害飘字
		action_name = "skill4",		-- 动作名字
		hurt_action_time = 0.5,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作				
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		slip = { 							-- 技能位移
			distance  = 200,					-- 位移最大距离
			type = 2,						-- 1.到点 2.最多位移到目标点前方，不会穿过目标点
			time 	  = 0.5,				-- 位移时间
			rate_type = 4,					-- 击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			rate 	  = 10,					-- 缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		},

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 300,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.64,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.6,       --开始震动的时间
			    shake_lase_time = 0.3,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =8,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 11, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	--技能
	[101009] = {
		skill_id 	= 101009,
		action_time = 1.5,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.5, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "skill5",		-- 动作名字
		hurt_action_time = 0.5,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_cangqionghujia_101009_baokai",
				start_time=0, 
				play_count = 1,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type =4 ,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_male_cangqionghujia_101009",
				start_time=0, 
				play_count = 1,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type =2 ,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
	
		}, 
		camera_infos =  
		{
			{
			    shake_start_time = 0.2,       --开始震动的时间
			    shake_lase_time = 0.18,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =2,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
	},

	--技能
	[101010] = {
		skill_id 	= {101010,101009},
		action_time = 1.5,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.5, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "skill5",		-- 动作名字
		hurt_action_time = 0.5,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_cangqionghujia_101009_baokai",
				start_time=0, 
				play_count = 1,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type =4 ,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_male_cangqionghujia_101009",
				start_time=0, 
				play_count = 1,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type =2 ,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
	
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.2,       --开始震动的时间
			    shake_lase_time = 0.18,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =2,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
	},

	--技能
	[101011] = {
		skill_id 	= 101011,
		action_time = 1.233,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 1.167, 				-- 动作前摇
		fuse_time = 0.3, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.5,		-- 伤害飘字
		action_name = "skill6",			-- 动作名字
		hurt_action_time = 0.5,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_luoleitianjie_101011",
				start_time=0.34, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 5,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 200,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

			},
			-- {
				-- name = "effect_male_skill03_longjuanfeng",
				-- start_time=0.3, 
				-- play_count = 0,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 2,		--1根据角色旋转,2不旋转
				-- effect_type = 1,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			-- },
			{
				name = "effect_male_attack_hurt",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.5,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =5,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 55, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[101012] = {
		skill_id 	= 101012,
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		-- action_time = 2.033,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 				-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
				--hurt_text_start_time = 0.18,0.34,1.017		-- 伤害飘字
		action_name = "skill7",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作				
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_leitingzhanyi_101012",
				start_time=0.42, 
				play_count = 15,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 50,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.64,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.5,       --开始震动的时间
			    -- shake_lase_time = 0.3,        --震动的总时间 
				-- shake_type = 1,               --1上下 2左右 3拉伸
				-- shake_max_range =11,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 56, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	[103005] = {
		skill_id 	= 103005,
		action_time = 1.5,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 1, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.6,		-- 伤害飘字
		action_name = "skill2",		-- 动作名字
		hurt_action_time = 0.79,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill02_daoguangzhan",
				start_time=0.15, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 80,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.40,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		}, 
		camera_infos =  
		{
			{
			    shake_start_time = 0.6,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 9, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	
	
	
	
	------******女剑客******------
	--普通攻击1
	[201001] = {
		skill_id 	= 201001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 20, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		

	},
	--普通攻击2
	[201002] = {
		skill_id 	= 201002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
            time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 21, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		
	},
	--普通攻击3
	[201003] = {
		skill_id 	= 201003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
             time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.22,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.22,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =4,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 22, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},
	--普通攻击4
	[201004] = {
		skill_id 	= 201004,
		action_time = 1.000,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.6, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.4,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =8,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 23, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[201005] = {
		skill_id 	= 201005,
		action_time = 1.0,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.8, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.35,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.6,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},
		mul = {0.1,0.2,0.3},		

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			-- {
				-- name = "effect_female_skill01",
				-- start_time=0.2, 		
				-- play_count = 0,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 1,		--1根据角色旋转,2不旋转
				-- effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。

				-- },
			{
				name = "effect_female_skill01_luoxuanhuazhuan",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--不旋转 1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.47,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.47,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 360
			},			
		},
		-- 音效
		sound = {
			{
				id = 16, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[201006] = {
		skill_id 	= 201006,
		action_time = 1.533,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time =0.85, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.65,		-- 伤害飘字
		action_name = "skill2",		-- 动作名字
		hurt_action_time = 0.65,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_skill02_dadaoguang",
				start_time=0.15, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.58,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.65,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
	
		},
		-- 音效
		sound = {
			{
				id = 17, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[201007] = {
		skill_id 	= 201007,
		action_time = 1.233,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 1.167, 				-- 动作前摇
		fuse_time = 1.1, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.6,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		mul = {0.15,0.3,0.45},

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_skill03_baofengqian",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				},
			{
				name = "effect_female_skill03_longjuanfeng",
				start_time=0.3, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.5,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 2,               --1上下 2左右 3拉伸
				shake_max_range =8,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 18, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[201008] = {
		skill_id 	= 201008,
		action_time = 1.667,				-- 动作时间,可以不填。默认是获取动作时间播放
		-- action_time = 2.033,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 1.60, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.85,		-- 伤害飘字
				--hurt_text_start_time = 0.18,0.34,1.017		-- 伤害飘字
		action_name = "skill4",		-- 动作名字
		hurt_action_time = 0.85,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作				
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_skill04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 0,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		
		},
		-- slip = { 							-- 技能位移
			-- distance   = 0,				-- 位移最大距离
			-- type       = 2,					-- 1.到点 2.最多位移到目标点前方，不会穿过目标点
			-- start_time = 0.2,				-- 位移开始时间 不填默认为0
			-- time       = 1,				-- 位移时间
			-- rate_type  = 1,					-- 击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate       = 10,					-- 缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		camera_infos =  
		{
			{
			    shake_start_time = 0.85,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =10,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 19, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	--技能
	[201009] = {
		skill_id 	= 201009,
		action_time = 0.8,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.2, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "skill5",			-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		-- effect = {						-- 技能特效,部分技能由多个特效组成
		-- {
				-- name = "effect_female_xiaguangzhidun_201009",
				-- start_time=0, 
				-- play_count = 10,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 1,		--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			-- },
			-- {
				-- name = "effect_female_attack_hurt",
				-- start_time=0.58,			--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			-- },			
		-- },

		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.47,       --开始震动的时间
			    -- shake_lase_time = 0.15,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =5,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
	},

	--技能
	[201010] = {
		skill_id 	= 201010,
		action_time = 0.8,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.2, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "skill5",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		-- effect = {						-- 技能特效,部分技能由多个特效组成
			-- {
				-- name = "effect_female_xiaguangzhidun_201009",
				-- start_time=0, 
				-- play_count = 10,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 1,		--1根据角色旋转,2不旋转
				-- effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			-- },
			-- {
				-- name = "effect_female_attack_hurt",
				-- start_time=0.58,			--特效开始时间
				-- play_count = 0,				--播放次数
				-- root_type = 7,				--父节点类型
				-- career = 1,
				-- rotate_type = 1,			--1根据角色旋转,2不旋转
				-- effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			-- },			
		-- },
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.56,       --开始震动的时间
			    -- shake_lase_time = 0.3,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =15,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },		
	
		-- },
	},

	--技能
	[201011] = {
		skill_id 	= 201011,
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 1, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.8,		-- 伤害飘字
		action_name = "skill6",			-- 动作名字
		hurt_action_time = 0.8,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成

			{
				name = "effect_female_dingshenbaozha_201011",
				start_time=0.3, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 5,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 250,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.8,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =20,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 57, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[201012] = {
		skill_id 	= 201012,
		action_time = 1.167,				-- 动作时间,可以不填。默认是获取动作时间播放
		-- action_time = 2.033,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time =0.8, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.66,		-- 伤害飘字
				--hurt_text_start_time = 0.18,0.34,1.017		-- 伤害飘字
		action_name = "skill7",		-- 动作名字
		hurt_action_time = 0.66,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作				
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_huimielingyu_201012",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 0,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_female_huimielingyu_201012_01",
				start_time=0.5, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 0,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.65,       --开始震动的时间
			    -- shake_lase_time = 0.2,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =20,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		slip = { 							-- 技能位移
			distance   = 300,				-- 位移最大距离
			type       = 1,					-- 1.到点 2.最多位移到目标点前方，不会穿过目标点
			start_time = 0.4,				-- 位移开始时间 不填默认为0
			time       = 0.2,				-- 位移时间
			rate_type  = 1,					-- 击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			rate       = 10,					-- 缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		},
		-- 音效
		sound = {
			{
				id = 58, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	[203005] = {
		skill_id 	= 203005,
		action_time = 1.533,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.85, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.65,		-- 伤害飘字
		action_name = "skill2",		-- 动作名字
		hurt_action_time = 0.65,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_skill02_dadaoguang",
				start_time=0.15, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.58,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.65,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =5,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},		
	
		},
		-- 音效
		sound = {
			{
				id = 17, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

		------******强化普攻******------
	--男转职2
	[102001] = {
		skill_id 	= 102001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 特效有效。	
			    -- distance = 300, 		--弹道距离 测试			
			    -- time = 0.2, 			--弹道时间 测试
			},
			
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 12, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},
	--普通攻击2
	[102002] = {
		skill_id 	= 102002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 13, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},	
	},
	--普通攻击3
	[102003] = {
		skill_id 	= 102003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			},
			
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =3,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 14, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},	

	--普通攻击4
	[102004] = {
		skill_id 	= 102004,
		action_time = 1.067,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.6, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack04",
				start_time=0.1, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.19,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =10,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的0角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 15, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--男转职3
	[103001] = {
		skill_id 	= 103001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 特效有效。	
			    -- distance = 300, 		--弹道距离 测试			
			    -- time = 0.2, 			--弹道时间 测试
			},
			
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 12, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},
	--普通攻击2
	[103002] = {
		skill_id 	= 103002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 13, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},	
	},
	--普通攻击3
	[103003] = {
		skill_id 	= 103003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			},
			
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =3,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 14, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},	

	--普通攻击4
	[103004] = {
		skill_id 	= 103004,
		action_time = 1.067,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.6, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack04",
				start_time=0.1, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.19,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =10,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的0角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 15, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--女转职1
	--普通攻击1
	[202001] = {
		skill_id 	= 202001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 20, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		

	},
	--普通攻击2
	[202002] = {
		skill_id 	= 202002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
            time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 21, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		
	},
	--普通攻击3
	[202003] = {
		skill_id 	= 202003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
             time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.22,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.22,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =4,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 22, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},
	--普通攻击4
	[202004] = {
		skill_id 	= 202004,
		action_time = 1.000,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.6, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.4,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =8,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 23, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--女转职2
	--普通攻击1
	[203001] = {
		skill_id 	= 203001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 20, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		

	},
	--普通攻击2
	[203002] = {
		skill_id 	= 203002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.1,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
            time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 21, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		
	},
	--普通攻击3
	[203003] = {
		skill_id 	= 203003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.2,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.2,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
             time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.22,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.22,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =4,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 22, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},
	--普通攻击4
	[203004] = {
		skill_id 	= 203004,
		action_time = 1.000,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.6, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.3,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.4,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =8,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 23, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	
	--怒气技能
	--技能
	[205001] = {
		skill_id 	= 205001,
		action_time = 1.0,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.41, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.35,		-- 伤害飘字
		action_name = "empty",			-- 动作名字
		hurt_action_time = 0.6,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},
		mul = {0.1,0.2,0.3},		

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			-- {
				-- name = "effect_female_skill01",
				-- start_time=0.2, 		
				-- play_count = 0,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 1,		--1根据角色旋转,2不旋转
				-- effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。

				-- },
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.47,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 360
			},			
		},
		-- 音效
		sound = {
			{
				id = 16, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	[205002] = {
		skill_id 	= 205002,
		action_time = 1.0,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.41, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.35,		-- 伤害飘字
		action_name = "empty",			-- 动作名字
		hurt_action_time = 0.6,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},
		mul = {0.1,0.2,0.3},		

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			-- {
				-- name = "effect_female_skill01",
				-- start_time=0.2, 		
				-- play_count = 0,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 1,		--1根据角色旋转,2不旋转
				-- effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。

				-- },
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.47,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 360
			},			
		},
		-- 音效
		sound = {
			{
				id = 16, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	
	

		--怪物技能
	--普通攻击1
	--被捆绑的老头
	[301001] = {
		skill_id		=301001,
			-- 0.3
		action_time = 1.733,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.733,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--肥胖的蝙蝠
	[301002] = {
		skill_id		=301002,
			-- 0.3
		action_time = 1.4,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.4,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--弹弓射手
	[301003] = {
		skill_id		=301003,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.64,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--锦鲤王
	[301004] = {
		skill_id		=301004,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--蝴蝶精灵
	[301005] = {
		skill_id		=301005,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.55,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--猫头鹰骑士
	[301006] = {
		skill_id		=301006,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--森林蜘蛛
	[301007] = {
		skill_id		=301007,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--东贝利
	[301008] = {
		skill_id		=301008,
			-- 0.3
		action_time = 1.133,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.133,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.35,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--浣熊战士
	[301009] = {
		skill_id		=301009,
			-- 0.3
		action_time = 1.067,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.067,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--森林精灵
	[301010] = {
		skill_id		=301010,
			-- 0.3
		action_time = 1.433,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.433,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.77,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深林守护熊
	[301011] = {
		skill_id		=301011,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.55,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--磁铁怪
	[301012] = {
		skill_id		=301012,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.36,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--扳手小妹
	[301013] = {
		skill_id		=301013,
			-- 0.3
		action_time = 1.433,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.433,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.4,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--雷电蝙蝠
	[301014] = {
		skill_id		=301002,
			-- 0.3
		action_time = 1.4,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.4,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--机械蝎子
	[301015] = {
		skill_id		=301015,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.575,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--机械熊人
	[301016] = {
		skill_id		=301016,
			-- 0.3
		action_time = 1.4,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.4,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--铁巨人
	[301017] = {
		skill_id		=301017,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.75,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰雪王子
	[301018] = {
		skill_id		=301018,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.58,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰盾守卫
	[301019] = {
		skill_id		=301019,
			-- 0.3
		action_time = 1.533,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.533,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.49,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--企鹅战士
	[301020] = {
		skill_id		=301020,
			-- 0.3
		action_time = 1.433,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.433,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.51,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰原巨人
	[301021] = {
		skill_id		=301021,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
	},
	--女流刺客
	[301022] = {
		skill_id		=301022,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--血色骷髅
	[301023] = {
		skill_id		=301023,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.33,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.64,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--吸血战士
	[301024] = {
		skill_id		=301024,
			-- 0.3
		action_time = 2.067,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.067,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--血怒狂牛
	[301025] = {
		skill_id		=301025,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--荒漠蝎子
	[301026] = {
		skill_id		=301026,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.45,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--炸弹怪
	[302001] = {
		skill_id		=302001,
			-- 0.3
		action_time = 0.8,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 0.8,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.36,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--黄金史莱姆
	[302002] = {
		skill_id		=302002,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.64,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--圣灵剑士
	[302003] = {
		skill_id		=302003,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--圣灵射手
	[302004] = {
		skill_id		=302004,
			-- 0.3
		action_time = 1.533,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.533,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.88,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--圣灵法师
	[302005] = {
		skill_id		=302005,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.666,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--远古法师
	[303001] = {
		skill_id		=303001,
			-- 0.3
		action_time = 1.9,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.9,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--旱灾•迪斯
	[303002] = {
		skill_id		=303002,
			-- 0.3
		action_time = 1.,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.45,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--飓风•莫拉
	[303003] = {
		skill_id		=303003,
			-- 0.3
		action_time = 1.767,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.767,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.86,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--剧毒•乌迪
	[303004] = {
		skill_id		=303004,
			-- 0.3
		action_time = 1.7,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.7,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.64,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰霜•克莉
	[303005] = {
		skill_id		=303005,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--亡语•佐伊
	[303006] = {
		skill_id		=303006,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.46,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--极光•利娜
	[303007] = {
		skill_id		=303007,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.47,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--时空龙
	[303008] = {
		skill_id		=303008,
			-- 0.3
		action_time = 1.633,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.633,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.67,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰石头人
	[303009] = {
		skill_id		=303009,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.47,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火蜘蛛
	[303010] = {
		skill_id		=303010,
			-- 0.3
		action_time = 1.567,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.567,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.85,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰暴君
	[303011] = {
		skill_id		=303011,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--地狱猎犬
	[303012] = {
		skill_id		=303012,
			-- 0.3
		action_time = 1.267,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.267,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.62,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--熔岩守门人
	[303013] = {
		skill_id		=303013,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.467,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰人马
	[303014] = {
		skill_id		=303014,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.4,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--黑龙天照
	[303015] = {
		skill_id		=303015,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰魔人
	[303016] = {
		skill_id		=303016,
			-- 0.3
		action_time = 1.833,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.833,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--狂暴斗鱼
	[303017] = {
		skill_id		=303017,
			-- 0.3
		action_time = 1.2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.4,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--海龙王子
	[303018] = {
		skill_id		=303018,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.56,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--帝王蟹
	[303019] = {
		skill_id		=303019,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.33,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--霜毒蜘蛛
	[303020] = {
		skill_id		=303020,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.63,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深海巨兽
	[303021] = {
		skill_id		=303021,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.75,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--鲨鱼杀手
	[303022] = {
		skill_id		=303022,
			-- 0.3
		action_time = 1.267,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.267,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.57,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深海游龙
	[303023] = {
		skill_id		=303023,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深海领主
	[303024] = {
		skill_id		=303024,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.9,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰雪幽灵
	[303025] = {
		skill_id		=303025,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.55,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--皇城守护
	[303026] = {
		skill_id		=303026,
			-- 0.3
		action_time = 1.6,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.6,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰原骑士
	[303027] = {
		skill_id		=303027,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--审判者
	[303028] = {
		skill_id		=303028,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰原守门人
	[303029] = {
		skill_id		=303029,
			-- 0.3
		action_time = 1.8,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.8,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.85,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰霜领主
	[303030] = {
		skill_id		=303030,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.4,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰炎魔龙
	[303031] = {
		skill_id		=303031,
			-- 0.3
		action_time = 1.833,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.833,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰霜魔人
	[303032] = {
		skill_id		=303032,
			-- 0.3
		action_time = 1.6,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.6,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--青眼白龙
	[303033] = {
		skill_id		=303033,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.666,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--伊利丹•怒风
	[303034] = {
		skill_id		=303034,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--木精灵
	[303035] = {
		skill_id		=303035,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--水精灵
	[303036] = {
		skill_id		=303036,
			-- 0.3
		action_time = 1.333,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火精灵
	[303037] = {
		skill_id		=30303,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--风精灵
	[303038] = {
		skill_id		=303038,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--魅蝎
	[303039] = {
		skill_id		=303039,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--天狼
	[303040] = {
		skill_id		=303040,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--苍龙
	[303041] = {
		skill_id		=303041,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--远古法师
	[304001] = {
		skill_id		=304001,
			-- 0.3
		action_time = 2.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.17,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--旱灾•迪斯
	[304002] = {
		skill_id		=304002,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.98,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--飓风•莫拉
	[304003] = {
		skill_id		=304003,
			-- 0.3
		action_time = 2.533,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.533,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.69,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--剧毒•乌迪
	[304004] = {
		skill_id		=304004,
			-- 0.3
		action_time = 2.3,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.3,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.24,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰霜•克莉
	[304005] = {
		skill_id		=304005,
			-- 0.3
		action_time = 1.7,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.7,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.77,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--亡语•佐伊
	[304006] = {
		skill_id		=304006,
			-- 0.3
		action_time = 1.7,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.7,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--极光•利娜
	[304007] = {
		skill_id		=304007,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.65,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--时空龙
	[304008] = {
		skill_id		=304008,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.54,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰石头人
	[304009] = {
		skill_id		=304009,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.72,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火蜘蛛
	[304010] = {
		skill_id		=304010,
			-- 0.3
		action_time = 2.4,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.4,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.14,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰暴君
	[304011] = {
		skill_id		=304011,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.16,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--地狱猎犬
	[304012] = {
		skill_id		=304012,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.774,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--熔岩守门人
	[304013] = {
		skill_id		=304013,
			-- 0.3
		action_time = 2 ,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.9,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰人马
	[304014] = {
		skill_id		=304014,
			-- 0.3
		action_time = 1.733,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.733,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.72,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--黑龙天照
	[304015] = {
		skill_id		=304015,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.9,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--火焰魔人
	[304016] = {
		skill_id		=304016,
			-- 0.3
		action_time = 2.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--狂暴斗鱼
	[304017] = {
		skill_id		=304017,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.4,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--海龙王子
	[304018] = {
		skill_id		=304018,
			-- 0.3
		action_time = 2.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.35,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--帝王蟹
	[304019] = {
		skill_id		=304019,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.92,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--霜毒蜘蛛
	[304020] = {
		skill_id		=304020,
			-- 0.3
		action_time = 1.867,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.867,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.95,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深海巨兽
	[304021] = {
		skill_id		=304021,
			-- 0.3
		action_time = 1.767,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.767,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--鲨鱼杀手
	[304022] = {
		skill_id		=304022,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.24,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深海游龙
	[304023] = {
		skill_id		=304023,
			-- 0.3
		action_time = 1.767,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.767,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.2,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--深海领主
	[304024] = {
		skill_id		=304024,
			-- 0.3
		action_time = 2.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.4,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰雪幽灵
	[304025] = {
		skill_id		=304025,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--皇城守护
	[304026] = {
		skill_id		=304026,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰原骑士
	[304027] = {
		skill_id		=304027,
			-- 0.3
		action_time = 1.267,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.267,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--审判者
	[304028] = {
		skill_id		=304028,
			-- 0.3
		action_time = 2.533,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.533,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1.85,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰原守门人
	[304029] = {
		skill_id		=304029,
			-- 0.3
		action_time = 1.833,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.833,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.91,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰霜领主
	[304030] = {
		skill_id		=304030,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰炎魔龙
	[304031] = {
		skill_id		=304031,
			-- 0.3
		action_time = 2.200,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2.200,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--冰霜魔人
	[304032] = {
		skill_id		=304032,
			-- 0.3
		action_time = 2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--青眼白龙
	[304033] = {
		skill_id		=304033,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.833,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--伊利丹•怒风
	[304034] = {
		skill_id		=304034,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--魅蝎
	[304039] = {
		skill_id		=304039,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--天狼
	[3034040] = {
		skill_id		=304040,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.55,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--苍龙
	[304041] = {
		skill_id		=304041,
			-- 0.3
		action_time = 1.533,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.533,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.75,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--假面·猫又
	[304501] = {
		skill_id		=304501,
			-- 0.3
		action_time = 1.1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304601] = {
		skill_id		=304601,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304701] = {
		skill_id		=304701,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	

	--火枪·阿西巴
	[304502] = {
		skill_id		=304502,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304602] = {
		skill_id		=304602,
			-- 0.3
		action_time = 0.833,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 0.833,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304702] = {
		skill_id		=304702,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		

	--糖巫·波比
	[304503] = {
		skill_id		=304503,
			-- 0.3
		action_time = 0.967,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 0.967,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304603] = {
		skill_id		=304603,
			-- 0.3
		action_time = 0.3,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 0.3,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304703] = {
		skill_id		=304703,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		
	

	--机甲·鬼熊氏
	[304504] = {
		skill_id		=304504,
			-- 0.3
		action_time = 1.767,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.767,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304604] = {
		skill_id		=304604,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304704] = {
		skill_id		=304704,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		
		
	

	--巨螯·炎吞海
	[304505] = {
		skill_id		=304505,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304605] = {
		skill_id		=304605,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304705] = {
		skill_id		=304705,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		

	--使·心魔
	[304506] = {
		skill_id		=304506,
			-- 0.3
		action_time = 1.067,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.067,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304606] = {
		skill_id		=304606,
			-- 0.3
		action_time = 1.467,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.467,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304706] = {
		skill_id		=304706,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},					
	

	--巨神·贝希摩斯
	[304507] = {
		skill_id		=304507,
			-- 0.3
		action_time = 1.1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304607] = {
		skill_id		=304607,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304707] = {
		skill_id		=304707,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},					
	

	--狼人·噬月
	[304508] = {
		skill_id		=304508,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304608] = {
		skill_id		=304608,
			-- 0.3
		action_time = 1.2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304708] = {
		skill_id		=304708,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		
	

	--美人鱼
	[304509] = {
		skill_id		=304509,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304609] = {
		skill_id		=304609,
			-- 0.3
		action_time = 1.2,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.2,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304709] = {
		skill_id		=304709,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		
	
	--杰洛
	[304510] = {
		skill_id		=304510,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	[304610] = {
		skill_id		=304610,
			-- 0.3
		action_time = 1.7,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.7,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack2",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304710] = {
		skill_id		=304710,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	[304711] = {
		skill_id		=304711,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},		
	[305010] = {
		skill_id		=305010,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},	
	

	[401001] = {
		skill_id 	= 401001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,				--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 特效有效。	
			    -- distance = 300, 		--弹道距离 测试			
			    -- time = 0.2, 			--弹道时间 测试
			},
			
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 12, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},

	},
	--普通攻击2
	[401002] = {
		skill_id 	= 401002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
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
				id = 13, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},	
	},
	--普通攻击3
	[401003] = {
		skill_id 	= 401003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.3,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			},
			
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.1,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =3,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 14, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},	

	--普通攻击4
	[401004] = {
		skill_id 	= 401004,
		action_time = 1.067,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.25,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.24,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_attack04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.19,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =10,          --震动的幅度 像素  
				shake_angle = 360,            --震动的0角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 15, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[401005] = {
		skill_id 	= 401005,
		action_time = 1,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.4, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.38,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.38,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},
		mul = {0.1,0.25},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}


		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill01_shandian",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--不旋转 1根据角色旋转,2不旋转
				effect_type = 1,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 250,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.44,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.21,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
			-- 音效
		sound = {
			{
				id = 8, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[401006] = {
		skill_id 	= 401006,
		action_time = 1.533,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.710, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.60,		-- 伤害飘字
		action_name = "skill2",		-- 动作名字
		hurt_action_time = 0.7,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill02_daoguangzhan",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.40,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		}, 
		camera_infos =  
		{
			{
			    shake_start_time = 0.4,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =3,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 9, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[401007] = {
		skill_id 	= 401007,
		action_time = 1.233,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 1.167, 				-- 动作前摇
		fuse_time = 0.65, 				-- 动作检查融合的时间
		hurt_text_start_time = 0,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.6,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		mul = {0.1,0.6,0.7,0.8},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill03",
				start_time=0.2, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 2,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_male_skill03_longjuanfeng",
				start_time=0.3, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 1,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.6,       --开始震动的时间
			    shake_lase_time = 0.3,        --震动的总时间 
				shake_type = 2,               --1上下 2左右 3拉伸
				shake_max_range =10,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 10, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[401008] = {
		skill_id 	= 401008,
		action_time = 1.533,				-- 动作时间,可以不填。默认是获取动作时间播放
		-- action_time = 2.033,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.7, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
				--hurt_text_start_time = 0.18,0.34,1.017		-- 伤害飘字
		action_name = "skill4",		-- 动作名字
		hurt_action_time = 0.55,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作				
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		slip = { 							-- 技能位移
			distance  = 300,					-- 位移最大距离
			type = 2,						-- 1.到点 2.最多位移到目标点前方，不会穿过目标点
			time 	  = 0.5,				-- 位移时间
			rate_type = 4,					-- 击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			rate 	  = 10,					-- 缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		},

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_male_skill04_chadi",
				start_time=0.0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 250,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_male_attack_hurt",
				start_time=0.64,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.5,       --开始震动的时间
			    shake_lase_time = 0.3,        --震动的总时间 
				shake_type = 1,               --1上下 2左右 3拉伸
				shake_max_range =11,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 11, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	
	
	[402001] = {
		skill_id 	= 402001,
		-- 0.3
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 0.25, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字
		action_name = "attack1",			-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",			-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack01",
				start_time=0,				--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 4,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 20, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		

	},
	--普通攻击2
	[402002] = {
		skill_id 	= 402002,
		action_time = 0.733,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.3, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.20,		-- 伤害飘字ds
		action_name = "attack2",		-- 动作名字
		hurt_action_time = 0.20,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack02",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.20,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- 音效
		sound = {
			{
				id = 21, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
		
	},
	--普通攻击3
	[402003] = {
		skill_id 	= 402003,
		action_time = 0.900,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.4, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "attack3",		-- 动作名字
		hurt_action_time = 0.10,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack03",
				start_time= 0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.22,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		-- camera_infos =  
		-- {
			-- {
			    -- shake_start_time = 0.22,       --开始震动的时间
			    -- shake_lase_time = 0.1,        --震动的总时间 
				-- shake_type = 3,               --1上下 2左右 3拉伸
				-- shake_max_range =4,          --震动的幅度 像素  
				-- shake_angle = 360,            --震动的角度  
				-- start_angle = 0
			-- },			
		-- },
		-- 音效
		sound = {
			{
				id = 22, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},		
	},
	--普通攻击4
	[402004] = {
		skill_id 	= 402004,
		action_time = 1.000,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 0.744, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.360,		-- 伤害飘字
		action_name = "attack4",		-- 动作名字
		hurt_action_time = 0.521,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作

		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },

		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_attack04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			    offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	

				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.3,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.4,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =8,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 23, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},
	
	
	[402005] = {
		skill_id 	= 402005,
		action_time = 1.0,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.41, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.35,		-- 伤害飘字
		action_name = "skill1",			-- 动作名字
		hurt_action_time = 0.35,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},
		mul = {0.1,0.2,0.3},		

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			-- {
				-- name = "effect_female_skill01",
				-- start_time=0.2, 		
				-- play_count = 0,
				-- root_type = 7,			-- 父节点类型
				-- career = 1,
				-- rotate_type = 1,		--1根据角色旋转,2不旋转
				-- effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				-- offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。

				-- },
			{
				name = "effect_female_skill01_luoxuanhuazhuan",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--不旋转 1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点特效有效。
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.47,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.47,       --开始震动的时间
			    shake_lase_time = 0.1,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =10,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 360
			},			
		},
		-- 音效
		sound = {
			{
				id = 16, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[402006] = {
		skill_id 	= 402006,
		action_time = 1.533,			-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time = 0.67, 				-- 动作检查融合的时间
		forward_time = 0, 				-- 动作前摇
		hurt_text_start_time = 0.65,		-- 伤害飘字
		action_name = "skill2",		-- 动作名字
		hurt_action_time = 0.65,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_skill02_dadaoguang",
				start_time=0.15, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 1,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.58,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.56,       --开始震动的时间
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
				id = 17, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[402007] = {
		skill_id 	= 402007,
		action_time = 1.233,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 1.167, 				-- 动作前摇
		fuse_time = 0.67, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.1,		-- 伤害飘字
		action_name = "skill3",			-- 动作名字
		hurt_action_time = 0.6,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		mul = {0.15,0.3,0.45},

		effect = {						-- 技能特效,部分技能由多个特效组成

			{
				name = "effect_female_skill03_longjuanfeng",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 1,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
				},
			{
				name = "effect_female_attack_hurt",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},			
		},
		camera_infos =  
		{
			{
			    shake_start_time = 0.3,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 2,               --1上下 2左右 3拉伸
				shake_max_range =10,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 18, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	--技能
	[402008] = {
		skill_id 	= 402008,
		action_time = 1.667,				-- 动作时间,可以不填。默认是获取动作时间播放
		-- action_time = 2.033,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 				-- 动作前摇
		fuse_time = 1, 				-- 动作检查融合的时间
		hurt_text_start_time = 0.85,		-- 伤害飘字
				--hurt_text_start_time = 0.18,0.34,1.017		-- 伤害飘字
		action_name = "skill4",		-- 动作名字
		hurt_action_time = 0.85,			-- 伤害受击动作开始时间
		hurt_action_name = "hited",		-- 伤害受击动作				
		
		hit_color = {
			color	= {255,58,0,255},	--受击颜色
			time 	= 0.1,					--受击颜色变色时间
			scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			bias   	= 0.25					--受击颜色 菲涅尔范围(亮度)
		},

		-- repel = {
			-- distance  = 0,				--击退距离
			-- time 	  = 0.1,				--击退时间
			-- rate_type = 1,					--击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate 	  = 8,					--缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		
		effect = {						-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_female_skill04",
				start_time=0, 
				play_count = 0,
				root_type = 7,			-- 父节点类型
				career = 1,
				rotate_type = 2,		--1根据角色旋转,2不旋转
				effect_type = 4,		--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
				offset = 0,			--偏移坐标,朝人物朝向偏移多少个像素,只有指定坐标点和攻击方转移到场景对象 3受击方 5受击方转移到场景对象 特效有效。	
			},
			{
				name = "effect_female_attack_hurt",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 20,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		
		},
		-- slip = { 							-- 技能位移
			-- distance   = 0,				-- 位移最大距离
			-- type       = 2,					-- 1.到点 2.最多位移到目标点前方，不会穿过目标点
			-- start_time = 0.2,				-- 位移开始时间 不填默认为0
			-- time       = 1,				-- 位移时间
			-- rate_type  = 1,					-- 击退缓减速类型 1.幂次方缓减速 2.回弹两次 3.回弹一次 4.先慢后快
			-- rate       = 10,					-- 缓减速系数 系数越大曲线越抖 等于1的时候，就是匀速
		-- },
		camera_infos =  
		{
			{
			    shake_start_time = 0.76,       --开始震动的时间
			    shake_lase_time = 0.2,        --震动的总时间 
				shake_type = 3,               --1上下 2左右 3拉伸
				shake_max_range =20,          --震动的幅度 像素  
				shake_angle = 360,            --震动的角度  
				start_angle = 0
			},			
		},
		-- 音效
		sound = {
			{
				id = 19, 					-- 音效id
				time = 0.1, 				-- 延迟时间
				type = 1, 					-- 1.攻击音效 2.受击音效（暂无）
			},
		},
	},

	
	--宠物BOSS副本
	[801000] = {
		skill_id		=801000,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	--宠物BOSS副本
	[801001] = {
		skill_id		=801001,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "skill1",		 	-- 动作名字
			-- effect = {							-- 技能特效,部分技能由多个特效组成
		 
			-- }
 	},
	
	--千冢锄甲卫
		[60000] = {
		skill_id		=60000,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.8,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_bigger",
				start_time=0.85,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--须佐武道灵
	[60102] = {
		skill_id		=60102,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_bigger",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--魔能女祭师
	[60103] = {
		skill_id		=60103,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_bigger",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--沙之海祭师
	[60104] = {
		skill_id		=60104,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_bigger",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--六翼寓言使
	[60201] = {
		skill_id		=60201,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--奥法光明王
	[60202] = {
		skill_id		=60202,
			-- 0.3
		action_time = 1.5,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.5,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=0.7,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--魔灵双刀使
	[60203] = {
		skill_id		=60203,
			-- 0.3
		action_time = 1.667,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.667,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 1,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=1,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--铠甲圣剑士
	[60204] = {
		skill_id		=60204,
			-- 0.3
		action_time = 1.833,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.833,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.7,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=0.7,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--炎烈戮神将
	[60301] = {
		skill_id		=60301,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_attack01_fx",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},
			
		},
 	},
	--超时空乐师
	[60302] = {
		skill_id		=60302,
			-- 0.3
		action_time = 1.167,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.167,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.5,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_attack01_fx",
				start_time=0.5,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--鲜血伯爵
	[60303] = {
		skill_id		=60303,
			-- 0.3
		action_time = 1,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.45,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=0.45,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--粉色仙子
	[60401] = {
		skill_id		=60401,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_10003_attack01_fx",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--三枪双月王
	[60402] = {
		skill_id		=60402,
			-- 0.3
		action_time = 1.333,					-- 动作时间,可以不填。默认是获取动作时间播放
		fuse_time		 = 1.333,				 	-- 动作检查融合的时间
		forward_time = 0,					-- 动作前摇
		hurt_text_start_time = 0.6,			-- 伤害飘字
		action_name = "attack",		 	-- 动作名字
			effect = {							-- 技能特效,部分技能由多个特效组成
			{
				name = "effect_pet_20003_bigger_qibo",
				start_time=0.6,			--特效开始时间
				play_count = 0,				--播放次数
				root_type = 7,				--父节点类型
				career = 1,
				rotate_type = 1,			--1根据角色旋转,2不旋转
				effect_type = 5,			--特效类型,1指定坐标点 2攻击方对象节点 3受击方 4攻击方转移到场景对象 5受击方转移到场景对象 11弹道 坐标 12弹道 朝目标方向放一段距离 13弹道 追踪 14多目标弹道 坐标 20受伤特效
			},		 
		},
 	},
	--电气轰龙普攻
	[305011] = {
		skill_id 	= 305011,
		-- 0.3
		action_time = 1.633,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 1.633, 					-- 动作检查融合的时间
		hurt_text_start_time = 0.53,		-- 伤害飘字
		action_name = "attack",				-- 动作名字
		-- hurt_action_time = 0.53,			-- 伤害受击动作开始时间
		-- hurt_action_name = "hited",			-- 伤害受击动作
		--mul = {0.1,0.3},				-- 多段伤害 {第一段延迟时间，第二段延迟时间...}		
		-- hit_color = {
			-- color	= {255,58,0,255},	--受击颜色
			-- time 	= 0.1,					--受击颜色变色时间
			-- scale  	= 0.5,					--受击颜色 菲涅尔倍数(广度)
			-- bias   	= 0.4					--受击颜色 菲涅尔范围(亮度)
		-- },

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
	--电气轰龙大招
	[305012] = {
		skill_id 	= 305012,
		-- 0.3
		action_time = 2.833,				-- 动作时间,可以不填。默认是获取动作时间播放
		forward_time = 0, 					-- 动作前摇
		fuse_time = 2.833, 					-- 动作检查融合的时间
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

	[940001] = {
		skill_id 	= {940001},
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

	[930001] = {
		skill_id 	= {930001,930002},
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

	[930003] = {
		skill_id 	= {930003},
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
}


if LuaMemManager then
	old_require("game/fight/PetFightConfig")
	old_require("game/fight/MachineArmorFightConfig")
else
	require("game/fight/PetFightConfig")
	require("game/fight/MachineArmorFightConfig")
end


-- 单个配置对应多个
local function HandeMulConfig()
	local t = {}
	for skill_id,v in pairs(FightConfig.SkillConfig) do
		local skill = v.skill_id
		v.skill_id = skill_id
		if skill and type(skill) == "table" then
			t[skill_id] = skill
		end
	end

	for skill_id,list in pairs(t) do
		for k,_skill_id in pairs(list) do
			FightConfig.SkillConfig[_skill_id] = clone(FightConfig.SkillConfig[skill_id])
			FightConfig.SkillConfig[_skill_id].skill_id = _skill_id
		end
	end
end
HandeMulConfig()