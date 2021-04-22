-- 技能 小狒狒强化
-- 技能ID 53281
--[[
	小狒狒 4102
	升灵台
	psf 2020-4-13
]]--

local shenglt_jingff_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11_3"},
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
                    OPTIONS = {delay_frame = 18},
                },
				{
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "shenglt_jingff_debuff", teammate = true, haste = true},
                },
                {
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {buff_id = "shenglt_jingff_qianghua_buff", teammate = true, haste = true},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBActorStatus",
                    OPTIONS = 
                    {
                        { "self:hp>0", "self:decrease_hp:maxHp*2","under_status"},
                    }
                },              
            },
        },
    },
}

return shenglt_jingff_dazhao