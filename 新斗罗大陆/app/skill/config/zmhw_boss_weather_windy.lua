--斗罗SKILL 大风
--宗门武魂争霸
--id 51394
--通用 天气小精灵
--[[
吹飞
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmhw_boss_weather_windy = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
			CLASS = "action.QSBArgsRandom",
			OPTIONS = {
				input = {
					datas = {
						{x = 1480, y = 100, global = true},{x = 1480, y = 200, global = true},{x = 1480, y = 300, global = true},{x = 1480, y = 400, global = true},
						{x = 1480, y = 500, global = true},{x = 1480, y = 600, global = true},
					},
				},
				output = {output_type = "data"},
				args_translate = { select = "pos"}
			},
		},
		{
			CLASS = "action.QSBTeleportToAbsolutePosition",
			OPTIONS = {verify_flip = true,args_translate = { pos = "start_pos"}},
		},
		-- {  
			-- CLASS = "composite.QSBSequence",
			-- OPTIONS = {forward_mode = true,},
			-- ARGS = {
				-- {
					-- CLASS = "action.QSBArgsIsLeft", -- 根据自己是否在屏幕左半侧选择
					-- OPTIONS = {is_attacker = true},
				-- },
				-- {
					-- CLASS = "composite.QSBSelector",
					-- OPTIONS = {pass_args = true}, -- 把选择的子行为的传递参数传递下去
					-- ARGS = {
						
					-- },
				-- },
			-- }, 
		-- },
		{
			CLASS = "action.QSBSelectTarget",
			OPTIONS = {max_distance = true,always = true},
		},
		{
			CLASS = "action.QSBBullet",
			OPTIONS = {effect_id = "zmwh_weather_windy_attack01_3",is_tornado = true, tornado_size = {width = 115, height = 200}, 
			speed = 300, sort_layer_with_actor = true},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return zmhw_boss_weather_windy

