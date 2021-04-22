-- 技能 ss马红俊普攻触
-- 技能ID 476
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_pugong_chufa = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attackee = true,status = "zhuoshao"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },

                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return ssmahongjun_pugong_chufa

