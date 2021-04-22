-- 技能 宁风致一日力
-- 技能ID 191
-- 参考凤凰马红俊普攻
--[[
    魂师 凤凰马红俊
    ID:1046 
    psf 2019-9-10
]]--

local ssmahongjun_pugong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
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
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 0},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ningfengzhi_attack13_1" ,is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = { start_pos = {x = 125,y = 200},effect_id = "ningfengzhi_attack13_2", speed = 1700, hit_effect_id = "ningfengzhi_attack13_3"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = { start_pos = {x = 125,y = 200},effect_id = "ningfengzhi_attack13_2", speed = 1700, hit_effect_id = "ningfengzhi_attack13_3"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = { start_pos = {x = 125,y = 200},effect_id = "ningfengzhi_attack13_2", speed = 1700, hit_effect_id = "ningfengzhi_attack13_3"},
                },
            },
        },
    },
}

return ssmahongjun_pugong1

