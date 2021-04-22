-- 英雄大招动作
local baihe_atk11= {
    CLASS = "composite.QUIDBParallel",
    ARGS = 
    {
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
				{
					CLASS = "action.QUIDBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "baihe_dazhao_ui"},
				},
            },
        },
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack11"},
        },
		{
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 100},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}
return baihe_atk11