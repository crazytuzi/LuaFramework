-- 技能 群体普攻
-- 同时向多人发射弹道，加点震动
--[[
	boss 地穴魔蛛
	ID:3022 副本3-12
	psf 2018-1-22
]]--

local boss_dixuemozhu_pugong = {
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
							OPTIONS = {shake = {amplitude = 6, duration = 0.17, count = 1},}
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

return boss_dixuemozhu_pugong

