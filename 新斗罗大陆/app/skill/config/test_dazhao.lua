local test_dazhao = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
			OPTIONS ={animation = "attack11"}
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {all_enemy = true, buff_id = "test_wuli_jiashen"},
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {all_enemy = true, buff_id = "test_wuli_yishang"},
        },
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {all_enemy = true, buff_id = "test_wuli_jianmian"},
        },
		--[[
		下面这些BUFF排列组合,每个BUFF都可以最高叠加10层,看结果是否符合公式:
		test_wuli_jiashen	物理加深+20%
		test_wuli_yishang	物理易伤+31%
		test_wuli_jianmian	物理减免+43%
		test_mofa_jiashen	魔法加深+20%
		test_mofa_yishang	魔法易伤+21%
		test_mofa_jianmian	魔法减免+23%
		test_pvp_wuli_jiashen	PVP物理加深+7%
		test_pvp_wuli_jianmian	PVP物理减免+10%
		test_pvp_wuli_jianmian_fushu	PVP物理减免-35%
		test_pvp_mofa_jiashen	PVP魔法加深+4%
		test_pvp_mofa_jianmian	PVP魔法减免+10%
		test_pvp_mofa_jianmian_fushu	PVP魔法减免-35%
		--]]
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return test_dazhao
