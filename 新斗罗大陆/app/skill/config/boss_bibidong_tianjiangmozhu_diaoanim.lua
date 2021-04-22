-- 技能 BOSS比比东 天降魔蛛叼起来
-- 技能ID 50840
-- 播叼起来动画, 然后自杀
--[[
	boss 比比东 
	ID:3681 副本14-16
	psf 2018-7-5
]]--

local boss_bibidong_tianjiangmozhu_diaoanim = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_shanghai"},
		},
		{
			CLASS = "action.QSBPlayAnimation",
			OPTIONS = { animation = "attack13_1",is_loop = true }
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 2},
				},
				{
					CLASS = "action.QSBPlayAnimation",
					OPTIONS = { animation = "attack13" }
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 3.2},
				},
				{
					CLASS = "action.QSBSuicide",
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_bibidong_tianjiangmozhu_diaoanim	