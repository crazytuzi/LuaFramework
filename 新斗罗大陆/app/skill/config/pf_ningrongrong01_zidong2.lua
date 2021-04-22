-- 技能 宁荣荣 九宝有名
-- 技能ID 303
-- 单体加BUFF
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--

local ningrongrong_zidong2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return ningrongrong_zidong2
