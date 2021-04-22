
local pf_cnxiaowu_zidong1 = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {  
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 0.5 },
                },
                {
                    CLASS = "action.QUIDBPlaySound",
                    OPTIONS = {sound_id ="ssptangchen__skill"},--声音
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBActorFade",
                    OPTIONS = {fadeout = true, revertable = true, duration = 0.25 },
                },
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 25 },
                },
                {
                    CLASS = "action.QUIDBActorFade",
                    OPTIONS = {fadein = true, revertable = true,  duration = 0.25 },
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11_1"},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11_2"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_ssptangchen_attack11_1", is_hit_effect = false}, --大招施法
                },
            },
        },
        -- {
        --     CLASS = "composite.QUIDBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QUIDBDelayTime",
        --             OPTIONS = {delay_frame = 32},
        --         },
        --         {
        --             CLASS = "action.QUIDBPlayEffect",
        --             OPTIONS = {effect_id = "ui_ssptangchen_attack11_2", is_hit_effect = false}, --大招空中蓄力
        --         },
        --     },
        -- }, 
    },
}

return pf_cnxiaowu_zidong1