local jinzhan_tongyong = {
    CLASS = 'composite.QSBParallel',
    ARGS = {
        {
            CLASS = 'action.QSBPlaySound'
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_frame = 19 / 2}
                },
                {
                    CLASS = 'action.QSBPlayEffect',
                    OPTIONS = {effect_id = 'zhaowuji_attack14_1', is_hit_effect = false}
                }
            }
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_frame = 13}
                },
                {
                    CLASS = 'action.QSBPlayAnimation'
                }
            }
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_frame = 0}
                },
                {
                    CLASS = 'composite.QSBParallel',
                    ARGS = {
                        {
                            CLASS = 'action.QSBPlayEffect',
                            OPTIONS = {effect_id = 'zhaowuji_attack13_1_1', is_hit_effect = false}
                        },
                        {
                            CLASS = 'action.QSBPlayEffect',
                            OPTIONS = {is_hit_effect = true}
                        }
                    }
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
                    OPTIONS = {delay_frame = 90}
                },
                {
                    CLASS = 'action.QSBAttackFinish'
                }
            }
        }
    }
}

return jinzhan_tongyong
