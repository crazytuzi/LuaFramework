local zhuzhuqing_dazhao_benti4 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "zhuzhuqing_11_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 18},
						},
						{
					        CLASS = "action.QSBPlayEffect",
					        OPTIONS = {effect_id = "zhuzhuqing_attack11_7",is_hit_effect = false, haste = true},--这个特效自带延时
				        },
				    },
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {is_keep_animation = true,animation = "attack11_7"}
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 22},
						},
						{
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
								{
                                    CLASS = "action.QSBHitTarget",
                                },
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
							OPTIONS = {delay_frame = 44},
						},
						{
							CLASS = "action.QSBAttackFinish"
						},
						{
							CLASS = "action.QSBSuicide", 
						},
					},
				},
            },
        },
    },
}

return zhuzhuqing_dazhao_benti4