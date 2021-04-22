
local shengltxin_putongmoniao_pugong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },

        {
            CLASS = "composite.QSBSequence",--无动作
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation", 
                    OPTIONS = {animation = "dead_1"},
                },
                {
                    CLASS = "action.QSBSuicide",
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
             ARGS = {
                {
                    CLASS = "composite.QSBSequence",--攻击
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 2},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "shenglt_putongmoniao_attack11", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",--给BOSS一颗回血弹
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_frame = 3},
                        -- },            
                        {
                            CLASS = "action.QSBArgsSelectTarget",
                            OPTIONS = {is_teammate = true, under_status = "cuimoniaowang_xianji"},
                        },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "shenglt_putongmoniao_attack11_1", time = 0.5, start_pos = {x = 0,y = 100}},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 10},
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },  
                    },
                },
            },
        },

    },
}

return shengltxin_putongmoniao_pugong