
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
                            OPTIONS = {interval = 500, first_interval = 1},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 50099},
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 100, first_interval=2},
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
                            OPTIONS = {interval = 100, first_interval=5},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51020},--闪现
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
                            OPTIONS = {interval = 100, first_interval=7.5},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51017},--后空翻
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
                            OPTIONS = {interval = 100, first_interval=10},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51020},--闪现
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
                            OPTIONS = {interval = 100, first_interval=13},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51017},--后空翻
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
                            OPTIONS = {interval = 100, first_interval=17},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51020},--闪现
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
                            OPTIONS = {interval = 100, first_interval=20},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51015},--三连击
                        },
                    },
				},
				{
				CLASS = "composite.QAISequence",
				ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 100, first_interval = 21},
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
                            OPTIONS = {interval = 100, first_interval=24},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51022},--闪现到中间
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 100, first_interval=28},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51016},--直线龙卷风1
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 100, first_interval=40},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51021},--直线龙卷风2
                        },
                    },
                },
			--	{
            --        CLASS = "composite.QAISequence",
            --        ARGS = 
            --        {
            --            {
            --                CLASS = "action.QAITimer",
            --                OPTIONS = {interval = 100, first_interval=42},
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
                            OPTIONS = {interval = 100, first_interval=57},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51020},--闪现
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
                            OPTIONS = {interval = 100, first_interval=59.5},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51017},--后空翻
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
                            OPTIONS = {interval = 100, first_interval=62},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51020},--闪现
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
                            OPTIONS = {interval = 100, first_interval=65},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51017},--后空翻
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
                            OPTIONS = {interval = 100, first_interval=69},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51020},--闪现
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
                            OPTIONS = {interval = 100, first_interval=72},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51015},--三连击
                        },
                    },
				},
				{
				CLASS = "composite.QAISequence",
				ARGS = 
					{
						{
							CLASS = "action.QAITimer",
							OPTIONS = {interval = 100, first_interval = 73},
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
                            OPTIONS = {interval = 100, first_interval=76},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51022},--闪现到中间
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 100, first_interval=100},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51016},--直线龙卷风1
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 100, first_interval=92},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51021},--直线龙卷风2
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