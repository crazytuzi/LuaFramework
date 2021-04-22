--自杀
local qiandaoliu_zisha = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
		},
        {
            CLASS = "action.QSBImmuneDeathSuicide", 
            OPTIONS = {use_dead_skill = true},
        },
    },    
}
return qiandaoliu_zisha