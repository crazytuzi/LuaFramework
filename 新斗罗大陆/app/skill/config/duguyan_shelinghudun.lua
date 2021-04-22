
local duguyan_shelinghudun = {
	CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 30},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = "shelinghudun;y", lowest_hp_teammate_and_self = true, no_cancel = true},
                                        },
                                        {
                                            CLASS = "action.QSBApplyBuff",
                                            OPTIONS = {buff_id = "shelinghudun;y", is_target = self, no_cancel = true},
                                        },
                                    },  
                        },                 
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return duguyan_shelinghudun