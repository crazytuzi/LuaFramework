local boss_zhanghe_fenshen = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
		        {
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack13"},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS =
					{
						{ 
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 30 / 24},
						},
						{
	                        CLASS = "action.QSBActorFadeOut",
	                        OPTIONS = {duration = 0.2, revertable = true},
	                    },
                    },
                },
            },
        },
  --       {
		--     CLASS = "action.QSBSetActorToPos",
		--     OPTIONS = {pos = {x = 640, y = 320}, speed = 1500, effectId = "kong_effect"},
		-- },
		{
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 640, y = 300}},
        },
		-- {
		-- 	CLASS = "action.QSBPlayEffect",
		-- 	OPTIONS = {is_target = false, effect_id = "shadow_step_1"},
		-- },
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS =
					{
						{
							CLASS = "action.QSBPlayAnimation",
							OPTIONS = {animation = "attack11"},
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
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 20/24 },
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = 
							{
								-- {
								-- 	CLASS = "action.QSBSummonGhosts",
							 --        OPTIONS = {actor_id = 3660, life_span = 15.0, no_fog = true, relative_pos = {x = -500, y = -300}},
								-- },
								{
									CLASS = "action.QSBSummonGhosts",
							        OPTIONS = {actor_id = 3660, life_span = 11, no_fog = true, relative_pos = {x = 300, y = 0}},
								},
								{
									CLASS = "action.QSBSummonGhosts",
							        OPTIONS = {actor_id = 3660, life_span = 11, no_fog = true, relative_pos = {x = -300, y = 0}},
								},
								-- {
								-- 	CLASS = "action.QSBSummonGhosts",
							 --        OPTIONS = {actor_id = 3660, life_span = 15.0, no_fog = true, relative_pos = {x = 500, y = -300}},
								-- },
							},
						},
					},
				},
			},
		},
		-- {
  --           CLASS = "action.QSBRemoveBuff",     
  --           OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
  --       },
	},
}
return boss_zhanghe_fenshen