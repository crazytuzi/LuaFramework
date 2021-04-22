-- 技能 ss马红俊觉醒1
-- 技能ID 180191
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_fumo3 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBArgsConditionSelector",
            OPTIONS = {
                failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
                {expression = "self:is_pvp=true", select = 1},
            }
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDecreaseHpByBuffNum",
                            OPTIONS = {buff_id = "ssmahongjun_zhuoshao", base_percent = 0.02, coefficient = 0.01},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
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
    },
}

return ssmahongjun_fumo3

