

local hl_boss_cuimoniaowang_dazhao_1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		--------------动作
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11_1"},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
	            {
	                CLASS = "composite.QSBSequence",
	                ARGS = 
	                {
	                    {
	                        CLASS = "action.QSBArgsRandom",
	                        OPTIONS = {
	                            info = {count = 1},
	                            input = {
	                                datas = {1,2,3,4},
	                                formats = {1,1,1,1},
	                            },
	                            output = {output_type = "data"},
	                            args_translate = { select = "number"}
	                        },
	                    },
	                    {
	                        CLASS = "composite.QSBSelectorByNumber",
	                        ARGS = 
	                        {
	                            {
						            CLASS = "action.QSBApplyBuff",
						            OPTIONS = {flag = 1, buff_id = "hl_boss_cuimoniaowang_dazhao_buff1", teammate_and_self = true},
						        },
	                            {
						            CLASS = "action.QSBApplyBuff",
						            OPTIONS = {flag = 2, buff_id = "hl_boss_cuimoniaowang_dazhao_buff2", teammate_and_self = true},
						        },
	                            {
						            CLASS = "action.QSBApplyBuff",
						            OPTIONS = {flag = 3, buff_id = "hl_boss_cuimoniaowang_dazhao_buff3", all_enemy = true},
						        },
						        {
						            CLASS = "action.QSBApplyBuff",
						            OPTIONS = {flag = 4, buff_id = "hl_boss_cuimoniaowang_dazhao_buff3", all_enemy = true},
						        },
	                        },
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
                    OPTIONS = {delay_frame = 20},
                },
				{
                    CLASS = "action.QSBArgsIsDirectionLeft",
                    OPTIONS = {is_attacker = true},
                },
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBTrap", 
							OPTIONS = 
							{ 
								trapId = "boss_hl_cuimoniaowang_tuteng_l",
								args = 
								{
									{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
								},
							},
						},
						{
							CLASS = "action.QSBTrap", 
							OPTIONS = 
							{ 
								trapId = "boss_hl_cuimoniaowang_tuteng_r",
								args = 
								{
									{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
								},
							},
						},
					},
				},
				{
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		
    },
}

return hl_boss_cuimoniaowang_dazhao_1