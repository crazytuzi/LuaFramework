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
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 1 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "new_yangwudi_atk11_1_2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 6 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "new_yangwudi_atk11_1_1", is_hit_effect = false},
                        },
                    },
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
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "yangwudi_attack11_3_1",is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_target = true, buff_id = "boss_changqianglaoyu2"},
                                }, 
                            },
                        },
                    },
                },
                -- {
                    -- CLASS = "composite.QSBSequence",
                    -- OPTIONS = {revertable = true},
                    -- ARGS = 
                    -- {
                        -- {
                            -- CLASS = "action.QSBDelayTime",
                            -- OPTIONS = {delay_time = 50 /24 },
                        -- },
                        -- {
                            -- CLASS = "action.QSBArgsPosition",
                            -- OPTIONS = {is_attackee = true},
                        -- },
                        -- {
                            -- CLASS = "action.QSBMultipleTrap",
                            -- OPTIONS = {trapId = "jinshu_shemao_xuanwo",count = 1, pass_key = {"pos"}},
                        -- },
                    -- },
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 54 /24 },
                        },
                        -- {
                        --     CLASS = "action.QSBApplyBuff",
                        --     OPTIONS = {is_target = true, buff_id = "boss_changqianglaoyu2"},
                        -- }, 
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 3713 , life_span = 21,number = 1, appear_skill = 50897 , enablehp = true,hp_percent = 0.02, relative_pos = {x = 0, y = -50}, no_fog = false,is_attacked_ghost = true},
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
            },
        },
		-- {
		-- 	CLASS = "action.QSBRemoveBuff",
		-- 	OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		-- },
    },
}

return npc_pozhiyizu_zhaohuanlaolong_10_16