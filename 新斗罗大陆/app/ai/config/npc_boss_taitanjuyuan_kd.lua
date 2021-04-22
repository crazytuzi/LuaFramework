--斗罗AI：蜘蛛女BOSS(弃用,矿洞怪物改了)
--普通副本
--创建人：psf
--创建时间：2018-4-17
--id 3267  矿洞
--巨石重击\泰坦威压\冲锋

local npc_boss_taitanjuyuan_kd = {         --泰坦巨猿矿洞BOSS
    CLASS = "composite.QAISelector",
    ARGS = 
    {
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval=6},
				},
				{
					CLASS = "action.QAIIsAttacking",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50312},--巨石重击(无红圈)
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval=10},
				},
				{
					CLASS = "action.QAIAttackByHitlog",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50187},--泰坦威压(坐地)
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval=17},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					-- OPTIONS = {distance = 3},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50186},--冲锋
				},
				{
					CLASS = "action.QAIIgnoreHitLog",              --使得ai忽略仇恨列表，锁定攻击当前目标（除非当前目标死了）
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 25, first_interval=17.75},
				},
				{
					CLASS = "action.QAIIsAttacking",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 50184},--巨石重击(蓄力)
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval =25,first_interval=18.5},
				},
				{
					CLASS = "action.QAIAcceptHitLog",
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

return npc_boss_taitanjuyuan_kd