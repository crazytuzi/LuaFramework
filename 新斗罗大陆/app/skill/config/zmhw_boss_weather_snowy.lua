--斗罗SKILL 冰雪
--宗门武魂争霸
--id 51396
--通用 天气小精灵
--[[
冰雪陷阱
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmhw_boss_weather_snowy = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
			CLASS = "action.QSBArgsRandom",
			OPTIONS = {
				input = {
					datas = {
						{x = 200, y = 325},{x = 325, y = 325},{x = 200, y = 175},{x = 325, y = 175},
						{x = 450, y = 325},{x = 275, y = 250},{x = 450, y = 175},{x = 400, y = 250},
						{x = 500, y = 250},{x = 575, y = 350},{x = 575, y = 150},{x = 600, y = 325}
					},
				},
				output = {output_type = "data"},
				args_translate = { select = "pos"}
			},
		},
		-- {
			-- CLASS = "action.QSBMultipleTrap", 
			-- OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "zmwh_boss_dazhao_hongquan", pass_key = {"pos"}} ,
		-- },
		-- {
			-- CLASS = "action.QSBDelayTime",
			-- OPTIONS = {delay_frame = 10, pass_key = {"pos"}},
		-- },
		{
			CLASS = "action.QSBMultipleTrap", 
			OPTIONS = {interval_time = 0, count = 1, distance = 0, trapId = "zmwh_weather_hail_trap", pass_key = {"pos"}} ,
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return zmhw_boss_weather_snowy

