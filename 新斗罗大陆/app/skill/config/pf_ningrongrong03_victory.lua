local pf_ningrongrong03_victory = {
    CLASS = 'composite.QSBSequence',
    ARGS = {
        {
            CLASS = 'action.QSBArgsHasActor',
            OPTIONS = {actor_id = 1048, skin_id = 61, teammate = true}
        },
        {
            CLASS = 'composite.QSBSelector',
            ARGS = {
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'victory1'}
                        },
                        {
                            CLASS = 'action.QSBPlaySceneEffect',
                            OPTIONS = {
                                pos = {x = 625, y = 50},
                                front_layer = true,
                                effect_id = 'pf_chunbaishiyue_victory'
                            }
                        }
                    }
                },
                {
                    CLASS = 'composite.QSBSequence',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayAnimation',
                            OPTIONS = {animation = 'victory'}
                        }
                    }
                }
            }
        },
        {
            CLASS = 'action.QSBAttackFinish'
        }
    }
}

return pf_ningrongrong03_victory
