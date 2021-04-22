-- 技能 BOSS焱 X型火焰
-- 技能ID 50370
-- boss 焱 ID:3287 副本9-4
-- lyl 2018-5-7


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
							OPTIONS = {buff_id = "boss_huowushuang_crossfire_debuff1",is_target = true,no_cancel = true},
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