local anqi_liehanshuangzhen_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBChangeRage", 
            OPTIONS = {rage_value = -0.15,is_target = true,check_enmey=true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return anqi_liehanshuangzhen_trigger