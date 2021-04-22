--斗罗AI：BOSS天青牛蟒
--普通副本
--id 3246  2-4
--[[
半屏聚怪
aoe，加击飞
随机控制：水龙卷
近战爆气  击退周围的敌人
]]
--创建人：庞圣峰
--创建时间：2018-3-22

local npc_boss_tianqingniumang = {    
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    	{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500, first_interval = 0},
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
					OPTIONS = {interval = 180, first_interval=6},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53190},	--顺劈斩
				},
			},
		},
    	{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=8.5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},  	--水泡技能1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=12},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53222},   --水泡技能2
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 15.5},
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
					OPTIONS = {interval = 180, first_interval=16},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53190},	--顺劈斩
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=18},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=23},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53225},--拉人，减速
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=28},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53183},--AOE
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=35},
				},
				{
					CLASS = "action.QAIIsUsingSkill",
					OPTIONS = {reverse_result = true , check_skill_id = 53183},
				}, 
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
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
					OPTIONS = {interval = 180, first_interval=38.5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=43.5},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {distance = 2},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},--水泡1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=47},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
			},
		},
    	{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=52},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53185},--浪花舞蹈
				},
			},
		},
		------------------------------------------浪花舞后的水泡水泡循环------------------------------------
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=59},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},  	--水泡技能1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=63},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 65},
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
					OPTIONS = {interval = 180, first_interval=66.5},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53222},   --水泡技能2
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 69.5},
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
					OPTIONS = {interval = 180, first_interval=72},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 74},
                },
				{
                    CLASS = "action.QAIAcceptHitLog",
                },
			},
		},
		------------------------------------------浪花舞后的水泡水泡循环2------------------------------------
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=76},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},  	--水泡技能1
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 79},
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
					OPTIONS = {interval = 180, first_interval=79.5},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 81.5},
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
					OPTIONS = {interval = 180, first_interval=84},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53222},   --水泡技能2
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 87},
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
					OPTIONS = {interval = 180, first_interval=87.5},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 89.5},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
			},
		},
		------------------------------------------浪花舞后的水泡水泡循环3------------------------------------
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=91},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},  	--水泡技能1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=94},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 96},
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
					OPTIONS = {interval = 180, first_interval=97},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53222},   --水泡技能2
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 100},
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
					OPTIONS = {interval = 180, first_interval=101},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 103},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
			},
		},
		------------------------------------------浪花舞后的水泡水泡循环4------------------------------------
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=104},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},  	--水泡技能1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=107},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 109},
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
					OPTIONS = {interval = 180, first_interval=110},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53222},   --水泡技能2
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 113},
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
					OPTIONS = {interval = 180, first_interval=114},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180,first_interval = 117},
                },
                {
                    CLASS = "action.QAIAcceptHitLog",
                },
			},
		},
		------------------------------------------拉人------------------------------------
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=121},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53225},--拉人，减速
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=126},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53183},--AOE
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 180, first_interval=133},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
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
					OPTIONS = {interval = 180, first_interval=135},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
			},
		},
		------------------------------------------------------------------------
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 15, first_interval=139},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53221},  	--水泡技能1
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 15, first_interval=143},
				},
				{
					CLASS = "action.QAIAttackAnyEnemy",
					OPTIONS = {always = true},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53222},   --水泡技能2
				},
				{
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 15,first_interval = 146},
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
					OPTIONS = {interval = 15, first_interval=147},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53190},	--顺劈斩
				},
			},
		},
		{
			CLASS = "composite.QAISequence",
			ARGS = 
			{
				{
					CLASS = "action.QAITimer",
					OPTIONS = {interval = 15, first_interval=149},
				},
				{
					CLASS = "action.QAIAttackEnemyOutOfDistance",
					OPTIONS = {current_target_excluded = true , distance = 1},
				},
				{
					CLASS = "action.QAIUseSkill",
					OPTIONS = {skill_id = 53220},	--冲锋顺劈斩
				},
			},
		},
		--------------------------------------------------------------------------
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

return npc_boss_tianqingniumang