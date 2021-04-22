	-- 技能 BOSS唐晨替身召唤
-- 技能ID 51010
-- 召唤唐晨BOSS(-1), 清除身上的三层BUFF, 然后根据DEBUFF数量给BOSS扣血,再获得BUFF
--[[
	boss 唐晨蝙蝠 
	ID:3777 3678 3679 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_tishen_loop = 
{
	CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBUncancellable",
        },
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff",remove_all_same_buff_id = true},
				},
			},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_time = 1},
		},
		{
			CLASS = "action.QSBSummonMonsters",
			OPTIONS = {wave = -1},
		},
		{
			CLASS = "action.QSBAttackByBuffNum", --每死掉一个蝙蝠 给自己补一个标记,减少BOSS 33%HP
			OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_debuff",trigger_skill_id = 51011,target_type = "self"},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
	},
}

return boss_tangchen_tishen_loop