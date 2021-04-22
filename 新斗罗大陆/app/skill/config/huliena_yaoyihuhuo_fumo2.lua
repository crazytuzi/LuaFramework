--这是播放特效的子弹通用
local huliena_yaoyihuhuo_fumo2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="huliena_skill"},
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
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
                    OPTIONS = {delay_frame = 50/24*30},
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
                    OPTIONS = {delay_frame = 50/24*30},
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
            CLASS = "action.QSBPlayEffect"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 100,y = 80}},------第一束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 10}},------第二束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 70}},------第三束狐火-----
                },
   
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 100}},------第四束狐火-----
                },
  
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 20}},------第五束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 140}},------第六束狐火-----
                },
   
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 90}},------第7束狐火-----
                },
    
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 100,y = 130}},------第8束狐火-----
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                -- {
                --     CLASS = "action.QSBBullet",
                --     OPTIONS = {target_random = true,start_pos = {x = 180,y = 100}},------第六束狐火-----
                -- },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return huliena_yaoyihuhuo_fumo2
