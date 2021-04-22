--  创建人：刘悦璘
--  创建时间：2018.03.22
--  NPC：大地之王
--  类型：攻击
local npc_dadizhiwang_shaxuan = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBActorStand",
        }, 
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "dadizhiwang_hongquan", is_hit_effect = false},
        },  
        {
            CLASS = "composite.QSBSequence",
            ARGS = {      
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 36},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                }, 
            },
        },
    },
}

return npc_dadizhiwang_shaxuan