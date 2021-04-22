
local bibidong_zhenji_ai = {
    CLASS = "composite.QAISelector",
	OPTIONS = {randomly = true},
    ARGS = 
    {
        {
            CLASS = "action.QAIAttackAnyEnemy",
        },
        {
			CLASS = "action.QAIAttackClosestEnemy",
		},
    },
}

return bibidong_zhenji_ai