--这是播放特效的子弹通用
local huliena_boss_yaoyihuhuo = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayAnimation",
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
                    OPTIONS = {start_pos = {x = 50,y = 80}},------第一束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 50,y = 40}},------第二束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 50,y = 100}},------第三束狐火-----
                },
  
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 50,y = 130}},------第四束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 50,y = 50}},------第五束狐火-----
                },

                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x = 50,y = 170}},------第六束狐火-----
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return huliena_boss_yaoyihuhuo
