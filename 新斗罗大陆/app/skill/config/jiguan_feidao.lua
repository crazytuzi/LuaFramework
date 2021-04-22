local npc_langdao_zhixianchongfeng = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
  --       {
		-- 	CLASS = "action.QSBPlaySound"
		-- },
        -- {
        --     CLASS = "action.QSBRemoveFromGrid",
        -- },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },	
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "stand", is_loop = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = true},
                        },
                        {
                            CLASS = "action.QSBPlaySound",
                            OPTIONS = {sound_id ="jiguan_feidao"},
                        },
                    },
                },
            },
        },	
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 23/24 },
        --         }, 
        --         {
        --             CLASS = "action.QSBHeroicalLeap",
        --             -- OPTIONS = {speed = 300 ,move_time = 3 ,interval_time = 0.1 ,is_hit_target = true ,bound_height = 150},
        --             OPTIONS = {speed = -500 ,move_time = 10/24}
        --         }, 
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 36/24 },
        --         }, 
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --             OPTIONS = {animation = "attack11_3" },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 36/24 },
        --         }, 
        --         -- {
        --         --     CLASS = "action.QSBPlayEffect",
        --         --     OPTIONS = {effect_id = "langhunshi_feipu", is_hit_effect = false},
        --         -- },
        --         {
        --             CLASS = "action.QSBApplyBuff",
        --             OPTIONS = {buff_id = "langhunshi_feipu", is_target = false},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {   
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_time = 70/24 },
                                -- }, 
                                {
                                    CLASS = "action.QSBHeroicalLeap",
                                    OPTIONS = {distance = 1500, move_time = 240/24},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 48/24 },
                                }, 
                                {
                                    CLASS = "action.QSBHeroicalLeap",
                                    OPTIONS = {distance = -2000, move_time = 320/24},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_time = 70/24 },
                                -- }, 
                                {
                                    CLASS = "action.QSBHeroicalLeap",
                                    OPTIONS = {distance = -1500, move_time = 240/24},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 24/24 },
                                }, 
                                {
                                    CLASS = "action.QSBHeroicalLeap",
                                    OPTIONS = {distance = 2000, move_time = 320/24},
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBHitTimer",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 561/24 },
                }, 
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}
return npc_langdao_zhixianchongfeng