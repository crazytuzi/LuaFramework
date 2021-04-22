local pf_cnxiaowu03_shengli = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_chengnianxiaowu03_victory_1", is_hit_effect = false},
                },
            },
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBArgsHasActor",
					OPTIONS = {actor_id = 1020,skin_id = 42,teammate = true}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBPlaySceneEffect",
							OPTIONS = {pos  = {x = 100 , y = 100},front_layer = true,effect_id = "pf_qx_shenglitexiao"},
						},
					},
				},
			},
		},
    },
}

return pf_cnxiaowu03_shengli