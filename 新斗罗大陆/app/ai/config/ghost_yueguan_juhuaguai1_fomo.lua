
local ghost_yueguan_juhuaguai1_fomo = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
        {
            CLASS = "action.QAIAttackByStatus",
			OPTIONS = {is_team = false, status = "yueguan_aim"}
        },
		{
            CLASS = "action.QAIAttackByHitlog",
        },
        {
			CLASS = "action.QAIAttackClosestEnemy",
		},
    },
}

return ghost_yueguan_juhuaguai1_fomo