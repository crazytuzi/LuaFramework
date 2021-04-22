-- 技能 深渊玳瑁普攻
-- 技能ID 53330
-- 单体远程物理攻击
--[[
	深渊玳瑁
	ID:4128
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_shenyuandaimao_pugong = {
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
                    CLASS = "action.QSBHitTarget",
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "huangjindaimao_attack01_1", ]]is_hit_effect = false, haste = true},
				},
            },
        },
		-- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 21},
        --         },
        --         {
		-- 			CLASS = "action.QSBBullet",
		-- 			OPTIONS = {start_pos = {x = 120,y = 45},},
		-- 		},
        --     },
        -- },
    },
}

return shenglt_shenyuandaimao_pugong