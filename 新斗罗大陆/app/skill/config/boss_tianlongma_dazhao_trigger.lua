-- 技能 天龙马大招触发闪电
-- 技能ID 30056~60
-- 叉状闪电
--[[
	hunling 天龙马
	ID:2008
	psf 2019-6-14
]]--

local hl_tianlongma_dazhao_trigger = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			CLASS = "action.QSBLaserWithEnemyStatus",
			OPTIONS = {effect_id = "tianlongma_attack11_2",attack_dummy = "dummy_center",  sort_layer_with_pos = true, --层级取目标
			enemy_status = "hl_static", hit_effect_id = "tianlongma_attack01_3",effect_width = 430,move_time = 0.1,duration = 0.2},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return hl_tianlongma_dazhao_trigger