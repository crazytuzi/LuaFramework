GuildBuildtypeModel = {
    desc = {
        ID = "#类型ID",
        name = "名称",
        useResource = "建设消耗资源",
        outputContribution = "产出个人贡献",
        outputPoint = "产出科技点",
        outputGuildFund = "产出宗门资金",
        outputResource = "产出资源(佣兵令)",
        pic = "图片"
    },
    key = {"ID"},
    items_count = 3,
    items = {
        [34004001] = {
            ID = 34004001,
            name = "初级建设",
            useResource = "1111,0,20",
            outputContribution = 200,
            outputPoint = 0,
            outputGuildFund = 200,
            outputResource = "",
            pic = "gh_5"
        },
        [34004002] = {
            ID = 34004002,
            name = "中级建设",
            useResource = "1111,0,50",
            outputContribution = 400,
            outputPoint = 100,
            outputGuildFund = 600,
            outputResource = "1605,16050016,1",
            pic = "gh_7"
        },
        [34004003] = {
            ID = 34004003,
            name = "高级建设",
            useResource = "1111,0,200",
            outputContribution = 2000,
            outputPoint = 300,
            outputGuildFund = 1000,
            outputResource = "1605,16050016,3",
            pic = "gh_9"
        }
    }
}