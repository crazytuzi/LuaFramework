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
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 50},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
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
                                            CLASS = "action.QSBMultipleTrap",
                                            OPTIONS = {trapId = "guimiandaozei_chongfeng2",count = 1, attacker_underfoot = true, pass_key = {"pos"}},
                                        },
                						{
                							CLASS = "action.QSBDelayTime",
                							OPTIONS = {delay_frame = 70},
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
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBMultipleTrap",
                                            OPTIONS = {trapId = "guimiandaozei_chongfeng1",count = 1, attacker_underfoot = true, pass_key = {"pos"}},
                                        },
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 70},
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