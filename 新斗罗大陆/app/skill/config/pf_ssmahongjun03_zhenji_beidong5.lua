-- 技能 ss马红俊真技火盾
-- 技能ID 190273
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhenji_beidong5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyAbsorbWithBuffId",
            OPTIONS = {buff_id = "pf_ssmahongjun03_zhuoshao", absorb_buff_id = "ssmahongjun_zhenji_huodun"
            , base_percent = 0, coefficient = 0.05, check_enemy = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_zhenji_beidong5

