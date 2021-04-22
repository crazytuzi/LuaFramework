-- 技能 死:杀死冰晶
-- ID 53319
-- 冰天雪女死后删除冰晶
--[[
	冰天雪女
	升灵台
	ID:4126
	psf 2020-4-13
]]--

local shenglt_bingtianxuenv_fanzhaohuan = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
            CLASS = "action.QSBGhostApplyBuff",
            OPTIONS = {buff_id = "shenglt_bingtianxuenv_debuff"},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_bingtianxuenv_fanzhaohuan