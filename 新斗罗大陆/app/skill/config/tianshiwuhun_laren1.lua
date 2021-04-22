
local tianshiwuhun_laren1 = {
       CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",      --mianyi
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{
            CLASS = "action.QSBPlayAnimation",     
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack15_2", is_loop = true},       
        }, 
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "tianshi_laren_xuanyun", is_target = true},
		}, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
		{
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 6},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBReloadAnimation",
                        },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = false}
                        },
						{
                            CLASS = "action.QSBAttackFinish"
                        },
						{
							CLASS = "action.QSBRemoveBuff",      --mianyi
							OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
										{
											CLASS = "action.QSBPlayAnimation",
											OPTIONS = {animation = "attack15_3"},       
										}, 
										{
											CLASS = "action.QSBApplyBuff",
											OPTIONS = {buff_id = "tianshi_laren_zifei"},
										}, 
										{
											CLASS = "action.QSBHitTarget",
										},
									},
						},
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                    },
                },
            },
        },
    },
}

return tianshiwuhun_laren1