-- 技能 BOSS比比东 毒液喷涌
-- 技能ID 50829
-- 喷毒
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_duyepenyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBPlayAnimation",                       
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 36},
                                },
                                 {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {start_pos = {x = 30,y = 135},target_random = true,effect_id = "bibidonga_attack14_2", speed = 1400, hit_effect_id = "bibidonga_attack14_3"},
                                },   
                            },
                        },    
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 3},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "bibidong_attack14_1_4", is_hit_effect = false},
                                },
                            },
                        },                        
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_bibidong_duyepenyong