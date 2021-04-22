local zhongzi_yellow_shengzhang3 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3582, life_span = 30.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -3},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_yellow_shengzhang3