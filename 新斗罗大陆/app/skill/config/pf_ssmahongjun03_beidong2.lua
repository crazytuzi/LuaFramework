-- 技能 ss马红俊被动2
-- 技能ID 475
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun03_beidong2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "pf_ssmahongjun03_beidong2", is_target = false},
        },
        -- {
        --     CLASS = "action.QSBHitTarget",
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun03_beidong2

