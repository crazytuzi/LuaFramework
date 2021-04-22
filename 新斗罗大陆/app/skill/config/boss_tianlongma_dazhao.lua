-- 技能 天龙马大招
-- 技能ID 35051~55
-- 雷霆之怒：召唤审判之雷，攻击单体目标，造成大量伤害，若其他目标身上有静电标记，则审判之雷会传导到目标身上，造成真实伤害（伤害=主目标伤害X%）
-- 并天龙马会吸收掉静电标记，强化自身获得攻击加成以及大招能量（每个标记伤害提升X%，回复15%大招能量）；
--[[
    hunling 天龙马
    ID:2008
    psf 2019-6-14
]]--

local hl_tianlongma_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {--[[effect_id = "tianlongma_attack11_1",]] is_hit_effect = false, haste = true},
		},
		{
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 104},
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
                    OPTIONS = {delay_frame = 73},
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
                        {
                            CLASS = "action.QSBTriggerSkill",
                            OPTIONS = {skill_id = 52127, target_type = "skill_target", wait_finish = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackByBuffNum",
                    OPTIONS = { buff_id = "boss_tianlongma_pugong_debuff",num_pre_stack_count = 1,attackMaxNum = 4, trigger_skill_id = 35073,target_type = "enemy" }
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_tianlongma_pugong_debuff",enemy = true},
                },
            },
        },
    },
}

return hl_tianlongma_dazhao