-- 技能 弹射枪
-- 额外弹跳两个目标
--[[
	boss 杨无敌
	ID:3246 副本2-4
	psf 2018-3-22
]]--

local boss_yangwudi_tansheqiang = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {--[[effect_id = "yangwudi_atk11_2_1", ]]jump_effect_id = "yangwudi_atk11_2_1", speed = 1750, jump_info = {jump_number = 2}},
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

return boss_yangwudi_tansheqiang
