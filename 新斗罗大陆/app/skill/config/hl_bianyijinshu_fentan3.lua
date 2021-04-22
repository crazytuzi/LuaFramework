local hl_bianyijinshu_fentan3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBPlayLinkEffect",
                    OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1.5, effect_width = 298, pass_key = {"selectTargets"}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3, pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBPlayLinkEffect",
                    OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1.5, effect_width = 298, pass_key = {"selectTargets"}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 6, pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBPlayLinkEffect",
                    OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1, effect_width = 298, pass_key = {"selectTargets"}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate = true, just_hero = true},
                },
                {
                    CLASS = "action.QSBSplitHit",
                    OPTIONS = {split_percent = 0.39, on = true, pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 7, pass_key = {"selectTargets"}},
                },
                {
                    CLASS = "action.QSBSplitHit",
                    OPTIONS = {off = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "hl_bianyijinshu_dazhao_buff3", teammate_and_self = true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return hl_bianyijinshu_fentan3