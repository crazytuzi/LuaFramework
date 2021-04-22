

local zudui_mantuoluoshe= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		
        {   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 3 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51780},          --毒蛇冲刺
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 7 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51780},          --毒蛇冲刺
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 12 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51782},          --毒蛇冲刺
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 20 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51780},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 25 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51780},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 30 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51782},          --毒液
                },
            },
        },
        {   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 38 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51783},          --毒液
                },
            },
        },	
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 42 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51783},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 46 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51783},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 50 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51782},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 65,first_interval= 60 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51784},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 67 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51783},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 72 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51780},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 76 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51782},          --毒液
                },
            },
        },
		{   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 83 },
                },
				{
                     CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51784},          --毒液
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
    }
}
        
return zudui_mantuoluoshe