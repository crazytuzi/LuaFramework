-- 技能 暗器 红尘庇佑分摊触发5
-- 技能ID 40580

local anqi_hongchenbiyou_fentan5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayMountSkillAnimation",
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate = true, under_status = "hongchenbiyou_duiyou", args_translate = {selectTarget = "strike_agreementee"}},
                },
                {
                    CLASS = "action.QSBStrikeAgreement",
                    OPTIONS = {is_strike_agreement = true, percent = 0.30,time = 7,hp_threshold = 0.05},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 10},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsFindTargets",
                    OPTIONS = {teammate_and_self = true, just_hero = true, is_under_status = "hongchenbiyou_fentan"},
                },
                {
                    CLASS = "action.QSBPlayLinkEffect",
                    OPTIONS = {effect_id = "hongchenbiyou_fenlie", dummy = "dummy_center", duration = 6, effect_width = 298},
                },
            },
        },
    },
}

return anqi_hongchenbiyou_fentan5