-- 技能 月关 通用满足条件标记
-- ID 272
-- 仅在一个技能内使用,用完就删除
-- 1.标记场上已有两朵,阻止继续召花苞
-- 2.标记月关已经觉醒
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_beidong2_debuff_trigger = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "yueguan_beidong2_full"},
		},
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,status = "yueguan_fumo"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "fumo_yueguan_dazhao_juhuaguai_count"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "fumo_yueguan_dazhao_juhuaguai_count"},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return yueguan_beidong2_debuff_trigger 

