local zmwh_zidan = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {is_tornado = true, tornado_size = {width = 150, height = 100}, 
                    start_pos = {x = 1280, y = 200, global = true}, speed = 400, tornado_hit_disappear = true
                    , sort_layer_with_actor = true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}


return zmwh_zidan