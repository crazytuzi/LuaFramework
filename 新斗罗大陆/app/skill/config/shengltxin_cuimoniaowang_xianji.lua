
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
                    OPTIONS = {delay_frame = 50},
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
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "shenglt_zishamoniao_xianji1", is_hit_effect = false},
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
				{
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "shenglt_zishamoniao_xianji1", is_hit_effect = false},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_zishamoniao_xianji", is_hit_effect = false},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",--击杀场内小鸟(给它们挂献祭BUFF)
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },            
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate = true, is_under_status = "putongmoniao_xianji"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "shengltxin_putongmoniao_zisha_buff", attacker_target = true},
                }
            },
        },

    },
}

return shengltxin_putongmoniao_pugong