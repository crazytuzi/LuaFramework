local boss_chaoxuemuzhu_chanrao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_target = false, effect_id = "wyw_story_07"},
        },            
        {
            CLASS = "action.QSBAttackFinish",
        },
        -- {
        --  CLASS = "action.QSBRemoveBuff",
        --  OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
    },
}

return boss_chaoxuemuzhu_chanrao