local ssniutian_victory = 
{
 
        CLASS ="composite.QSBParallel",
        ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "victory2"},

                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_2"},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_ssptanghao01_victory_2_1"},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {pos  = {x = 100 , y = 100},front_layer = true,effect_id = "pf_qx_shenglitexiao_red"},
                },

            },

    
}
return ssniutian_victory