-- 技能 BOSS邪魔神虎 跳扑
-- 技能ID 50864
-- 定点跳红圈
--[[
	boss 邪魔神虎
	ID:3696
	psf 2018-7-19
]]--

local boss_xiemoshenhu_tiaopu = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {random_enemy = true, buff_id = "boss_xiemoshenhu_aim_debuff"},
		},
		{
			CLASS = "action.QSBPlaySound",
		},    
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "heihu_attack12_1_1" , is_hit_effect = false},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "heihu_attack12_1_2" , is_hit_effect = false},
		},		
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack12"},
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "heihu_attack12_1_3" , is_hit_effect = false},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "heihu_attack12_1_4" , is_hit_effect = false},
						},
						{
							 CLASS = "action.QSBHitTarget",
						},
					},
				},
			},
		},
		 {
			CLASS = "composite.QSBSequence",
			OPTIONS = {forward_mode = true},
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsIsDirectionLeft",
					OPTIONS = {is_attacker = true},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = 
					{   
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 15},
								},
								{
									CLASS = "action.QSBLockTarget",     --锁定目标
									OPTIONS = {is_lock_target = true, revertable = true},
								},
								{
									CLASS = "action.QSBArgsPosition",
									OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
								},
								{
									CLASS = "action.QSBMultipleTrap",
									OPTIONS = {trapId = "boss_guihu_feipu_trap",count = 1, pass_key = {"pos"}},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 30, pass_key = {"pos"}},
								},
								{
									CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
									OPTIONS = {move_time = 0.44,offset = {x= 80,y=0}},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 15},
								},
								{
									CLASS = "action.QSBLockTarget",     --锁定目标
									OPTIONS = {is_lock_target = true, revertable = true},
								},
								{
									CLASS = "action.QSBArgsPosition",
									OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
								},
								{
									CLASS = "action.QSBMultipleTrap",
									OPTIONS = {trapId = "boss_guihu_feipu_trap",count = 1, pass_key = {"pos"}},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 30, pass_key = {"pos"}},
								},
								{
									CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
									OPTIONS = {move_time = 0.44,offset = {x= -80,y=0}},
								},
							},
						},
					},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.5},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "xiaowu_tongyongchongfeng_buff"},
				},
				{
					CLASS = "action.QSBLockTarget",
					OPTIONS = {is_lock_target = false},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_xiemoshenhu_tiaopu