local pf_ssdaimubai01_sj = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBAttackFinish"
                },
                {
                    CLASS = "action.QSBPlayGodSkillAnimation"
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_shenji_1s"},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssdaimubai01_shenji_1x"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 12 / 30},
                        },
                        {
                          CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = {"pf_ssdaimubai01_sj2", "pf_ssdaimubai01_sj2_2"}},
                },
            },
        },
    },
}

return pf_ssdaimubai01_sj