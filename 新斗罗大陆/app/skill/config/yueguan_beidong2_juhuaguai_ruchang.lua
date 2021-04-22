-- 技能 月关 满地伤菊花妖入场技
-- ID 276
-- 先加攻击属性BUFF, 再判断有没有觉醒
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_beidong2_juhuaguai_ruchang = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
		{
			CLASS = "action.QSBJumpAppear",
			OPTIONS = {jump_animation = "attack21"},
		},  
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "yueguan_beidong2_buff;y"},--技能成长加攻击
				},
				{
					CLASS = "action.QSBAttackByBuffNum", --临时标记判断月关是否觉醒
					OPTIONS = {buff_id = "fumo_yueguan_buff",num_pre_stack_count = 1,trigger_skill_id = 272,skill_level = 1,target_type = "teammate"}
				},
				{
					CLASS = "action.QSBArgsIsUnderStatus",
					OPTIONS = {is_attacker = true,status = "yueguan_full"}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = 
					{
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "fumo_yueguan_juhuaguai_buff"},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "fumo_yueguan_juhuaguai_buff"},
						},
					},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "yueguan_beidong2_full"},--清除临时标记
				},
			},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.7},
                },
				{
					CLASS = "action.QSBManualMode",
					OPTIONS = {exit = true},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return yueguan_beidong2_juhuaguai_ruchang 

