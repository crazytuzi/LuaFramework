local zhuzhuqing_dazhao_benti3 = {
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
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {is_keep_animation = true,animation = "attack11_1"}
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 15},
						},
						{
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "zhuzhuqing_attack11_1",is_hit_effect = false},
								},
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
							OPTIONS = {delay_frame = 35},
						},
						{
                            CLASS = "action.QSBActorFadeOut",
                            OPTIONS = {duration = 0.05, revertable = true},
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

return zhuzhuqing_dazhao_benti3