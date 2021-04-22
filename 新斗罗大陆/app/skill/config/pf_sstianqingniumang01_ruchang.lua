local ssniutian_ruchang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBActorFadeOut",
            OPTIONS = {duration = 0.01, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
							CLASS = "action.QSBArgsIsLeft",
							OPTIONS = {is_attacker = true},
						},
						{
							CLASS = "composite.QSBSelector",
							ARGS = {
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{	
										{
											CLASS = "action.QSBArgsPosition",
											OPTIONS = {is_attacker = true , enter_stop_position = true,offset = {x = -50, y = 0}},
										},
										-- {
											-- CLASS = "action.QSBDelayTime",
											-- OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
										-- },
										{
											CLASS = "action.QSBCharge",
											OPTIONS = {move_time = 1 / 30},
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{	
										{
											CLASS = "action.QSBArgsPosition",
											OPTIONS = {is_attacker = true , enter_stop_position = true,offset = {x = 50, y = 0}},
										},
										-- {
											-- CLASS = "action.QSBDelayTime",
											-- OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
										-- },
										{
											CLASS = "action.QSBCharge",
											OPTIONS = {move_time = 1 / 30},
										},
									},
								},
							},
						},
						
						{
                            CLASS = "action.QSBArgsPosition",
                            OPTIONS = {is_attacker = true , enter_stop_position = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
                        },
                        {
                            CLASS = "action.QSBCharge",
                            OPTIONS = {move_time = 25 / 30},
                        },
                    },
                },
                {
					CLASS = "composite.QSBParallel",
					ARGS = 
					{
						{
							CLASS = "action.QSBActorFadeIn",
							OPTIONS = {duration = 10 / 30, revertable = true},
						},
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack21"},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 80 / 30},
								},
								{
									CLASS = "action.QSBAttackFinish",
								},
							},
						},
					},
				},
            },
        },
    },
}

return ssniutian_ruchang