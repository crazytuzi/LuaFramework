
local shengltxin_qingyufenghuang_dan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 3},
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack18_1",is_loop = true, is_keep_animation = true},
				},
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 2},
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack18_2"},
				},
			},
		},
	},
}

return shengltxin_qingyufenghuang_dan