-- 技能 BOSS死亡魔蛛 召唤
-- 技能ID 50870
-- 召唤小蜘蛛
--[[
	boss 死亡魔蛛
	ID:3698
	psf 2018-7-19
]]--

local dugubo_zhenji_plus = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = {"pf_dugubo01_zhenji_debuff","pf_dugubo01_zhenji_die"}, is_target = true},
        },
        {
			CLASS = "action.QSBAttackFinish",
		},
	},
}
return dugubo_zhenji_plus