-- 技能 ss马红俊灼烧触发
-- 技能ID 478
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhuoshao_chufa = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_zhuoshao_chufa

