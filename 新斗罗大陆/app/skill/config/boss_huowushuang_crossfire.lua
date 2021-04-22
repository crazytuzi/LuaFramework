-- 技能 BOSS火无双 十字火焰
-- 技能ID 50370
-- 给一人上全套十字火焰BUFF
--[[
	boss 火无双
	ID:3287 副本6-16
	psf 2018-3-30
]]--

local boss_huowushuang_crossfire = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
            CLASS = "action.QSBPlaySound"
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
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
             ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 45},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{	
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff",is_target = true,no_cancel = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_l",is_target = true,no_cancel = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_r",is_target = true,no_cancel = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff_b",is_target = true,no_cancel = true},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "boss_huowushuang_crossfire_prompt",is_target = true,no_cancel = true},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
						},
					},
				},
            },
        },
    },
}

return boss_huowushuang_crossfire