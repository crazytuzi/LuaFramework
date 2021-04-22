	-- 技能 BOSS唐晨蝙蝠退场
-- 技能ID 50822
-- 蝙蝠自我隐藏, 给唐晨替身上一层boss_tangchen_tishen_zhaohuan_buff
--[[
	boss 唐晨蝙蝠 
	ID:3777 3678 3679 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_bianfu_zibao ={
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBUncancellable",
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
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
									OPTIONS = {duration = 0.15},
								},
							},
						},
						-- {
							-- CLASS = "action.QSBTeleportToAbsolutePosition",
							-- OPTIONS = {pos = {x = 650,y = 350},  verify_flip = true},
						-- },
						-- {
							-- CLASS = "action.QSBActorFadeIn",
							-- OPTIONS = {duration = 0.15, revertable = true},
						-- },
					},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_tangchen_bianfu_zhaohuan_debuff"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",remove_all_same_buff_id = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",teammate = true},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}

return boss_tangchen_bianfu_zibao