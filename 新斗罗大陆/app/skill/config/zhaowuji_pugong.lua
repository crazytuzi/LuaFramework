local jinzhan_tongyong = {
    CLASS = 'composite.QSBParallel',
    ARGS = {
        {
            CLASS = 'action.QSBPlaySound'
        },
        {
            CLASS = 'action.QSBPlayEffect',
            OPTIONS = {effect_id = 'zhaowuji_attack01_1', is_hit_effect = false}
        },
        {
            CLASS = 'action.QSBPlayAnimation'
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_frame = 14}
                },
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayEffect',
                            OPTIONS = {is_hit_effect = true}
                        },
                        {
                            CLASS = 'action.QSBHitTarget'
                        }
                    }
                },
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_frame = 8}
                },
                {
                    CLASS = 'action.QSBHitTarget'
                }
            }
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_frame = 46}
                },
                {
                    CLASS = 'action.QSBAttackFinish'
                }
            }
        }
    }
}

return jinzhan_tongyong
