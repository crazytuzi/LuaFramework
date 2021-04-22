
local shengltxin_putongmoniao_pugong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },

        {
            CLASS = "composite.QSBSequence",--动作
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation", 
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 37},
                }, 
                {
                    CLASS = "action.QSBAttackFinish"
                },  
            },
        },

        {
            CLASS = "composite.QSBSequence",--攻击
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",--受击
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 22},
                },            
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 50,y = 100}},
                },
            },
        },

    },
}

return shengltxin_putongmoniao_pugong