local shifa_tongyong = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
	        -- 播动作特效啥的
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = { animation = "attack11"},
        },



        -- 回血回怒
        {
            CLASS = "action.QSBExpression",
            OPTIONS = { expStr = "hp:call = { self:maxHp }, rage:call = { self:rage * 1+250 }",  },
        },

        -- 移除免死
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "sspbbd_fuhuo_jt5"},
        },
        


        -- 解除无法锁定
        {
            CLASS = "action.QSBSetCannotBeLocked",
            OPTIONS = { isCan = true, isImmuneAoE = false, isImmuneTrap = false },
        },
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "sspbbd_bianshen5", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    }, 
}

return shifa_tongyong