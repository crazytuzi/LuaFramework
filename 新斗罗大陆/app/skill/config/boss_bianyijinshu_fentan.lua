--hl_bianyijinshu_fentan1
local boss_bianyijinshu_fentan = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsFindTargets",
            OPTIONS = {teammate_and_self = true}
        },
        {
            CLASS = "action.QSBSplitHit",
            OPTIONS = {split_percent = 0.6, pass_key = {"selectTargets"}, on = true}
        },
        {
            CLASS = "action.QSBPlayLinkEffect",
            OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1, effect_width = 298, pass_key = {"selectTargets"}},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 2, pass_key = {"selectTargets"}}
        },
        {
            CLASS = "action.QSBPlayLinkEffect",
            OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1, effect_width = 298, pass_key = {"selectTargets"}},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 2, pass_key = {"selectTargets"}}
        },
        {
            CLASS = "action.QSBPlayLinkEffect",
            OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1, effect_width = 298, pass_key = {"selectTargets"}},
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 2, pass_key = {"selectTargets"}}
        },
        {
            CLASS = "action.QSBPlayLinkEffect",
            OPTIONS = {effect_id = "hl_bianyijinshu_lianjie", dummy = "dummy_center", duration = 1, effect_width = 298, pass_key = {"selectTargets"}},
        },
        {
            CLASS = "action.QSBSplitHit",
            OPTIONS = {off = true}
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "boss_bianyijinshu_dazhao_buff", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return boss_bianyijinshu_fentan