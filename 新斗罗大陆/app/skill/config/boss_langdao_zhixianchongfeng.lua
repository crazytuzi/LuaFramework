--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：狼盗
--  类型：攻击
local boss_langdao_zhixianchongfeng = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
        {
			CLASS = "action.QSBPlaySound"
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
                    ARGS = {                        
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "npc_langdao_zhixianchongfeng_hongkuang", is_target = false},
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
            		OPTIONS = {distance = 500, move_time = 21/24, interval_time = 1, is_hit_target = true, bound_height = 40},
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
return boss_langdao_zhixianchongfeng