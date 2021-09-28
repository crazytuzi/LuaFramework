ShizhuangBuffModel = {
    desc = {
        buffID = "#BUFFID",
        duration = "持续时间",
        CD = "间隔时间(CD)",
        distance = "有效距离",
        target = "目标类型(0:无,1:自身,2:单体,3:敌方全体,4:己方全体)",
        buffFireType = "buff释放类型(0:被动,1:主动)",
        buffEffectType = "buff效果类型",
        changeValue = "改变值",
        isDebuff = "是否debuff(0:否,1:是)",
        secondBuffID = "二级BUFFID",
        useRange = "使用范围(0:城外,1:城中,2:皆可使用)"
    },
    key = {"buffID"},
    items_count = 2,
    items = {
        [11001001] = {
            buffID = 11001001,
            duration = 10,
            CD = 30,
            distance = 0,
            target = 1,
            buffFireType = 1,
            buffEffectType = 11,
            changeValue = 5,
            isDebuff = false,
            secondBuffID = 0,
            useRange = 0
        },
        [11001002] = {
            buffID = 11001002,
            duration = 10,
            CD = 30,
            distance = 0,
            target = 4,
            buffFireType = 1,
            buffEffectType = 11,
            changeValue = 5,
            isDebuff = false,
            secondBuffID = 0,
            useRange = 0
        }
    }
}