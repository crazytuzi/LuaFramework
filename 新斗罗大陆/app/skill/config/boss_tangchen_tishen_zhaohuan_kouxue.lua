	-- 技能 BOSS唐晨替身给唐晨扣血给自己上BUFF
-- 技能ID 50825
-- 给BOSS扣血,再获得BUFF
--[[
	boss 唐晨蝙蝠 
	ID:3777 3678 3679 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_tishen_zhaohuan_kouxue ={
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff"},
				},
				{
					CLASS = "action.QSBHitTarget",
				},
			},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}

return boss_tangchen_tishen_zhaohuan_kouxue