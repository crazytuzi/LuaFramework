--序章成年马红俊入场
--创建人：张义
--创建时间：2018年5月30日18:22:55
--修改时间：



local prologue_mahongjun_ruchang = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_frame = 1},
                        -- },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack22"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.5},
                        }, 
                        {
                            CLASS = "action.QSBPlaySound",
                        }, 
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "mahongjun_ruchang", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return prologue_mahongjun_ruchang