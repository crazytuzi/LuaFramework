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
            CLASS = "action.QSBHeroicalLeap",
            OPTIONS = {distance = 200, move_time = 13/24},
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "back", is_loop = true},       
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },        
        {
            CLASS = "action.QSBHeroicalLeap",
            OPTIONS = {distance = -320, move_time = 28/24},
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = "action.QSBRemoveFromGrid",       
        },  
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "back_1", is_loop = true},       
        },     
        -- {
        --     CLASS = "action.QSBAttackFinish"
        -- },
    },
}

return zhaowuji_soul