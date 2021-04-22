local zudui_npc_langhunshi_feipu = 
{
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
        {
			CLASS = "action.QSBPlaySound"
		},
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },	
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11_1" },
                        },
                    },
                },
            },
        },	
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 23/24 },
                }, 
                {
                    CLASS = "action.QSBHeroicalLeap",
                    -- OPTIONS = {speed = 300 ,move_time = 3 ,interval_time = 0.1 ,is_hit_target = true ,bound_height = 150},
                    OPTIONS = {speed = -500 ,move_time = 10/24}
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36/24 },
                }, 
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_3" },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 36/24 },
                }, 
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "langhunshi_feipu", is_hit_effect = false},
                -- },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "langhunshi_feipu", is_target = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 70/24 },
                }, 
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {distance = 850, move_time = 16/24, interval_time = 1 / 24, is_hit_target = true, bound_height = 50},
                        },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 1 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 2 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 4 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 6 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 8 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 10 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {   
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 11 / 24},
                        --         },
                        --         {
                        --              CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                    },
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
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 90/24 },
                }, 
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}
return zudui_npc_langhunshi_feipu