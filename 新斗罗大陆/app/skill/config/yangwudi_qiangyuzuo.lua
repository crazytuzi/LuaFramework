-- 2018-7-10  psf: 因为预警框不循环、伤害判定范围和预警框不一致的问题， 把预警框和伤害都做成陷阱了.

local yangwudi_qiangyuzuo = {
    CLASS = "composite.QSBSequence",
    ARGS = { 
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		-- {
            -- CLASS = "action.QSBPlaySceneEffect",
            -- OPTIONS = {effect_id = "yangwudi_attack11_3_3", pos  = {x = -420 , y = 340}, ground_layer = true},
        -- },
		{
            CLASS = "action.QSBTrap", 
            OPTIONS = 
            { 
				trapId = "boss_yangwudi_changqiangyu_left_rect",
				args = 
				{
					{delay_time = 0, pos = {x = -480 , y = 340}} ,
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
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 400 , y = 520}, ground_layer = true},
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
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 50 , y = 220}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 200 , y = 350}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 580 , y = 220}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 270 , y = 400}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 140 , y = 350}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 400 , y = 400}, ground_layer = true},
										},
										{
											CLASS = "action.QSBDelayTime",
											OPTIONS = {delay_time = 0.15},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 200 , y = 340}, ground_layer = true},
										},
										{
											CLASS = "action.QSBPlaySceneEffect",
											OPTIONS = {effect_id = "yangwudi_attack11_3_1", pos  = {x = 300 , y = 270}, ground_layer = true},
										}
									},
								},
								{
									CLASS = "action.QSBTrap", 
									OPTIONS = 
									{ 
										trapId = "boss_yangwudi_changqiangyu_trap",
										args = 
										{
											{delay_time = 0 , pos = {x = 325 , y = 340}} ,
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

return yangwudi_qiangyuzuo