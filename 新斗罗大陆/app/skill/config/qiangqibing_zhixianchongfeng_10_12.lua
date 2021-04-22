-- 技能 持盾冲撞
-- 原地砸一下盾牌蓄力，然后向前冲撞，击飞路径上的敌人
--[[
	boss 牛皋
	ID:3305 副本3-12
	psf 2018-1-22
]]--

local qiangqibing_zhixianchongfeng_10_12 = {
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
        	CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 62/24 },
                }, 
                {
					CLASS = "action.QSBHeroicalLeap",
            		OPTIONS = {distance = 2000, move_time = 21/24, interval_time = 1, is_hit_target = true, bound_height = 40},
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

return qiangqibing_zhixianchongfeng_10_12

