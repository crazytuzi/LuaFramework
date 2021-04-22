-- 技能 海神三叉戟死亡上buff3
-- 技能ID 2020115

local sq_haishensanchaji_siwang3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "sq_haishensanchaji_siwangchufa3", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_haishensanchaji_shunjian_chufa3", highest_attack_teammate_and_self = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_haishensanchaji_siwang3
