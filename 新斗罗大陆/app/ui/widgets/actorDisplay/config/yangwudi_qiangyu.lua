
local yangwudi_qiangyu = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {is_loop = false,animation = "attack11"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				 {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "yangwudi_attack11_3"},
                 },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
				{
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 2},
                },
            },
        },
    },
}

return yangwudi_qiangyu