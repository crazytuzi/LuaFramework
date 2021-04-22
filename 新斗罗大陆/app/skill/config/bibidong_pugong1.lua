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
                    OPTIONS = {delay_frame = 24},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "bibidong_attack01_1", is_hit_effect = false},
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
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent<0.55","target:apply_buff:bibidong_hp_lower_50"},
					}
				},
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 130,y = 105}, effect_id = "bibidong_attack01_2", speed = 1500, hit_effect_id = "bibidong_attack01_3"},
                },
				{
					CLASS = "action.QSBActorStatus",
					OPTIONS = 
					{
					   { "target:hp_percent>0.5","target:remove_buff:bibidong_hp_lower_50"},
					}
				},
            },
        },
    },
}

return bibidong_pugong1

