local pf_ssdaimubai01_ruchang = 
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
											OPTIONS = {is_attacker = true , enter_stop_position = true,offset = {x = -300, y = 0}},
										},
										-- {
											-- CLASS = "action.QSBDelayTime",
											-- OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
										-- },
										{
											CLASS = "action.QSBCharge",
											OPTIONS = {move_time = 20 / 30},
										},
									},
								},
								{
									CLASS = "composite.QSBSequence",
									ARGS = 
									{	
										{
											CLASS = "action.QSBArgsPosition",
											OPTIONS = {is_attacker = true , enter_stop_position = true,offset = {x = 300, y = 0}},
										},
										-- {
											-- CLASS = "action.QSBDelayTime",
											-- OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
										-- },
										{
											CLASS = "action.QSBCharge",
											OPTIONS = {move_time = 20 / 30},
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
													OPTIONS = {is_attacker = true , enter_stop_position = true},
												},
												{
													CLASS = "action.QSBDelayTime",
													OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
												},
												{
													CLASS = "action.QSBPlaySceneEffect",
													OPTIONS = {effect_id = "pf_ssdaimubai01_attack21_1_l",pass_key = {"pos"}},
												},
												{
													CLASS = "action.QSBDelayTime",
													OPTIONS = {delay_time = 58 / 30 ,pass_key = {"pos"}},
												},
												{
													CLASS = "action.QSBPlaySceneEffect",
													OPTIONS = {effect_id = "pf_ssdaimubai01_attack21_2_l"},
												},
											},
										},
										{
											CLASS = "composite.QSBSequence",
											ARGS = 
											{	
												{
													CLASS = "action.QSBArgsPosition",
													OPTIONS = {is_attacker = true , enter_stop_position = true},
												},
												{
													CLASS = "action.QSBDelayTime",
													OPTIONS = {delay_time = 0 / 30 ,pass_key = {"pos"}},
												},
												{
													CLASS = "action.QSBPlaySceneEffect",
													OPTIONS = {effect_id = "pf_ssdaimubai01_attack21_1_r",pass_key = {"pos"}},
												},
												{
													CLASS = "action.QSBDelayTime",
													OPTIONS = {delay_time = 58 / 30 ,pass_key = {"pos"}},
												},
												{
													CLASS = "action.QSBPlaySceneEffect",
													OPTIONS = {effect_id = "pf_ssdaimubai01_attack21_2_r"},
												},
											},
										},
									},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 3 / 30},
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack21"},
								},
							},
						},
					},
				},
				{
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 27 / 30 },
                        },
						{
							CLASS = "action.QSBShakeScreen",
							OPTIONS = {amplitude = 2, duration = 0.4, count = 1,},
						},
					},
				},
				{
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 58 / 30 },
                        },
						{
							CLASS = "action.QSBShakeScreen",
							OPTIONS = {amplitude = 3, duration = 0.4, count = 3,},
						},
					},
				},
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0 / 30 },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "pf_ssdaimubai01_mianyi2"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 13 / 30 },
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = false, buff_id = "pf_ssdaimubai01_mianyi3"},
                        },
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 69 / 30 },
                        },                  
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
            },
        },
    },
}

return pf_ssdaimubai01_ruchang