--六瓣仙兰
--NPC原型 10018
--普攻ID:50306
--治疗兵
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：许成
--创建时间：2017-6-22
--迭代: 庞圣峰 2018-3-21

local npc_liubanxianlan = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1.5, include_self = false, treat_hp_lowest = true},
        },
    },
}
        
return npc_liubanxianlan