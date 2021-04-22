local guimei_zhenji_3 = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsRandom",
            OPTIONS = {
                info = {count = 1},
                input = {
                    datas = {162,190127},
                    formats = {1,2},
                },
                output = {output_type = "data"},
                args_translate = { select = "skill_id"}
            },
        },
        {
            CLASS = "action.QSBTriggerSkill",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return guimei_zhenji_3
