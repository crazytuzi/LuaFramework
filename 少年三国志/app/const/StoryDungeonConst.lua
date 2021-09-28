local StoryDungeonConst = 
{
    TOUCHTYPE = 
    {
        TYPE_PASSDUNGEON = 1,                          -- 通关副本
        TYPE_KILLMONSTER = 3,                             -- 杀死怪物
        TYPE_FIRSTENTER = 2,                                 -- 首次进入副本
        TYPE_OUTSIDE_FINISH = 4 ,                        --进入战斗后立刻触发
        TYPE_BATTLE_MOVE_FINISH1 = 5,              -- 进入战斗后移动1次再触发
        TYPE_BATTLE_MOVE_FINISH2 = 6,              --进入战斗后移动2次再触发（战斗中）
        TYPE_BATTLE_FIRSTATTACK = 7,                --战斗中某怪物攻击即触发（战斗中）
        TYPE_OUTSIDE_FINISH2 = 8 ,                        --进入战斗第二波人后触发
    },

    STORYTYPE=
    {
        TYPE_DUNGEON = 1,            --主线副本
        TYPE_STORYDUGEON = 2,    -- 名将副本
        TYPE_NEWGUIDE = 3,            -- 新手引导战斗   
    },

    BRANCH = 
    {
        NORMAL = 1,  --名将副本普通模式
        EPIC_WAR = 2,  -- 史诗战役
    }
}


return StoryDungeonConst
