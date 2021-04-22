
local zudui_boss_guimei_jingzhilingyu = {
CLASS = "composite.QSBParallel",
    ARGS = {
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false, effect_id = "boss_guimei_attack11_1"},
		}, 
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 8/30},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "guimei_attack11_4_1", pos  = {x = 550 , y = 340}, ground_layer = true},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 18/30},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "guimei_attack11_4_2", pos  = {x = 550 , y = 340}, ground_layer = true},
                },
            },
        },
        {   
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 110/30},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "guimei_attack11_1_4", pos  = {x = 550 , y = 340}, ground_layer = true},
                },
            },
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 110/30},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "guimei_attack11_1_2_2", pos  = {x = 640 , y = 360},ground_layer = true},
                },
            },
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="guimei_walk"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 110/30},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "guimei_attack11_4", pos  = {x = 640 , y = 360}, ground_layer = true},
                },
            },
        },
    },
}
return zudui_boss_guimei_jingzhilingyu
