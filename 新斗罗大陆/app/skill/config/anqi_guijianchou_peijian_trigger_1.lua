-- 技能 暗器 煞影索命 施加状态
-- 技能ID 40545~40549
-- 对当前攻击目标施加debuff, 清除其他目标的debuff.
-- 配件伤害过低时触发当前等级的飞弹
--[[
	暗器 鬼见愁
	ID:1528
	psf 2020-1-17
]]--

local anqi_guijianchou_peijian_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attackee = true,status = "guijianchou_peijian",reverse_result =true},
		},
		{
            CLASS = "composite.QSBSelector",
            ARGS = {
				{
					CLASS = "action.QSBApplyBuff",	
					OPTIONS = {buff_id = "anqi_guijianchou_debuff",all_enemy = true},
				},
				{
					CLASS = "action.QSBResetBuffCooldown",	
					OPTIONS = {status = "guijianchou_zhuli"},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guijianchou_peijian_trigger

