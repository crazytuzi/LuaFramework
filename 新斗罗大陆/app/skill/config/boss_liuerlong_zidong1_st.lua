-- 技能 BOSS柳二龙多重戳
-- 技能ID 50652
-- 群体刺好几下,最后一下击退
--[[
	boss 柳二龙 
	ID:3175 力量试炼
	psf 2018-5-31
]]--

local boss_liuerlong_zidong1_st = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
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
					OPTIONS = {delay_time = 1.4},
				},
				{
					CLASS = "action.QSBDragActor",
					OPTIONS = {pos_type = "self" , pos = {x = 275,y = 0} , duration = 0.25, flip_with_actor = true },
				},
			},
		},
     --    {
     --        CLASS = "composite.QSBSequence",
     --        ARGS =
     --    	{
     --    		{
    	-- 			CLASS = "composite.QSBParallel",
     --        		ARGS = 
     --        		{
     --            		{
					-- 		CLASS = "action.QSBPlayAnimation",
     --                		ARGS = 
     --                		{
     --                    		{
     --                                CLASS = "action.QSBPlayEffect",
     --                                OPTIONS = {is_hit_effect = true},
     --                            },
					-- 			{
     --                                CLASS = "action.QSBHitTarget",
     --                            },
     --                    	},
     --                	},
     --        		},
     --        	},
     --    		{
     --        		CLASS = "action.QSBAttackFinish",
    	-- 		},
    	-- 	},	
    	-- },
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
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 18 / 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "liuerlong_attack13_1" ,is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 22 / 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 24 / 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 26 / 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 32 / 30},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },  
        },
	},   
}
return boss_liuerlong_zidong1_st