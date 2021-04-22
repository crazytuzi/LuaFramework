
local pf_ningrongrong03_dazhao_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,reverse_result = false, status = "ningrongrong_hetiji"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "ningrongrong_hetiji_buff"},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
			},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "ningrongrong_hetiji_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
    },
}

return pf_ningrongrong03_dazhao_trigger