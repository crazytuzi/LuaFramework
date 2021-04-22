local npc_pozhiyizu_zhaohuanlaolong_10_16 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack22"},
                },
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 40 /24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS =
                            {
                                -- {
                                --     CLASS = "action.QSBPlayEffect",
                                --     OPTIONS = {effect_id = "yangwudi_attack11_3_1",is_hit_effect = true},
                                -- },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "boss_changqianglaoyu1"},
                                }, 
                            },
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     OPTIONS = {revertable = true},
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 50 /24 },
                --         },
                --         {
                --             CLASS = "action.QSBArgsPosition",
                --             OPTIONS = {is_attackee = true},
                --         },
                --         {
                --             CLASS = "action.QSBMultipleTrap",
                --             OPTIONS = {trapId = "shemao_xuanwo",count = 1, pass_key = {"pos"}},
                --         },
                --     },
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 44 /24 },
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 3827 , life_span = 21,number = 1, appear_skill = 51240 , enablehp = true,hp_percent = 0.05 , relative_pos = {x = 0, y = -25}, no_fog = false,is_attacked_ghost = true},
                        },
                        {
                            CLASS = "action.QSBLockTarget",
                            OPTIONS = {is_lock_target = false},
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 47 /24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 6, duration = 0.35, count = 1,},
                        },
                    },
                },
            },
        },
    },
}

return npc_pozhiyizu_zhaohuanlaolong_10_16