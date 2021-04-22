-- 技能 月关 菊花残 强化
-- ID 190085
-- 鞭打菊花,使他们加攻速  且延时2秒
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_zidong2 =  {
    CLASS = "composite.QSBParallel",
    ARGS = {
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
                    OPTIONS = {delay_time = 45 / 30},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false,effect_id = "yueguancz_attack13_4"},
				},
			},
		},
		{
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.6},
                },
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						-- {
						-- 	CLASS = "action.QSBPlayEffect",
						-- 	OPTIONS = {is_hit_effect = true},
						-- },
						{
							CLASS = "action.QSBGhostApplyBuff",
							OPTIONS = {buff_id = "yueguan_zidong2_buff;y",no_cancel = true},
						},
						{
							CLASS = "action.QSBPetApplyBuff",
							OPTIONS = {buff_id = "yueguan_zidong2_buff;y",no_cancel = true},
						},
						{
							CLASS = "action.QSBPetApplyBuff",
							OPTIONS = {buff_id = "yueguan_zidong2_direct;y",no_cancel = true},
						},
						{
							CLASS = "action.QSBPetApplyBuff",
							OPTIONS = {buff_id = "yueguan_zidong2_direct;y",no_cancel = true},
						},
						-- {
						-- 	CLASS = "action.QSBHitTarget",
						-- },
					},	
				},
				----延长ghost时间
				{
					CLASS = "action.QSBAddGhostLifeSpan",
					OPTIONS = {add_time = 2,status = "yueguan_berserk"},
				},
            },
        },
    },
}

return yueguan_zidong2

