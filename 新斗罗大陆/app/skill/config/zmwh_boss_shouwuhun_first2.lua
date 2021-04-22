--斗罗SKILL 兽武魂宗门守卫
--宗门武魂争霸
--id 51339
--通用 马甲
--[[
召守卫61029
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_shouwuhun_first2 = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
    {  
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
		-- {
			-- CLASS = "action.QSBPlayAnimation",
			-- OPTIONS = {animation = "attack09"},
		-- },
		{
			CLASS = "action.QSBPlaySound"
		},
		{
			CLASS = "action.QSBShakeScreen",
			OPTIONS = {amplitude = 3, duration = 0.15, count = 1,},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBArgsRandom",
					OPTIONS = {
						input = {
							datas = {
								{x = 200, y = 200},{x = 400, y = 200},{x = 600, y = 200},
								{x = 200, y = 400},{x = 400, y = 400},{x = 600, y = 400}
							},
						},
						output = {output_type = "data"},
						args_translate = { select = "absolute_pos"}
					},
				},
				{
					CLASS = "action.QSBSummonGhosts",
					OPTIONS = {actor_id = 61027 , life_span = 120,number = 1 , appear_skill = 51367 , enablehp = true,
					hp_percent = 0 , hp_fixed = 3,divide_pos = {x = 75, y = 50},
					no_fog = false,is_attacked_ghost = true},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
    },
}

return zmwh_boss_shouwuhun_first2