local boss_xiemohujing_kongju = {
CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack15"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24/24*30},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id ="xiemohujing_kongju_buff", is_target = true},             
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 31},
                },
                {
                    CLASS = "action.QSBLaser",      -- 特殊子弹，激光形式的子弹         ---
                    OPTIONS = {effect_id = "shenhaimojing_attack15_2", effect_width = 750, Zoder = "isGroundEffect",start_pos = {x = 200, y = 100}, use_clip = true, duration = 2.75, is_loop = true, interval = 0.6, switch_target = false, hit_dummy = "dummy_body", cancel_skill = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 90/24*30},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return boss_xiemohujing_kongju