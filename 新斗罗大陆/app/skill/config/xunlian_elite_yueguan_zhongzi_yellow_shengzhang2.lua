local zhongzi_yellow_shengzhang2 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3582, life_span = 20.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -2},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_yellow_shengzhang2