-- 技能 仙草强化
-- 变身
--[[
	冰结仙草 寒冰仙草
	ID:4114 -> 4115 
	升灵台
	psf 2020-4-13
]]--

local shenglt_xiancao_bianshen1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "shenglt_xiancao_bianshen_buff1"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "shenglt_xiancao_bianshen_buff2"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_xiancao_bianshen1