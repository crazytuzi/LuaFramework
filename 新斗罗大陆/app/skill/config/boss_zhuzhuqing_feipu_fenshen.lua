-- 技能 鬼虎飞扑
-- 扑向目标造成AOE伤害
--[[
	boss 朱竹青分身
	ID:3307 副本3-16
	psf 2018-1-23
]]--

local boss_zhuzhuqing_feipu_fenshen = {
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
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "xiaowu_tongyongchongfeng_buff"},
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
				-- {
                    -- CLASS = "action.QSBMultipleTrap",
                    -- OPTIONS = {trapId = "boss_tielong_chuidi_trap",count = 1, pass_key = {"pos"}},
                -- },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30, pass_key = {"pos"}},
                },
				{
					CLASS = "action.QSBCharge",
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
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return boss_zhuzhuqing_feipu_fenshen