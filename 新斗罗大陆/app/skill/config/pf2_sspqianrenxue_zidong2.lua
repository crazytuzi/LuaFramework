
local tangsan_htc_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
					CLASS = "action.QSBPlayAnimation",
				}, 
				{
					CLASS = "action.QSBAttackFinish",
				},  
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                }, 
                {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_3"},--头顶剑特效
		        }, 
            },
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 12},
	            }, 
	            {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_4"},--施法特效
		        }, 
	        },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 44},
	            },
	            {
	            	CLASS = "composite.QSBParallel",
				    ARGS = 
				    {
						{
				            CLASS = "action.QSBPlayEffect",
				            OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_1"},--前层特效
				        }, 	
				        {
				            CLASS = "action.QSBPlayEffect",
				            OPTIONS = {is_hit_effect = false, effect_id = "pf2_sspqianrenxue_attack14_2"},--后层特效
				        }, 
				    },    	
				},	
				{
		            CLASS = "action.QSBHitTarget",
		        },	        
	        },
        },
    },
}
return tangsan_htc_zidong1