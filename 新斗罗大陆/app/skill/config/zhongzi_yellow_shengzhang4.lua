local zhongzi_yellow_shengzhang4 = {
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		-- {
		-- 	CLASS = "action.QSBSummonGhosts",
		--   	OPTIONS = {actor_id = 3582, life_span = 40.0, no_fog = false},
		-- },
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -4},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return zhongzi_yellow_shengzhang4