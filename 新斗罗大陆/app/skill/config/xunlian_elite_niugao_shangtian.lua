local zudui_niugao_shangtian = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},       
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 22/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBActorFadeOut",
                                    OPTIONS = {duration = 0.5, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_shanghai"},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTeleportToAbsolutePosition",
                            OPTIONS = {pos = {x = 850, y = 340}},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack21"},       
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                                },
                                {
                                    CLASS = "action.QSBActorFadeIn",
                                    OPTIONS = {duration = 0.5, revertable = true},
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 1},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_shanghai"},
                                        },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBTriggerSkill",
                            OPTIONS = {skill_id = 53163, wait_finish = true}, --放置另一个trap
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 25/24 },
                        },
                        {
                            CLASS = "action.QSBSummonMonsters",
                            OPTIONS = {wave = -1,attacker_level = true},
                        },
                    },
                },
            },
        },
    },
}
return zudui_niugao_shangtian