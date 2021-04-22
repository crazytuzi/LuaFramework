-- 技能 BOSS唐晨杀戮之剑
-- 技能ID 50817
-- 丢炸弹
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local zudui_boss_tangchen_shaluzhijian = {
    CLASS = "composite.QSBSequence",
    ARGS = {      
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {is_throw = true, from_target = false,hit_duration = -1, 
							speed_power = 0.8, throw_speed = 800, throw_angel = 100, 
							at_position={x = 0, y = -10}},
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
        },       
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zudui_boss_tangchen_shaluzhijian