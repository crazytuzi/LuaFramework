

local ultra_fireball_2 = {		-- 凯尔萨斯火球术2
	CLASS = "composite.QSBParallel",
    ARGS = {
   
   		{ 	
    		CLASS = "composite.QSBSequence",
        	ARGS = 
        	{
            	{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack02"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
        	},
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
            		OPTIONS = {is_hit_effect = false, effect_id = "kaiershashi_pugong_1"},
                },
        	},
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
            		OPTIONS = {is_hit_effect = false, effect_id = "kaiershashi_pugong_12"},
                },
        	},
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
            		OPTIONS = {is_hit_effect = false, effect_id = "kaiershashi_pugong_2"},
                },
        	},
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "kaiershashi_pugong_3", speed = 2000, hit_effect_id = "pyro_firemage_3"},
                },
        	},
        },
    },
} 

return ultra_fireball_2