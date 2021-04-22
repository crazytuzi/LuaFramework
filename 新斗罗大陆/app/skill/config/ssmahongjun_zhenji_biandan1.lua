-- 技能 ss马红俊真技大招1
-- 技能ID 190264
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhenji_biandan1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBUncancellable"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 18},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ssmahongjun_attack15_1", is_hit_effect = false},
                },
            }, 
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "ssmahongjun_zhenji_biandan1", is_target = false},
                },
                -- {
                --     CLASS = "action.QSBRemoveBuff",
                --     OPTIONS = {buff_id = "ssmahongjun_zhenji_dazhao", is_target = false},
                -- },
            },
        },
    },
}

return ssmahongjun_zhenji_biandan1

