local xunlian_elite_niumanglaoyu_ex_1 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "root_25s"},
        }, 
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
        {
            CLASS = "action.QSBLockTarget",     --锁定目标
            OPTIONS = {is_lock_target = true, revertable = true},
        }, 
		{
            CLASS = "action.QSBPlaySound"
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
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attackee = true}, -- 生成传递参数 pos = {x = 100, y = 目标的y轴}
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1 / 30, pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBMultipleTrap",
                            OPTIONS = {trapId = "niumang_ruchang_shuibo3",count = 1, pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                            OPTIONS = {count = 1, trapId = "xunlian_shuilao_hongquan_1",pass_key = {"pos"}} ,
                        },
                        {
                            CLASS = "action.QSBMultipleTrap",
                            OPTIONS = {trapId = "niumang_ruchang_shuibo2",count = 1, pass_key = {"pos"}},
                        }, 
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 38 / 30,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBMultipleTrap",
                            OPTIONS = {trapId = "niumang_ruchang_shuibo1",count = 1, pass_key = {"pos"}},
                        },                    
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 1.6 },
                        },
                        {
                            CLASS = "action.QSBArgsIsUnderStatus",
                            OPTIONS = {is_attackee = true,status = "laoyujt1"},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {is_target = true, buff_id = "xunlina_shuipao_dingshendebuff1"},
                                        }, 
                                        {
                                            CLASS = "action.QSBSummonGhosts",
                                            OPTIONS = {actor_id = 3984 , life_span = 500,number = 1, relative_pos = {x = 0, y = -30}, appear_skill = 50897 ,enablehp = true,hp_percent = 0.04,no_fog = false,is_attacked_ghost = true},
                                        },
                                        {
                                            CLASS = "action.QSBLockTarget",
                                            OPTIONS = {is_lock_target = false},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "root_25s"},
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
                                            CLASS = "action.QSBLockTarget",
                                            OPTIONS = {is_lock_target = false},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "root_25s"},
                                        },
                                        {
                                            CLASS = "action.QSBAttackFinish"
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

return xunlian_elite_niumanglaoyu_ex_1