
local pf_ayin01_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true,turn_on = true,time = 0.3,revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true,revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true,turn_on = false,time = 0.3},
                },
            },
        },
        {--竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},--不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true,turn_on = true,time = 0.3,revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true,revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true,turn_on = false,time = 0.3},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {               
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },              
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "pf_ayin01_attack11_1", is_hit_effect = false, haste = true},
                },   
            },
        },             
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 56},
                },               
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 13},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="ayin_skill"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="ayin_lyzy_sf"},
                },
            },
        },
    },
}

return pf_ayin01_dazhao