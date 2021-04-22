local jinzhan_tongyong = {
    CLASS = 'composite.QUIDBParallel',
    ARGS = {
        {
            CLASS = 'action.QUIDBPlaySound'
        },
        {
            CLASS = 'action.QUIDBPlayEffect',
            OPTIONS = {effect_id = 'zhaowuji_attack01_1ui', is_hit_effect = false}
        },
        {
            CLASS = 'action.QUIDBPlayAnimation',
            OPTIONS = {animation = 'attack01'}
        }
    }
}

return jinzhan_tongyong
