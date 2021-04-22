-- 技能 留下腐肉
-- 技能ID 53337
--[[
	腐肉鳄鱼 4130 
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_furoueyu_furou = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBTrap", 
            OPTIONS = {trapId = "shenglt_carrion_trap", ignore_dead = true, args = 
            {
                {delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
            },},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_furoueyu_furou
