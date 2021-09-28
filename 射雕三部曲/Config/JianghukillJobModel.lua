JianghukillJobModel = {
    desc = {
        ID = "#职业ID",
        name = "名字",
        atkR1 = "对豪杰伤害系数",
        atkR2 = "对刺客伤害系数",
        atkR3 = "对书生伤害系数",
        atkR4 = "对镖师伤害系数",
        removeTime = "相邻节点移动耗时/s",
        removeNeed = "移动粮草消耗",
        attr = "属性标识（前端要的）"
    },
    key = {"ID"},
    items_count = 4,
    items = {
        [1] = {
            ID = 1,
            name = "豪杰",
            atkR1 = 0,
            atkR2 = 2000,
            atkR3 = 0,
            atkR4 = 0,
            removeTime = 30,
            removeNeed = 120,
            attr = "spriteRecover|精神恢复,defence|驻守防御"
        },
        [2] = {
            ID = 2,
            name = "刺客",
            atkR1 = 0,
            atkR2 = 0,
            atkR3 = 2000,
            atkR4 = 0,
            removeTime = 30,
            removeNeed = 120,
            attr = "powerRecover|功力恢复时间,attackOdds|突袭触发概率"
        },
        [3] = {
            ID = 3,
            name = "书生",
            atkR1 = 2000,
            atkR2 = 0,
            atkR3 = 0,
            atkR4 = 0,
            removeTime = 30,
            removeNeed = 120,
            attr = "wuXingTimeRecover|悟性恢复时间,lingXi|心有灵犀触发概率"
        },
        [4] = {
            ID = 4,
            name = "镖师",
            atkR1 = 0,
            atkR2 = 0,
            atkR3 = 0,
            atkR4 = 0,
            removeTime = 15,
            removeNeed = 60,
            attr = "foodRecover|粮草恢复"
        }
    }
}