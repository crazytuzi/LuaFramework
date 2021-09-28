GuildShareRelation = {
    desc = {
        ID = "#唯一标识",
        FAPMin = "共用学员战力最小值",
        FAPMax = "共用学员战力最大值",
        validIncomeTotalTime = "共用有效收入总时长(秒)",
        validIncomeInterval = "共用有效收入最小间隔(秒)",
        validIncomeOnceGold = "共用有效收入单次可获金币"
    },
    key = {"ID"},
    items_count = 1,
    items = {
        [1] = {
            ID = 1,
            FAPMin = 1000,
            FAPMax = 1000000,
            validIncomeTotalTime = 86400,
            validIncomeInterval = 60,
            validIncomeOnceGold = 25
        }
    }
}