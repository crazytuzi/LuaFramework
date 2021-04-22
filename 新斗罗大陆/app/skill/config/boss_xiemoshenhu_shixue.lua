-- 技能 BOSS邪魔神虎 嗜血
-- 技能ID 50867
-- 队友加攻速, 对手消debuff
--[[
	boss 邪魔神虎
	ID:3696
	psf 2018-7-19
]]--

local boss_xiemoshenhu_shixue = 
{
	CLASS = "composite.QSBParallel",
	ARGS =
	{
		{
			CLASS = "composite.QSBSequence",
			ARGS =
			{
				{
					CLASS = "action.QSBPlayAnimation",
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
					OPTIONS = {delay_frame = 24},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {multiple_target_with_skill = true, buff_id = "boss_xiemoshenhu_debuff"},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {teammate_and_self = true, buff_id = "boss_xiemoshenhu_buff"},
				},
			},
		},
	},
}
return boss_xiemoshenhu_shixue