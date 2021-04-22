-- 技能 月关 菊花分株
-- ID 173
-- 给pet加标记,催促它使用270
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_zidong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
					ARGS = {
						{
							CLASS = "action.QSBHitTarget",
						},
					},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		{
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBPetApplyBuff",
							OPTIONS = {buff_id = "yueguan_zidong1_direct;y"},
						},
						{
							CLASS = "action.QSBPetApplyBuff",
							OPTIONS = {buff_id = "yueguan_zidong1_direct;y"},
						},
					},	
				},
            },
        },
    },
}

return yueguan_zidong1

