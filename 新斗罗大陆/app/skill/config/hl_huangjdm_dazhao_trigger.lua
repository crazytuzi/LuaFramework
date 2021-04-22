-- 技能 黄金玳瑁大招触发岩锥
-- 技能ID 35012
-- 远程：单体子弹
--[[
	hunling 黄金玳瑁
	ID:2003
	psf 2019-6-10
]]--

local hl_huangjdm_dazhao_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
						{expression = "self:buff_num:hl_huangjdm_pugong_buff>0", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
                            CLASS = "action.QSBBullet",
                        },
					},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
						{expression = "self:buff_num:hl_huangjdm_dazhao_count>4", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "hl_huangjdm_dazhao_buff"},
								},
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "hl_huangjdm_dazhao_count",remove_all_same_buff_id = true},
								},
							},
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "hl_huangjdm_dazhao_count"},
						},
					},
				},
            },
        },
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return hl_huangjdm_dazhao_trigger