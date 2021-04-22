
local npc_boss_baihe_10_8 = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=2},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50097},--召唤龙卷风
                        },
						{
							CLASS = "action.QAIAcceptHitLog",
						},
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=5},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50556},--闪现
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
                            OPTIONS = {interval = 80, first_interval=7.5},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50553},--后空翻
                        },
						{
							CLASS = "action.QAIAcceptHitLog",
						},
                    },
				},
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=10},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50556},--闪现
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
                            OPTIONS = {interval = 80, first_interval=13},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50553},--后空翻
                        },
						{
							CLASS = "action.QAIAcceptHitLog",
						},
                    },
				},
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=17},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50556},--闪现
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
                            OPTIONS = {interval = 80, first_interval=20},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50551},--三连击
                        },
                    },
				},
				{
				CLASS = "composite.QAISequence",
				ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 80, first_interval = 21},
						},
						{
							CLASS = "action.QAIAcceptHitLog",
						},
					},
				},
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=24},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50558},--闪现到中间
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=28},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50552},--直线龙卷风1
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=32},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50557},--直线龙卷风2
                        },
                    },
                },
			--	{
            --        CLASS = "composite.QAISequence",
            --        ARGS = 
            --        {
            --            {
            --                CLASS = "action.QAITimer",
            --                OPTIONS = {interval = 80, first_interval=42},
            --            },
            --            {
            --                CLASS = "action.QAIUseSkill",
            --                OPTIONS = {skill_id = 50097},--召唤龙卷风
            --            },
			--			{
			--				CLASS = "action.QAIAcceptHitLog",
			--			},
            --        },
            --    },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=45},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50556},--闪现
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
                            OPTIONS = {interval = 80, first_interval=47.5},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50553},--后空翻
                        },
						{
							CLASS = "action.QAIAcceptHitLog",
						},
                    },
				},
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=50},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50556},--闪现
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
                            OPTIONS = {interval = 80, first_interval=53},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50553},--后空翻
                        },
						{
							CLASS = "action.QAIAcceptHitLog",
						},
                    },
				},
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=57},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50556},--闪现
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
                            OPTIONS = {interval = 80, first_interval=60},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50551},--三连击
                        },
                    },
				},
				{
				CLASS = "composite.QAISequence",
				ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 80, first_interval = 61},
						},
						{
							CLASS = "action.QAIAcceptHitLog",
						},
					},
				},
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=64},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50558},--闪现到中间
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=68},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50552},--直线龙卷风1
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 80, first_interval=72},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50557},--直线龙卷风2
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

return npc_boss_baihe_10_8