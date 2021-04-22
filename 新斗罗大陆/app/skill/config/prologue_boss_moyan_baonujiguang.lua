--序章BOSS 魔眼 显示
--创建人：张义
--创建时间：2018年4月12日15:37:29

local prologue_boss_moyan_baonujiguang = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "composite.QSBSequence",        --第1波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 30 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 950 , y = 80}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第2波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 54 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 400 , y = 150}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第3波（击中小舞）
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 78 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 830 , y = 320}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第4波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 102 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 210 , y = 480}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第5波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 120 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 550 , y = 210}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第6波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 136 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 650 , y = 460}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第7波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 151 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 310 , y = 320}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第8波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 165 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 1130 , y = 510}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第9波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 178 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 740 , y = 260}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第10波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 190 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 340 , y = 470}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第10波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 202 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 1190 , y = 130}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第11波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 207 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 120 , y = 180}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第11波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 217 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 610 , y = 60}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第11波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 221 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 1000 , y = 480}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第12波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 225 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 370 , y = 350}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第12波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 231 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 600 , y = 460}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第13波--内
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 236 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 510 , y = 250}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第13波--内
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 244 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 810 , y = 410}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第13波--外
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 236 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 1020 , y = 130}, front_layer = true},
                        },
                    },
                },
                
                {
                    CLASS = "composite.QSBSequence",        --第13波--外
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 244 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 240 , y = 440}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第14波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 248 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 910 , y = 330}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第14波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 252 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 720 , y = 240}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第14波
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 256 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 620 , y = 470}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第14波--外
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 248 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 1080 , y = 480}, front_layer = true},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",        --第14波--外
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 252 / 24 * 30},
                        },
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "eyeboss_attack11_3_1", pos  = {x = 140 , y = 190}, front_layer = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return prologue_boss_moyan_baonujiguang