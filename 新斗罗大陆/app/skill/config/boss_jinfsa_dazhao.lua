-- 技能 金发狮獒大招
-- 技能ID 35036
-- 鏖战到底：大幅度提升自身攻击，并且快速攻击敌人6次，
-- 随后怒吼一声,消耗所有BUFF,每层对敌方造成一次伤害,若消耗4层BUFF,会给全队增加一个“雄霸一方”状态，提升伤害/治疗量的buff
--[[
	hunling 金发狮獒
	ID:2006
	psf 2019-6-14
]]--



local hl_jinfsa_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack11_1"},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 11},
                },
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "jinfashiao_attack11_1_1", is_hit_effect = false, haste = true},
				},  
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
				{
                    CLASS = "composite.QSBParallel",
                    ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {effect_id = "jinfashiao_attack01_1_1", is_hit_effect = false, haste = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
                    },
                },  
            },
        },
		{
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 27},
						},
						{
							CLASS = "action.QSBTriggerSkill",
							OPTIONS = {skill_id = 52120, target_type = "skill_target", wait_finish = true},
						},
						{
							CLASS = "action.QSBTriggerSkill",
							OPTIONS = {skill_id = 52121, target_type = "skill_target", wait_finish = true},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "boss_jinfsa_pugong_buff",remove_all_same_buff_id = true},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
            },
        },
    },
}

return hl_jinfsa_dazhao