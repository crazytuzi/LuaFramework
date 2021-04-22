-- 技能 月关 菊花怪死亡

-- 子弹通用,如果目标yueguan_zhenji_debuff,额外一段伤害
--[[
	hero 月关
	ID:1018
	psf 2018-11-14
]]--

local yueguan_juhuaguai_pugong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 45 / 30},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 30/30},
                },
        		{
        			CLASS = "action.QSBBullet",
        			OPTIONS = {flip_follow_y = false,hit_effect_id = "yueguancz_attack01_3",start_pos = {x = -50,y = 50}},
        		},
            },
        },
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:yueguan_zhenji_debuff","trigger_skill:190080"},
			},
		},
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
    },
}

return yueguan_juhuaguai_pugong

