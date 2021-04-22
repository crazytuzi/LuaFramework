-- 技能 暗器 日月神针配件治疗
-- 技能ID 40669~40673
-- 获得已损失生命X%的治疗(每3次CD1秒)，且有Y%概率重置主力效果冷却时间
--[[
	暗器 日月神针
	ID:1531
	psf 2020-6-2
]]--

local anqi_guijianchou_trigger1 = 
{
	CLASS = "composite.QSBSequence",
	ARGS = 
	{
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
				{ "self:hp>0","self:increase_hp:self:maxHp-hp*0.07","under_status"},--没有运算优先级,先算-法
			}
		},
		{
			CLASS = "action.QSBArgsConditionSelector",
			OPTIONS = {
				failed_select = 2,
				{expression = "self:random<0.15", select = 1},
			}
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "action.QSBTriggerSkill",	
					OPTIONS = {skill_id = 40662, wait_finish = false},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_guijianchou_trigger1

