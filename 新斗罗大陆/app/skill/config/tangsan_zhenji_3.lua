-- 技能 尘心真技剑痕攻击
-- 技能ID 190071
-- 攻击;处在chenxin_jianhen_baoji状态时,该脚本作为给自己加暴击BUFF的技能
--[[
	hero 尘心
	ID:1028 
	psf 2018-11-14
]]--

local tangsan_zhenji_3 = {
	CLASS = "composite.QSBSequence",
	ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tangsan_zhenji_xiao", is_target = true},
                        },
                    },
                },
            },
        },
		{
            CLASS = "action.QSBAttackFinish",
        },
	},
}

return tangsan_zhenji_3

