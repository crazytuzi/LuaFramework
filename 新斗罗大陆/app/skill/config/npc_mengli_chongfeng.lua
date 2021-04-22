local npc_langdao_zhixianchongfeng = 
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
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 18/24 },
                }, 
                {
                    CLASS = "action.QSBPlayAnimation",
                    -- ARGS = 
                    -- {                        
                    --     -- {
                    --     --     CLASS = "action.QSBPlayEffect",
                    --     --     OPTIONS = {is_hit_effect = true},
                    --     -- },
                    -- },
                },
            },
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "npc_langdao_zhixianchongfeng_hongkuang", is_target = false},
        -- },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_liuerlong_huoyanbo_hongkuang", is_target = false},
        },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 62/24 },
                }, 
                {
					CLASS = "action.QSBHeroicalLeap",
            		OPTIONS = {distance = 750, move_time = 21/24, interval_time = 1, is_hit_target = true, bound_height = 40},
            	},
            },
        },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 104 / 24 },
                }, 
     --        	{
					-- CLASS = "action.QSBHeroicalLeap",
     --        		OPTIONS = {speed = 0 ,move_time = 0.25},
     --        	},
     --            {
     --                CLASS = "action.QSBDelayTime",
     --                OPTIONS = {delay_time = 10 / 24 },
     --            },
            	{
					CLASS = "action.QSBAttackFinish",
				},
            },
        },
	},
}
return npc_langdao_zhixianchongfeng