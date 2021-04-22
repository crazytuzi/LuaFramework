-- 技能 暴龙之王吃鲜肉
-- 技能ID 53326
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_chixianrou = 
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack17"},--
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "shenglt_baolongzhiwang_hungry_debuff"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 1 },--
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 80 },--
				},
				-- {
				-- 	CLASS = "action.QSBHitTarget",
				-- },
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
						{ "self:hp>0","self:increase_hp:self:maxHp*0.15","under_status"},
					}
				},
				-- {
				-- 	CLASS = "action.QSBArgsConditionSelector",
				-- 	OPTIONS = {
				-- 		failed_select = 2,
				-- 		{expression = "self:buff_num:shenglt_baolongzhiwang_carrion_debuff>1", select = 1},
				-- 	}
				-- },
				-- {
				-- 	CLASS = "composite.QSBSelector",
				-- 	ARGS = {
				-- 		{CLASS = "action.QSBRemoveBuff",OPTIONS = {buff_id = "shenglt_baolongzhiwang_carrion_debuff"},},
				-- 	},
				-- },
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 35 },--
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 115 },--
				},
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						{expression = "self:shenglt_hunt", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shenglt_baolongzhiwang_hungry_debuff"},
						},
					},
				},
			},
		},
	},
}
return shenglt_baolongzhiwang_chixianrou