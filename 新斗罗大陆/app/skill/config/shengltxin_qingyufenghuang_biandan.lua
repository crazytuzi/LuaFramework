
local shengltxin_qingyufenghuang_biandan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",--受击
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "shengltxin_qingyufenghuang_biandan"},
                },
                {
                    CLASS = "action.QSBSetHpPercent",
                    OPTIONS = {hp_percent = 1},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "shengltxin_qingyufenghuang_danbuff"},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",--10S后有队友则复活
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 10},
                },
                {
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						{expression = "self:self_teammates_num>1", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {buff_id = "shengltxin_qingyufenghuang_biandan"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "shengltxin_qingyufenghuang_danbuff"},
                                },
                                {
                                    CLASS = "action.QSBSetHpPercent",
                                    OPTIONS = {hp_percent = 1},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },  
            },
        },


    },
}

return shengltxin_qingyufenghuang_biandan