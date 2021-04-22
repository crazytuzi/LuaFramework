local zhaowuji_soul = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack12", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = "action.QSBMoveToPosition",
            OPTIONS = {x = 600,y = 300},
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack01"},       
        },         
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zhaowuji_soul