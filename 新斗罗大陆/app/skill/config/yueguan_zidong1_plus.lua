-- 技能 月关 菊花分株  强化版 
-- ID 173
-- 给pet加标记,催促它使用270 , 施法后回血,加两层yueguan_zhenji_buff1
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_zidong1_plus = {
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
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 6/30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false,effect_id = "yueguancz_attack12_1"},
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
						-- {
						-- 	CLASS = "action.QSBHitTarget",
						-- },
					},	
				},
				---武魂真身强化效果:
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "yueguan_zhenji_buff1"},
				},
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "hp_percent<1","increase_hp:self:maxHp*0.10"},
					}
				},
            },
        },
    },
}

return yueguan_zidong1_plus

