-- 技能 暴龙之王吃腐肉
-- 技能ID 53327
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_chifurou = 
{
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack17_1"},--
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
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "shenglt_baolongzhiwang_carrion_debuff"},
				},
				-- {
				-- 	CLASS = "action.QSBHitTarget",
				-- },
				-- {
				-- 	CLASS = "action.QSBActorStatus",
				-- 	OPTIONS = 
				-- 	{
				-- 		{ "self:hp>0","self:decrease_hp:maxHp*0.12","under_status"},
				-- 	}
				-- },
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
						failed_select = 3,
						{expression = "self:buff_num:shenglt_baolongzhiwang_carrion_debuff>3", select = 1},
						{expression = "self:shenglt_hunt", select = 2},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "shenglt_baolongzhiwang_hunt_buff"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "shenglt_baolongzhiwang_stun_debuff"},
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack18", is_loop = true},--
								},
								{
									CLASS = "action.QSBActorKeepAnimation",
									OPTIONS = {is_keep_animation = true}
								},
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 210 },--
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "shenglt_baolongzhiwang_carrion_debuff",remove_all_same_buff_id = true},
								},
								{
									CLASS = "action.QSBActorKeepAnimation",
									OPTIONS = {is_keep_animation = false}
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "shenglt_baolongzhiwang_stun_debuff"},
								},
							},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "shenglt_baolongzhiwang_hungry_debuff"},
						},
					},
				},
				{
					CLASS = "action.QSBAttackFinish"
				},
			},
		},
	},
}
return shenglt_baolongzhiwang_chifurou