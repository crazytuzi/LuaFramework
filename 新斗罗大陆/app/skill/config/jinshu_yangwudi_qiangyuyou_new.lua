local yangwudi_qiangyuyou = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		-- {
            -- CLASS = "action.QSBPlaySceneEffect",
            -- OPTIONS = {effect_id = "yangwudi_attack11_3_2", pos  = {x = 1780 , y = 340}, ground_layer = true},
        -- },
		{
			CLASS = "action.QSBTrap", 
			OPTIONS = 
			{ 
				trapId = "jinshu_yangwudi_changqiangyu_right_rect",
				args = 
				{
					{delay_time = 0, pos = {x = 1730 , y = 340}} ,
				},
			},
		},
		{
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 1.5},
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
		                    CLASS = "action.QSBPlayAnimation",
		                },
		                {
				            CLASS = "action.QSBAttackFinish"
				        }, 
			        },
		        },
		        {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 1 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "new_yangwudi_atk11_1_2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 6 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "new_yangwudi_atk11_1_1", is_hit_effect = false},
                        },
                    },
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
					   
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 2},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "composite.QSBSequence",
									ARGS = {
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 1000 , y = 520}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 640 , y = 200}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 650 , y = 220}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 800 , y = 350}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 1080 , y = 220}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 700 , y = 400}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 740 , y = 350}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 900 , y = 400}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 900 , y = 340}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 1000 , y = 270}, ground_layer = true},
										}
									},
								},
								{
									CLASS = "action.QSBTrap", 
									OPTIONS = 
									{ 
										trapId = "jinshu_yangwudi_changqiangyu_trap",
										args = 
										{
											{delay_time = 0 , pos = {x = 950, y = 340}} ,
										},
									},
								},
							},
						},
					},
				},				
            },
        },     
    },
}

return yangwudi_qiangyuyou