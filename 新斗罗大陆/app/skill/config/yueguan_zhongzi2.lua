
local yueguan_zhongzi2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 8},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "yueguancz_attack11_1"}
                }
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "yueguancz_attack11_2", pos  = {x = 550 , y = 400}, ground_layer = false}
                }
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 120},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "yueguan_zhongzi_huanghua1"} ,
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "yueguan_zhongzi_zihua2"} ,
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "yueguan_zhongzi_zihua3"} ,
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "yueguan_zhongzi_huanghua4"} ,
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "yueguan_zhongzi_huanghua5"} ,
                        },
                    },
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 75},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 350, y = 500}, use_render_texture = false},
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 640, y = 425}, use_render_texture = false},
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 850, y = 350}, use_render_texture = false},
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 640, y = 275}, use_render_texture = false},
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 9999, life_span = 0.001,number = 1, no_fog = false,absolute_pos = {x = 350, y = 200}, use_render_texture = false},
                        },
                    },  
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
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
return yueguan_zhongzi2

