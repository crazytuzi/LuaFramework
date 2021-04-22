local anqi_zhugeshennupao_kaihuo = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "zhugeshennupao_attack", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 125,y = 75}, effect_id = "zhugeshennupao_zidan", speed = 1500,
                    hit_effect_id = "zhugeshennupao_shouji", check_target_by_skill = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },        
    },
}

return anqi_zhugeshennupao_kaihuo