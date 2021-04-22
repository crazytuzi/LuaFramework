local shifa_tongyong = 
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
                                    OPTIONS = {delay_time = 2},
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
                                    OPTIONS = {delay_time = 2},
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
                                            OPTIONS = {buff_id = "tangchen_xiuluofuti_ex_hetiji", is_target = false},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = {"tangchen_xiuluofuti_ex_hetiji;y","tangchen_dazhao_jishi_hetiji"}, is_target = false},
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
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack11_1"},
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBBullet",
                                                    OPTIONS = {flip_follow_y = true},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false},
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
                                    OPTIONS = {delay_time = 2},
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
                                    OPTIONS = {delay_time = 2},
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
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                            OPTIONS = {animation = "attack11"},
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
                                                    OPTIONS = {buff_id = {"tangchen_xiuluofuti_buff_hetiji;y", "tangchen_xiuluofuti_ex_hetiji;y", "tangchen_dazhao_jishi"}, is_target = false},
                                                },
                                            },
                                        },
                                    },
                                },
                                -- {
                                --     CLASS = "action.QSBRemoveBuff",
                                --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
                                -- },
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return shifa_tongyong