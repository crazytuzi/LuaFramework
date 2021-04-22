local shifa_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBRoledirection",
            OPTIONS = {direction = "left"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory"},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong