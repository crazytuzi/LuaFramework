-- 技能 BOSS唐晨入场
-- 技能ID 50813
-- 入场,使玩家恐惧(尽可能让玩家把仇恨转到自己身上)
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local zudui_boss_tangchen_ruchang = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
    {
        {
            CLASS = "action.QSBUncancellable",
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {enemy = true, buff_id = "boss_tangchen_ruchang_debuff"},
		},
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_special_mark"},
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBActorStand",
						},
						{
							CLASS = "action.QSBActorFadeOut",
							OPTIONS = {duration = 0.15, revertable = true},
						},
					},
				},
				{
					CLASS = "action.QSBTeleportToAbsolutePosition",
					OPTIONS = {pos = {x = 625,y = 275}},
				},
				{
					CLASS = "action.QSBActorFadeIn",
					OPTIONS = {duration = 0.15, revertable = true},
				},
			},
		},
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
					OPTIONS = {no_stand = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return zudui_boss_tangchen_ruchang