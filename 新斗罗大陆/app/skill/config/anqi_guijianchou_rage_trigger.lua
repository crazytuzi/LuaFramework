-- 技能 暗器 削减能量
-- 技能ID 40560
-- 叠满4层BUFF触发,减20%当前能量
--[[
	暗器 鬼见愁
	ID:1528
	psf 2020-1-17
]]--

local anqi_guijianchou_rage_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBChangeRage",	
			OPTIONS = {rage_value = -0.2, rage_value_min = -200, rage_value_max = -50},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guijianchou_rage_trigger
