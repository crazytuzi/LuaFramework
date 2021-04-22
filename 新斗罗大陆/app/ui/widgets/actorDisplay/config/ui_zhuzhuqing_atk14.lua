local ui_zhuzhuqing_atk14 = 
	{
        CLASS = "composite.QUIDBParallel",
        ARGS = {
            {
                CLASS = "action.QUIDBPlayEffect",
                OPTIONS = {effect_id = "ui_zhuzhuqing_attack14_1"},
            },
            {
                CLASS = "action.QUIDBPlayAnimation",
                OPTIONS = {animation = "attack14"}
            },
            {
                CLASS = "composite.QUIDBSequence",
                ARGS = {
                    {
                        CLASS = "action.QUIDBDelayTime",
                        OPTIONS = {delay_time = 27/30},
                    },
                    {
                        CLASS = "action.QUIDBPlayEffect",
                        OPTIONS = {effect_id = "ui_zhuzhuqing_attack14_1_1"},
                    },
                },
            },
        },
    }
return ui_zhuzhuqing_atk14