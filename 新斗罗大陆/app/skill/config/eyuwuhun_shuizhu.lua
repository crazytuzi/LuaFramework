--  创建人：刘悦璘
--  创建时间：2017.09.05
--  NPC：谋士兵
--  类型：攻击
local eyuwuhun_shuizhu = {
    CLASS = "composite.QSBParallel",
    ARGS = {      
        {
            CLASS = "composite.QSBSequence",
            ARGS = {    
                {    
                    CLASS = "action.QSBPlayAnimation", 
                }, 
                {
                    CLASS = "action.QSBAttackFinish",
                },  
                -- {
                --     CLASS = "action.QSBHitTarget",
                -- },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {is_hit_effect = false},
                -- },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },   
                {
                    CLASS = "action.QSBMultipleLaser",
                    OPTIONS = {effect_id = "xiao_tangsan_atk11_2",speed = 6000,  interval_time = 0 , count=2, is_bullet = true},
                }, 
            },
        },      
    },
}

return eyuwuhun_shuizhu