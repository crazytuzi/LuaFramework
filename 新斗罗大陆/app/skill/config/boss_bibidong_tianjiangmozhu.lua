-- 技能 BOSS比比东 天降魔蛛陷阱
-- 技能ID 50835
-- 释放天降魔蛛陷阱
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_tianjiangmozhu = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = true, buff_id = "boss_bibidong_tianjiangmozhu_zhaohuan_debuff"},
		},
		{
			CLASS = "action.QSBMultipleTrap",
			OPTIONS = {trapId = {"boss_bibidong_tianjiangmozhu_trap_circle","boss_bibidong_tianjiangmozhu_trap"},count = 2,distance = 0},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return boss_bibidong_tianjiangmozhu