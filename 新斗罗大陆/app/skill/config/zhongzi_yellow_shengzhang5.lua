local zhongzi_yellow_shengzhang5 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3582, life_span = 50.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -5},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_yellow_shengzhang5