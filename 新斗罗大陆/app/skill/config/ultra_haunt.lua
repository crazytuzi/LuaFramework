local guiyingchongchong = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack11"},
		},

		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				-- {
				-- 	CLASS = "action.QSBPlayEffect",
    --                 OPTIONS = {effect_id = "haunt_1", follow_actor_animation = true},
				-- },
				{
					CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 57},
				},
				-- {
				-- 	CLASS = "action.QSBPlayEffect",
    --                 OPTIONS = {effect_id = "haunt_2"},
				-- },
				{
					CLASS = "action.QSBSummonGhosts",
	            	OPTIONS = {actor_id = 41584, life_span = 7.0, tint_color = ccc3(147, 112, 219 * 0.9), use_render_texture = false}, -- 在每个敌人身后制造一个npc，无法被攻击，5秒后自动死亡
				},
				{
					CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
				},
				{
		             CLASS = "action.QSBApplyBuff",
		            OPTIONS = {buff_id = "kong_buff", teammate = true},
		        },
		        {
		            CLASS = "action.QSBHitTarget",
		        },
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.9},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.9},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
			},
		},
	},
}

return guiyingchongchong