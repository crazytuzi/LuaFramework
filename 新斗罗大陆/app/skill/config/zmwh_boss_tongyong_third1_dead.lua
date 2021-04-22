--斗罗SKILL 禁锢牢笼死亡
--宗门武魂争霸
--id 51370
--通用 牢笼
--[[
死亡，解锁
]]--
--创建人：庞圣峰
--创建时间：2019-1-3

local zmwh_boss_tongyong_third1_dead = 
{
     CLASS = "composite.QSBParallel",
     ARGS = 
     {
		{
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "zmwh_boss_qiwuhun_third1_debuff", multiple_target_with_skill = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}
return zmwh_boss_tongyong_third1_dead