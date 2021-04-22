

local zudui_hongbianfu_penhuo = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
	--	{
    --                CLASS = "action.QSBPlayLoopEffect",
    --                OPTIONS = {effect_id = "bianfu_penhuo_hongkuang",is_hit_effect = false},
    --    },
        {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
        },
		{
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11_1"},       
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11_2", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
		{
            CLASS = "action.QSBPlayLoopEffect",
             OPTIONS = {effect_id = "bianfu_penhuo",is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 2.8},
						},
                        {
                            CLASS = "action.QSBReloadAnimation",
                        },
                        {
                            CLASS = "action.QSBActorKeepAnimation",
                            OPTIONS = {is_keep_animation = false}
                        },
                        {
                            CLASS = "action.QSBActorStand",
                        },
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack11_3"},       
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
                     CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
				{
                     CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
				{
                     CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
				{
                     CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
				{
                     CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
				{
                     CLASS = "action.QSBHitTarget",
                },
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.3},
                },
				{
                     CLASS = "action.QSBHitTarget",
                },
			--	{
            --        CLASS = "action.QSBStopLoopEffect",
            --        OPTIONS = {effect_id = "bianfu_penhuo_hongkuang",is_hit_effect = false},
            --    },
				{
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "bianfu_penhuo",is_hit_effect = false},
                },
				},
			},
            },
        },
    },
}

return zudui_hongbianfu_penhuo