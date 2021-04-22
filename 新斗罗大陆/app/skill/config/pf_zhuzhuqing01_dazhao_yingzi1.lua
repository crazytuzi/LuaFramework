
local zhuzhuqing_dazhao_yingzi1 = {
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
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "pf_zhuzhuqingyingz01_attack11_4",is_hit_effect = false, haste = true},--自带延时
				},
				{
					CLASS = "action.QSBPlayAnimation",
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 18},
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
							OPTIONS = {delay_frame = 34},
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

return zhuzhuqing_dazhao_yingzi1