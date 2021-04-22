local qianrenxue_chireriguang = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = {
		{
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack14_2", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
		{
                     CLASS = "composite.QSBSequence",
                     ARGS = {
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang1"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang2"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang3"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang4"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang5"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang6"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang7"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang8"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang9"},
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1},
								},
								{
									CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
									OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "qianrenxue_chireriguang10"},
								},
							},
		},
		{
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 3},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
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
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                             CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
    },
}

return qianrenxue_chireriguang