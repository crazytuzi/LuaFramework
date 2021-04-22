local boss_fulande_bianshen = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
            	{
		            CLASS = "action.QSBApplyBuff",
		            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
		        },
		        {
		            CLASS = "action.QSBUncancellable",    
		        },
            	{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack22" , no_stand = true},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 5 / 24},
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 12, duration = 0.4, count = 3},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 5 / 24},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
			},
		},
		-- {
  --           CLASS = "action.QSBReleaseBuff",
  --           OPTIONS = {buff_id = "fulande_bianshen_buff"},
  --       },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return boss_fulande_bianshen