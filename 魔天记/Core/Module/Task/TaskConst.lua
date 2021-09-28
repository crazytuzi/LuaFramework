TaskConst = {};

TaskConst.Type = {
    MAIN = 1;                   --主线任务
    DAILY = 2;                  --日常循环任务
    REWARD = 3;                 --悬赏任务
    GUILD = 4;                  --仙盟任务
    BRANCH = 5;                 --分支任务
};

TaskConst.Status = {
    UNACCEPTABLE = 0;                   --未接取
    IMPLEMENTATION = 1;                 --进行中
    FINISH = 2;                         --已完成
    --ACCEPTABLE  = 3;                    --可接取
};
   
TaskConst.Target = {
    TALK = 1;               --对话(触发)
    FIND = 2;               --找人(触发)
    KILL = 3;               --杀怪
    COLLECT = 4;            --采集(触发)
    --EXPRESS = 5;            --运送物品(触发)
    DROP = 6;               --掉落
    USE_ITEM = 7;           --使用物品(触发)
    EXPLORE = 8;            --探索区域(触发)
    MONSTER = 9;            --刷怪
    ESCORT = 10;            --护送(触发)
    INSTANCE_CLEAR = 11;    --通关副本
    LV = 12;                --等级要求
    QUESTION = 13;          --答题
    COLLECT_ITEM = 14;      --收集道具.
    VEHICLE = 15;           --载具(触发).
    VKILL = 16;             --载具杀怪
    VACTION = 17;           --载具动作

    GUIDE_AUTOFIGHT = 18;   --引导药物设置
    GUIDE_PET = 19;         --引导伙伴出战
    GUIDE_EQUIP_QH = 20;    --引导装备强化
    GUIDE_SKILL_UP = 21;    --引导技能升级

    --分支
    B_TRUMP_REFINE = 22;            --法宝精炼.
    B_PET_UPGRADE = 23;             --伙伴升级
    B_DAILY_TASK = 24;              --循环任务
    B_ZONGMEN_LILIAN = 25;          --宗门历练
    B_GUILD_JOIN = 26;              --加入仙盟
    B_EQUIP_REFINE = 27;            --装备精炼
    B_EQUIP_GEM = 28;               --装备镶嵌宝石
    B_REALM_UPGRADE = 29;           --境界提升
    B_PET_FORMATION = 30;           --宠物上阵
    B_WINGS_UPGRADE = 31;           --翅膀升级
    B_REALM_COMPACT = 32;           --境界凝练
    B_PET_RANDAPTITUDE = 33;        --伙伴洗脸
    B_XLT = 34;                     --虚灵塔
    B_AUTOFIGHT_SETDRUG = 35;       --设置战斗药品
    B_GOTO_INSTANCE = 36;           --前往副本(竞技场)
    B_MINGXING_EMBED = 37;          --镶嵌命星
    B_WILDBOSS = 39;                --古魔来袭
    B_EQUIP_NEW_QH = 59;            --新装备强化
    B_ENDLESS_EXP = 60;             --无尽试炼任务
};

TaskConst.OType = {
    NONE = 0;
    DIALOG = 1;             --进行对话

    MOVE_TO_NPC = 10;               --寻找NPC
    MOVE_TO_PLACE = 11;             --寻路
    KILL_MONSTER = 12;              --杀怪
    ACTION = 13;                    --执行任务动作

}

