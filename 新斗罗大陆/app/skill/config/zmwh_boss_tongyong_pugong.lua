--斗罗SKILL 普攻
--宗门武魂争霸
--id 51337
--通用 马甲
--[[
顾名思义
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_tongyong_pugong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {flip_follow_y = true},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zmwh_boss_tongyong_pugong

