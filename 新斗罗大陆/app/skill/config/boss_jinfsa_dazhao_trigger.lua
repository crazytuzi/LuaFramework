-- 技能 金发狮獒大招额外攻击
-- 技能ID 35037
-- 额外攻击
--[[
	hunling 金发狮獒
	ID:2006
	psf 2019-6-14
]]--


local HIT_TWICE = {
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_frame = 6},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = { is_hit_effect = true},
				},
			},
		},
		{
			CLASS = "action.QSBDelayTime",
			OPTIONS = {delay_frame = 6},
		},
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
				{
					CLASS = "action.QSBHitTarget",
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = { is_hit_effect = true},
				},
			},
		},
	},
}


local boss_jinfsa_dazhao_trigger = {
	CLASS = "composite.QSBParallel",
	ARGS = {		
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = {animation = "attack11_2"},
		},
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 1, --没有匹配到的话select会置成这个值 默认为2
						{expression = "self:buff_num:boss_jinfsa_pugong_buff=0", select = 1},
						{expression = "self:buff_num:boss_jinfsa_pugong_buff=1", select = 2},
						{expression = "self:buff_num:boss_jinfsa_pugong_buff=2", select = 3},
						{expression = "self:buff_num:boss_jinfsa_pugong_buff>2", select = 4},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBAttackFinish",
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_3"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								HIT_TWICE,
								{
									CLASS = "action.QSBAttackFinish",
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_3"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								HIT_TWICE,HIT_TWICE,
								{
									CLASS = "action.QSBAttackFinish",
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_3"},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "jinfashiao_attack11_1_2", is_hit_effect = false, haste = true},
								},
								HIT_TWICE,HIT_TWICE,HIT_TWICE,
								{
									CLASS = "action.QSBAttackFinish",
								},
								{
									CLASS = "action.QSBPlayAnimation",
									OPTIONS = {animation = "attack11_3"},
								},
							},
						},
					},
				},
			},
		},
	},
}

return boss_jinfsa_dazhao_trigger