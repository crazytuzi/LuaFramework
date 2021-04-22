local tangchen_zhenji_zhiliao = 
{
     CLASS = "composite.QSBSequence",
     ARGS = {  
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "tangchen_zhenji_zhiliao", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return tangchen_zhenji_zhiliao