local ningrongrong_victory = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
    	{
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "ningrongrong_victory", is_hit_effect = false},
        },
    },
}

return ningrongrong_victory
