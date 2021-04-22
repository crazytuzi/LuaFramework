-- 技能 BOSS柳二龙火龙爆裂斩
-- 技能ID 50654
-- 掉血触发,前方圆形AOE,顺便上一层boss_test_attack_buff
--[[
	boss 柳二龙 
	ID:3175 力量试炼
	psf 2018-5-31
]]--

local boss_liuerlong_dazhao_st = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
    {
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_test_attack_buff",no_cancel = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3 / 30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "liuerlong_attack11_1" ,is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 53 / 30},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 60 / 30},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.3},
				},
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "boss_liuerlong_dazhao_hongkuang"},
				},
			},
		},
    },
}

return boss_liuerlong_dazhao_st