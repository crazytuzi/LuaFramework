-- 技能 ss马红俊闪现
-- 技能ID 471
-- 顾名思义 魔法
--[[
    魂师 凤凰马红俊
    ID:1046 
    psf 2019-9-10
]]--


local ssmahongjun03_beidong1 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBActorStand",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id="pf_ssmahongjun03_attack12_1",is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBActorFadeOut",
            OPTIONS = {duration = 0.3, revertable = true},
        },
        {
            CLASS = "action.QSBTeleportToPosition",
        },
        {
            CLASS = "action.QSBActorFadeIn",
            OPTIONS = {duration = 0.3, revertable = true},
        },
        -- {
        --     CLASS = "action.QSBPlayEffect",
        --     OPTIONS = {effect_id="ssmahongjun03_attack12_2",is_hit_effect = true},
        -- },       
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun03_beidong1