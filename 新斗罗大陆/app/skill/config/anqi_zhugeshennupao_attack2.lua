local anqi_zhugeshennupao_attack2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_zhugeshennupao_zhuangpei2", is_target = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_zhugeshennupao_dieceng2", is_target = false, remove_all_same_buff_id = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "anqi_zhugeshennupao_jishi2", is_target = false},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "anqi_zhugeshennupao_kaihuo2", is_target = false},
                },
            },
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "composite.QSBLoop",
            OPTIONS = {loop_count = 5},
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 30},
                        },
                        {
                            CLASS = "action.QSBArgsIsUnderStatus",
                            OPTIONS = {is_attacker = true,status = "zhugeshennupao_zidan"},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "zhugeshennupao_attack", is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {start_pos = {x = 125,y = 75}, effect_id = "zhugeshennupao_zidan", speed = 1500,
                                            hit_effect_id = "zhugeshennupao_shouji", check_target_by_skill = true},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "anqi_zhugeshennupao_zidan2", is_target = false},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 180},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "anqi_zhugeshennupao_zhuangpei2", is_target = false},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "anqi_zhugeshennupao_jishi2", is_target = false},
                },
            },
        },
    },
}

return anqi_zhugeshennupao_attack2