--斗罗AI：BOSS独孤雁
--普通副本
--id 3252  3-16
--[[
召唤白板曼陀罗蛇
曼陀罗蛇平时攻击t。独孤演命令小蛇瞄准后排，标记特效
召唤曼陀罗蛇 和六瓣仙兰
吟唱buff技能，增加队友攻速,免疫打断
毒圈
]]
--创建人：庞圣峰
--创建时间：2018-3-24

local npc_boss_duguyan = {
	CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval = 0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50098},  --免疫冲锋
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval =12 },
                },
				-- {
    --                 CLASS = "action.QAIAttackAnyEnemy",
    --                 OPTIONS = {always = true},
    --             },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {distance = 5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50317 },--集火指令
                },

            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval =15 },
                },
				{
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50319 },--毒圈
                },
				-- {
					-- CLASS = "action.QAITreatTeammate",
					-- OPTIONS = {hp_below = 1.5, include_self = false, treat_hp_lowest = true},
				-- },

            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval =5 },
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50320 },--召唤-1 白板曼陀罗蛇
                },
				-- {
					-- CLASS = "action.QAITreatTeammate",
					-- OPTIONS = {hp_below = 1.5, include_self = false, treat_hp_lowest = true},
				-- },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 25,first_interval =23 },
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50321 },--召唤-2 曼陀罗蛇 六瓣仙兰
                },
            },
        },	
		{
            CLASS = "action.QAIAttackByHitlog",
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    },
}
        
return npc_boss_duguyan