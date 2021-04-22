local qiangzhen_zibao =
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
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
                    OPTIONS = {animation = "attack01"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 18 / 24},
                        },
                        {
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 6 / 24 , revertable = true},
                        },
                    },
                },
				-- {
				-- 	CLASS = "composite.QSBSequence",
				-- 	ARGS = 
    --                 {
				-- 		{
    --                         CLASS = "action.QSBDelayTime",
    -- 						OPTIONS = {delay_time = 3 / 24},
    --                     },
    -- 					{
    -- 						CLASS = "action.QSBHitTarget",
    -- 					},
    --                 },
    --             },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 6 / 24},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 9 / 24},
                --         },
                --         {
                --             CLASS = "action.QSBHitTarget",
                --         },
                --     },
                -- },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 12 / 24},
                --         },
                --         {
                --             CLASS = "action.QSBHitTarget",
                --         },
                --     },
                -- },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 15 / 24},
                --         },
                --         {
                --             CLASS = "action.QSBHitTarget",
                --         },
                --     },
                -- },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return qiangzhen_zibao