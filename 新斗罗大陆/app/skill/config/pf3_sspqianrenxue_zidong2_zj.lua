
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
                    OPTIONS = {delay_frame = 11},
                }, 
                {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack14_3"},--头顶剑特效
		        }, 
            },
        },
    	{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                }, 
                {
		            CLASS = "action.QSBPlayEffect",
		            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack14_4"},--施法特效
		        }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
	            {
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 45},
	            },
	            {
	            	CLASS = "composite.QSBParallel",
				    ARGS = 
				    {
						{
				            CLASS = "action.QSBPlayEffect",
				            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack14_1"},--前层特效
				        }, 	
				        {
				            CLASS = "action.QSBPlayEffect",
				            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspqianrenxue_attack14_2"},--后层特效
				        }, 
				    },    	
				},					
	            {
		            CLASS = "composite.QSBSequence",
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBArgsConditionSelector",
		                    OPTIONS = 
		                    {
		                        failed_select = 2,
		                        {expression = "self:is_pvp=true", select = 1},
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSelector",
		                    ARGS = 
		                    {
		                        
	                            {
	                              CLASS = "action.QSBHitTarget",
	                              OPTIONS = {damage_scale = 2,check_target_by_skill = true},
	                            }, 
	                            {
	                              CLASS = "action.QSBHitTarget",
	                              OPTIONS = {damage_scale = 3.5,check_target_by_skill = true},
	                            }, 

		                    },
		                },
		            },
		        }, 	
			},
        },
    },
}
return tangsan_htc_zidong1