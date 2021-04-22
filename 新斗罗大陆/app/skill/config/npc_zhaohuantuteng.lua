local npc_zhaohuantuteng = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {     
        {
            CLASS = "action.QSBSummonGhosts",
            OPTIONS = {actor_id = 3819 , life_span = 21,number = 1,  relative_pos = {x = 0, y = -50}, no_fog = false,is_attacked_ghost = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return npc_zhaohuantuteng
