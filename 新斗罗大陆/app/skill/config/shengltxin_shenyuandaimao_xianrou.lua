-- 技能 留下鲜肉
-- 技能ID 53333
--[[
	深渊玳瑁 4128  恐怖玳瑁 4129 
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_shenyuandaimao_xianrou = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBTrap", 
            OPTIONS = {trapId = "shenglt_meat_trap", ignore_dead = true, args = 
            {
                {delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
            },},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_shenyuandaimao_xianrou
