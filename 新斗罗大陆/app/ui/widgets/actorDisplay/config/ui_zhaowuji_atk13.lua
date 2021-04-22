local zhaowuji_dalijinganghou = {
    CLASS = 'composite.QUIDBParallel',
    ARGS = {
        {
            CLASS = 'action.QUIDBPlaySound',
            OPTIONS = {sound_id = 'zhaowuji_skill'}
        },
        {
            CLASS = 'composite.QUIDBSequence',
            ARGS = {
                {
                    CLASS = 'action.QUIDBDelayTime',
                    OPTIONS = {delay_frame = 0}
                },
                {
                    CLASS = 'action.QUIDBPlayEffect',
                    OPTIONS = {effect_id = 'zhaowuji_attack11_1ui', is_hit_effect = false}
                }
            }
        },
        {
            CLASS = 'composite.QUIDBSequence',
            ARGS = {
                {
                    CLASS = 'action.QUIDBPlayAnimation',
                    OPTIONS = {animation = 'attack11'}
                }
            }
        }
    }
}

return zhaowuji_dalijinganghou
