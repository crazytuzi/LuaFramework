--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：烈火杏BOSS
--  类型：攻击
local boss_liehuoxing_xiexian_aoe1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack13"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {               
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 28},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 1200 , y = 600}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 1000 , y = 500}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 800 , y = 400}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 600 , y = 300}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 400 , y = 200}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 200 , y = 100}, ground_layer = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "lihxjs_attack13_3", pos  = {x = 0 , y = 0}, ground_layer = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {               
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 34},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
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
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return boss_liehuoxing_xiexian_aoe1