
local ui_guimei_atk13 = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        -- {
        --     CLASS = "action.QUIDBPlayLoopEffect",
        --     OPTIONS = {effect_id = "mahongjun_attack11_3_1", duration = 3.12, no_sound_loop = true},
        -- },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QUIDBDelayTime",
                --     OPTIONS = {delay_frame = 28},
                -- },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_qingyufenghuang_attack21_1_ui"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_qingyufenghuang_attack21_2_ui"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 58},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}

return ui_guimei_atk13