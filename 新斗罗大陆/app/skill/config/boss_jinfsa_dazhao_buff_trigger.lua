-- 技能 金发狮獒大招群体BUFF
-- 技能ID 35038
-- 群体BUFF
--[[
	hunling 金发狮獒
	ID:2006
	psf 2019-6-14
]]--

local boss_jinfsa_dazhao_buff_trigger = {
    CLASS = "composite.QSBParallel",
	ARGS = {		
		-- {
            -- CLASS = "composite.QSBSequence",
            -- ARGS = {
                -- {
                    -- CLASS = "action.QSBPlayAnimation",
					-- OPTIONS = {animation = "attack11_3"},
                -- },
                -- {
                    -- CLASS = "action.QSBAttackFinish",
                -- },
            -- },
        -- },
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 4,
						{expression = "self:buff_num:boss_jinfsa_pugong_buff>1", select = 1},
						{expression = "self:buff_num:boss_jinfsa_pugong_buff>2", select = 2},
						{expression = "self:buff_num:boss_jinfsa_pugong_buff>3", select = 3},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "boss_jinfsa_dazhao_buff;y"},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "jinfashiao_attack11_1_3", is_hit_effect = false, haste = true},
								},
							},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "boss_jinfsa_dazhao_buff;y"},
								},
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {lowest_hp_teammate = true, buff_id = "boss_jinfsa_dazhao_buff;y"},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "jinfashiao_attack11_1_3", is_hit_effect = false, haste = true},
								},
							},
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {teammate_and_self = true, buff_id = "boss_jinfsa_dazhao_buff;y"},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {effect_id = "jinfashiao_attack11_1_3", is_hit_effect = false, haste = true},
								},
							},
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

return boss_jinfsa_dazhao_buff_trigger