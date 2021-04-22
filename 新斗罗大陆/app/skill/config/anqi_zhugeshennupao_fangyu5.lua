local anqi_zhugeshennupao_fangyu5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyAbsorbWithBuffId",
            OPTIONS = {buff_id = "anqi_zhugeshennupao_zidan1", absorb_buff_id = "anqi_zhugeshennupao_hudun"
            , base_percent = 0.8, coefficient = 0.2},
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "anqi_zhugeshennupao_zidan5", is_target = false, remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_zhugeshennupao_fangyu5