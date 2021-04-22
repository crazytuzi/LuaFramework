-- 技能 比比东普攻1
-- 技能ID 389
-- 顾名思义 物理
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_pugong1 = 
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
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 26},
                },			
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 130,y = 105}, effect_id = "bibidong_attack02_2", speed = 2400, hit_effect_id = "bibidong_attack01_3"},
                },				
            },
        },
    },
}

return bibidong_pugong1

