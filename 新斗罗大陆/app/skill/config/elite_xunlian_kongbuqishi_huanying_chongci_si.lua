local elite_xunlian_kongbuqishi_huanying_chongci_si = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 20},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 120},
                        },
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 1250 ,move_time = 0.35 ,interval_time = 1 ,is_hit_target = true ,bound_height = 21},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "dead"},       
                        },
                        {
                            CLASS = "action.QSBSuicide", 
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}
return elite_xunlian_kongbuqishi_huanying_chongci_si