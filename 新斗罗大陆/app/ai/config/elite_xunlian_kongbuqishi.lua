local elite_npc_boss_kongbuqishi = {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 52134},          --免疫冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 500,first_interval=0},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53071},          --陷阱
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 3},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 9},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 10.5},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53069}, -- 连刺
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 13.5},
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
                    OPTIONS = {interval = 135,first_interval = 15},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53072}, -- 加BUFF
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 21},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 26},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 28},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53070}, -- 连刺AOE
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 30},
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
                    OPTIONS = {interval = 135,first_interval = 33},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53088}, -- 群体冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 39},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 45},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        }, 
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 51},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53072}, -- 加BUFF
                },
            },
        },  
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 56},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },    
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 58},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53070}, -- 连刺AOE
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 61},
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
                    OPTIONS = {interval = 135,first_interval = 63},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },  
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 68},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 71},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53069}, -- 连刺
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 75},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },       
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 77},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53069}, -- 连刺
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 81},
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
                    OPTIONS = {interval = 135,first_interval = 83},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53088}, -- 群体冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 90},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53072}, -- 加BUFF+召唤
                },
            },
        },  
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 97},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 102},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53068}, -- 冲锋
                },
                {
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 104},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53069}, -- 连刺
                },
            },
        },  
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 108},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 113},
                },
                {
                    CLASS = "action.QAIAttackEnemyOutOfDistance",
                    OPTIONS = {current_target_excluded = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53067}, -- 蓄力冲撞
                },
            },
        },  
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 118},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53088}, -- 群体冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 125},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53088}, -- 群体冲锋
                },
            },
        },
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 135,first_interval = 132},
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 53088}, -- 群体冲锋
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
        
return elite_npc_boss_kongbuqishi