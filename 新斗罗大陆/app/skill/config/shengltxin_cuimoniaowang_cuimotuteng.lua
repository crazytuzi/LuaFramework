
local shengltxin_cuimoniaowang_cuimotuteng = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "shengltxin_cuimoniaowang_miankong_buff",no_cancel = true},
				},
        {
            CLASS = "composite.QSBSequence",--动作
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_1"},
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                    OPTIONS = {pos = {x = 650, y = 300}},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_2", is_loop = true, is_keep_animation = true},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",--停止动作
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 4.5},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_3"},
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
                    OPTIONS = {delay_time = 1.7},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_tut_appear", is_hit_effect = false},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_attack11_2_1", is_hit_effect = false},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_xuli", is_hit_effect = false},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_tut_1", is_hit_effect = false},
                },
                --循环
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_tut_3", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "shengltxin_cuimoniaowang_xianji_buff"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "shengltxin_cuimoniaowang_tuteng_buff",no_cancel = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3},
                },
				{
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "shengltxin_cuimoniaowang_xianji_buff"},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_tut_2", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_tut_3", is_hit_effect = false},
                },
                  --循环结束
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 48},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_tut_dead", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",--治疗光圈爆发特效
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 4.9},
                },   
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ayin_attack11_1_1", is_hit_effect = false},
                },

            },
        },
        {
            CLASS = "composite.QSBSequence",--受击
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 5},
                },   
                {
                     CLASS = "action.QSBHitTarget",
                },         
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "shenglt_cuimoniaowang_attack11_3_1", is_hit_effect = true},
                },
            },
        },

    },
}

return shengltxin_cuimoniaowang_cuimotuteng