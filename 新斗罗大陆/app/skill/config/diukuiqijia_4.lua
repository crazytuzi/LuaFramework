local diukuiqijia = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "walk_1", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = "action.QSBMoveToPosition",
            OPTIONS = {x=-2000,y=390},
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return diukuiqijia