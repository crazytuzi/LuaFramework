-- 技能 鬼虎分身
-- 召唤两个分身3307
--[[
	boss 朱竹青
	ID:3306 副本3-16
	psf 2018-1-23
]]--

local boss_zhuzhuqing_fenshen = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "composite.QSBSequence",
			ARGS =
			{
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
				-- {
		            -- CLASS = "action.QSBSetActorToPos",
		            -- OPTIONS = {pos = {x = 640, y = 300}, speed = 1500, effectId = "kong_effect"},
		        -- },
		        {
			        CLASS = "action.QSBPlayEffect",
			        OPTIONS = {is_target = false},
			    },
		        {
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
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 22},
								},
								{
									CLASS = "composite.QSBParallel",
									ARGS = 
									{
										{
											CLASS = "action.QSBSummonGhosts",
							            	OPTIONS = {actor_id = 3307, life_span = 12.0, no_fog = true, relative_pos = {x = -50, y = -50}, set_color = ccc3(42, 85, 255)},
										},
										{
											CLASS = "action.QSBSummonGhosts",
							            	OPTIONS = {actor_id = 3307, life_span = 12.0, no_fog = true, relative_pos = {x = 50, y = 50}, set_color = ccc3(42, 85, 255)},
										},
									},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
								},
								{
									CLASS = "action.QSBAttackFinish",
								},
							},
						},
					},
				},
			},
		},
	},
}

return boss_zhuzhuqing_fenshen