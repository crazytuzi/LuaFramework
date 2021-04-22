
local zudui_baihe = {
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
                            OPTIONS = {skill_id = 52134},
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
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 45, first_interval=5},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51701},--闪现
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
                            OPTIONS = {interval = 45, first_interval=7.5},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51698},--后空翻
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
                            OPTIONS = {interval = 45, first_interval=10},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51701},--闪现
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
                            OPTIONS = {interval = 45, first_interval=13},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51698},--后空翻
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
                            OPTIONS = {interval = 45, first_interval=17},
                        },
                        {
							CLASS = "action.QAIAttackEnemyOutOfDistance",
							OPTIONS = {always = true},
						},
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51701},--闪现
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
                            OPTIONS = {interval = 45, first_interval=20},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51696},--三连击
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
                            OPTIONS = {interval = 45, first_interval=28},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51703},--闪现到中间
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 45, first_interval=32},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51697},--直线龙卷风1
                        },
                    },
                },
				{
                    CLASS = "composite.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 45, first_interval=40},
                        },
                        {
                            CLASS = "action.QAIAttackByHitlog",
                            OPTIONS = {always = true},
                        },
                        {
                            CLASS = "action.QAIUseSkill",
                            OPTIONS = {skill_id = 51702},--直线龙卷风2
                        },
                    },
                },
			--	
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

return zudui_baihe