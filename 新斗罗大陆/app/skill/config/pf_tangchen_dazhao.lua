local pf_tangchen_dazhao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "mhtc"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="tangchen_skill"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShowActor",
                                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBBulletTime",
                                    OPTIONS = {turn_on = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 34/24*30},
                                },
                                {
                                    CLASS = "action.QSBBulletTime",
                                    OPTIONS = {turn_on = false},
                                },
                                {
                                    CLASS = "action.QSBShowActor",
                                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                                },
                            },
                        }, 
                        {                           --竞技场黑屏
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShowActorArena",
                                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBBulletTimeArena",
                                    OPTIONS = {turn_on = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 34/24*30},
                                },
                                {
                                    CLASS = "action.QSBBulletTimeArena",
                                    OPTIONS = {turn_on = false},
                                },
                                {
                                    CLASS = "action.QSBShowActorArena",
                                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlaySound"
                        },
                        {
                             CLASS = "composite.QSBSequence",
                             ARGS = 
                             {
                                {
                                     CLASS = "composite.QSBSequence",
                                     ARGS = 
                                     {
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "tangchen_xiuluofuti_ex", is_target = false},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"tangchen_xiuluofuti_ex;y","tangchen_dazhao_jishi"}, is_target = false},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "tangchen_zhongjie_huifu", is_target = false},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    { 
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBPlayAnimation",
                                                    OPTIONS = {animation = "attack11_1"},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBDelayTime",
                                                    OPTIONS = {delay_frame = 17},
                                                },
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "xiuluotangchen_attack11_2", speed = 1500, hit_effect_id = "ssmahongjun_attack01_3"},
                                                },
                                            },
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "tangchen_zhongjie_huifu", is_target = false},
                                },
                                {
                                    CLASS = "action.QSBActorStatus",
                                    OPTIONS = 
                                    {
                                       { "target:xiuluo","target:apply_buff:tangchen_xiuluozhiling_die","under_status"},
                                    },
                                },
                                {
                                    CLASS = "action.QSBActorStatus",
                                    OPTIONS = 
                                    {
                                       { "xiuluozhiliao","apply_buff:tangchen_xiuluozhiling_zhiliao_die","under_status"},
                                    },
                                },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="tangchen_skill"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShowActor",
                                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBBulletTime",
                                    OPTIONS = {turn_on = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 74/24*30},
                                },
                                {
                                    CLASS = "action.QSBBulletTime",
                                    OPTIONS = {turn_on = false},
                                },
                                {
                                    CLASS = "action.QSBShowActor",
                                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                                },
                            },
                        }, 
                        {                           --竞技场黑屏
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShowActorArena",
                                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBBulletTimeArena",
                                    OPTIONS = {turn_on = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 74/24*30},
                                },
                                {
                                    CLASS = "action.QSBBulletTimeArena",
                                    OPTIONS = {turn_on = false},
                                },
                                {
                                    CLASS = "action.QSBShowActorArena",
                                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack11"},
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
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 0},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "pl_tangcheng_attack11_1", is_hit_effect = false},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_frame = 30},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"pf_tangchen_xiuluofuti_buff;y", "tangchen_xiuluofuti_ex;y", "tangchen_dazhao_jishi"}, is_target = false},
                                        },
                                    },
                                },
                            },
                        },  
                    },
                },
            },
        },
    },
}

return pf_tangchen_dazhao