-- 技能 鬼面盗贼突进
-- 技能ID 50357
-- 蓄力突进
--[[
	boss 鬼面盗贼
	ID:3283 副本6-8
	psf 2018-3-30
]]--

local boss_guimiandaozei_tujin = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "stand"},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                    },
                }, 
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
                    {
						{
							CLASS = "action.QSBPlayLoopEffect",
							OPTIONS = {effect_id = "daozei_attack11_hongkuang_15", is_hit_effect = false, follow_actor_animation = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 74},
						},
						{
							CLASS = "action.QSBStopLoopEffect",
							 OPTIONS = {effect_id = "daozei_attack11_hongkuang_15"},
						},
						{
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 936 ,move_time = 0.4 ,interval_time = 0.4 ,is_hit_target = true ,bound_height = 50},
                        },
					},
				},	
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_guimiandaozei_tujin