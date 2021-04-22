local boss_fulande_maoyingqijian = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="fulande_walk"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 29},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1750, target_random = true,start_pos = {x = 150, y = 150}},  ------第一颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1500, target_random = true, start_pos = {x = 150, y = 200}},  ------第二颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1500, target_random = true, start_pos = {x = 150, y = 200}},  ------第三颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2}, 
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1500, target_random = true, start_pos = {x = 150, y = 200}},  ------第四颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2}, 
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1500, target_random = true, start_pos = {x = 150, y = 200}},  ------第四颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2}, 
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1500, target_random = true, start_pos = {x = 150, y = 200}},  ------第四颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2}, 
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "fulande_atk11_2", speed = 1500, target_random = true, start_pos = {x = 150, y = 200}},  ------第四颗子弹-----
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}
return boss_fulande_maoyingqijian

