-- 技能 牛天真技7删除守护
-- 技能ID 190319
-- 删除ssniutian_zhenji7_buff
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local ssniutian_zhenji7_trigger = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "ssniutian_zhenji7_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return ssniutian_zhenji7_trigger

