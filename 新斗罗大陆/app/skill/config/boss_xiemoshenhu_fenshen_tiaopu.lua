-- 技能 BOSS邪魔神虎 分身 跳扑
-- 技能ID 50868
-- 定点跳
--[[
	boss 邪魔神虎
	ID:3697
	psf 2018-7-19
]]--

local boss_xiemoshenhu_fenshen_tiaopu = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlaySound",
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
							OPTIONS = {is_hit_effect = true},
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
			OPTIONS = {revertable = true},
			ARGS = 
			{
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30, pass_key = {"pos"}},
                },
				{
					CLASS = "action.QSBCharge", --移动向目标位置（不打断动画）
					OPTIONS = {move_time = 0.5},
				},
                -- {
                    -- CLASS = "action.QSBTriggerSkill",
					-- OPTIONS = { skill_id = 50178,wait_finish = true},
                -- },	
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "xiaowu_tongyongchongfeng_buff"},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_xiemoshenhu_fenshen_tiaopu