-- 技能 比比东支配死亡群体攻击
-- 技能ID 403
-- 群体攻击
--[[
	魂师 比比东
	ID:1026 
	psf 2019-7-8
]]--

local bibidong_beidong2_trigger2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "bibidong_beidong2_2", is_hit_effect = false},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },
                {
					CLASS = "action.QSBHitTarget",
				},
            },
        },
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return bibidong_beidong2_trigger2

