local boss_huangjindaimao_zidan = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "daimao_shuidun"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true, effect_id = "huangjindaimao_attack11_2", speed = 1500, hit_effect_id = "huangjindaimao_attack11_3"},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true, effect_id = "huangjindaimao_attack11_2", speed = 1500, hit_effect_id = "huangjindaimao_attack11_3"},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return boss_huangjindaimao_zidan