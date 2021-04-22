
local tangsan_baoyulihuazheng_new = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.6},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.6},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },

            },
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="tangsan_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="tangsan_bylhz_sf", revertable = true},
                },
            },
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
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.52},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tangsan_attack11_1_1", is_hit_effect = false},
                        }, 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.63},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tangsan_attack11_1", is_hit_effect = false},
                        }, 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.7},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tangsan_attack11_1_2", is_hit_effect = false},
                        }, 
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.6},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_1_3_1", speed = 2500,start_pos = {x = 120,y = 60}, hit_effect_id = "tangsan_attack01_3_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 7},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_1_3_1", speed = 2500,start_pos = {x = 120,y = 60}, hit_effect_id = "tangsan_attack01_3_1"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 19},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_1_3_2", speed = 3000,start_pos = {x = 120,y = 165}, hit_effect_id = "tangsan_attack01_3_2"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 2},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_1_3_3", speed = 3000,start_pos = {x = 120,y = 165}},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 1},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "tangsan_attack11_1_3_4", speed = 3000,start_pos = {x = 120,y = 165}},
                        },
                    },
                },			
            },
        },
    },
}

return tangsan_baoyulihuazheng_new

