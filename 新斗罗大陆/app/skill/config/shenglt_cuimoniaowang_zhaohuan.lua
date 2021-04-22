-- 技能 召唤图腾
-- 技能ID 53312
--[[
	翠魔鸟王
	升灵台
	ID:4121
	psf 2020-4-13
]]--

local shenglt_cuimoniaowang_zhaohuan =  {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = {animation = "attack11_1"},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBTrap", 
                    OPTIONS = 
                    { 
                        trapId = "shenglt_cuimoniaowang_tuteng",
                        args = 
                        {
                            {delay_time = 0 , relative_pos = { x = -50, y = 0}} ,
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

return shenglt_cuimoniaowang_zhaohuan