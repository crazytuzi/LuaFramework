-- 技能 海神三叉戟的叠层4
-- 技能ID 2020026

local sq_haishensanchaji_dieceng4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "sq_haishensanchaji_die4", is_target = false, remove_all_same_buff_id = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_haishensanchaji_dianliang4", is_target = false},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sq_haishensanchaji_biaoji", teammate_and_self = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_haishensanchaji_dieceng4

