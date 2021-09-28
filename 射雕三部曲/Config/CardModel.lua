CardModel = {
    desc = {
        ID = "#ID",
        name = "名称",
        price = "出售价格",
        continueTime = "持续时长(天)",
        buyAgainLeftTimeMax = "可再次购买的最大剩余时间(小时)",
        dailyReward = "每日奖励(格式:类型ID,模型ID,数量||…)",
        buyReward = "购买既得奖励",
        weekReward = "特殊奖励(格式:类型ID,模型ID,数量||…)",
        timeInterval = "领取特殊奖励间隔时间",
        totalReward = "总奖励预览",
        totalPrice = "总价值"
    },
    key = {"ID"},
    items_count = 2,
    items = {
        [1] = {
            ID = 1,
            name = "金币周卡",
            price = 30,
            continueTime = 7,
            buyAgainLeftTimeMax = 24,
            dailyReward = "1111,0,150||1605,16050048,150||1116,0,300||1605,16050265,15||1603,16030006,2||1112,0,500000",
            buyReward = "1111,0,120",
            weekReward = "1606,16060450,150",
            timeInterval = 6,
            totalReward = "1111,0,1050||1605,16050048,1050||1116,0,2100||1605,16050265,105||1603,16030006,14||1112,0,3500000||1606,16060450,150",
            totalPrice = 16888
        },
        [2] = {
            ID = 2,
            name = "经验周卡",
            price = 90,
            continueTime = 7,
            buyAgainLeftTimeMax = 24,
            dailyReward = "1111,0,300||1605,16050001,500||1602,16023005,10||1605,16050265,30||1605,16050239,50||1603,16030008,4||1112,0,1500000",
            buyReward = "1111,0,360",
            weekReward = "1606,16060353,100",
            timeInterval = 6,
            totalReward = "1111,0,2100||1605,16050001,3500||1605,16050239,350||1605,16050265,210||1603,16030008,28||1602,16023005,70||1112,0,10500000||1606,16060353,100",
            totalPrice = 22888
        }
    }
}