-- 技能 黄金玳瑁普攻
-- 技能ID 30003
-- 单体远程魔法攻击，概率为血量最低的队友施加【玳瑁水盾】。 【玳瑁水盾：能够吸收基于黄金玳瑁攻击力的伤害，最多持续8秒】）
--[[
	hunling 黄金玳瑁
	ID:2003 
	psf 2019-6-10
]]--

local hl_huangjdm_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
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
                    OPTIONS = {delay_frame = 20},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "huangjindaimao_attack01_1", ]]is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
                {
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 120,y = 45},},
				},
				{
					CLASS = "action.QSBArgsConditionSelector",
					OPTIONS = {
						failed_select = 2, --没有匹配到的话select会置成这个值 默认为2
						{expression = "self:random<0.25", select = 1},
					}
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = {
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {lowest_hp_teammate = true, buff_id = "hl_huangjdm_pugong_buff"},
						},
					},
				},
            },
        },
    },
}

return hl_huangjdm_pugong