--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：烈火杏BOSS
--  类型：攻击
local zudui_boss_liehuoxing_yimiaosanpen = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 31},
                -- },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "chihuo_attack01_2", speed = 1500, target_random = true, start_pos = {x = 100, y = 200}},  ------第1颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "chihuo_attack01_2", speed = 1500, target_random = true, start_pos = {x = 100, y = 200}},  ------第2颗子弹-----
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2}, 
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {effect_id = "chihuo_attack01_2", speed = 1500, target_random = true, start_pos = {x = 100, y = 200}},  ------第3颗子弹-----
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
    },
}

return zudui_boss_liehuoxing_yimiaosanpen

