	-- 技能 BOSS唐晨蝙蝠死亡
-- 技能ID 50823
-- 给唐三替身上一层boss_tangchen_tishen_zhaohuan_buff 和 boss_tangchen_tishen_zhaohuan_debuff
--[[
	boss 唐晨蝙蝠 
	ID:3777 3678 3679 副本14-8
	psf 2018-7-4
]]--

local zudui_boss_tangchen_bianfu_dead ={
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBUncancellable",
        },
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",remove_all_same_buff_id = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",teammate = true},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_debuff",teammate = true},
				},
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff"},
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}

return zudui_boss_tangchen_bianfu_dead