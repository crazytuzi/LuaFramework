ShengyuanwarsBuffModel = {
    desc = {
        Id = "#神符ID",
        name = "名字",
        intro = "描述",
        buffDuration = "buff持续时间/秒",
        refreshNum = "刷新个数",
        getBuffNeedTime = "获取Buff时间需时间/秒",
        refreshTime = "刷新时间/秒",
        outsideSpine = "建筑外buff特效",
        insidePic = "建筑内buff图片",
        aboveMagicPic = "法器上buff图片"
    },
    key = {"Id"},
    items_count = 5,
    items = {
        [1] = {
            Id = 1,
            name = "破灵珠",
            intro = "开始战斗时随机消灭对方1人",
            buffDuration = -1,
            refreshNum = 3,
            getBuffNeedTime = 5,
            refreshTime = 90,
            outsideSpine = "jiutang",
            insidePic = "jzthd_63",
            aboveMagicPic = "jzthd_53"
        },
        [2] = {
            Id = 2,
            name = "赏金神符",
            intro = "直接得到150点积分",
            buffDuration = -1,
            refreshNum = 1,
            getBuffNeedTime = 5,
            refreshTime = 90,
            outsideSpine = "jf",
            insidePic = "",
            aboveMagicPic = ""
        },
        [3] = {
            Id = 3,
            name = "双倍神符",
            intro = "玩家的攻防属性翻倍",
            buffDuration = 90,
            refreshNum = 1,
            getBuffNeedTime = 5,
            refreshTime = 90,
            outsideSpine = "ZL",
            insidePic = "jzthd_62",
            aboveMagicPic = ""
        },
        [4] = {
            Id = 4,
            name = "嗜血神符",
            intro = "击杀获得积分翻倍",
            buffDuration = 90,
            refreshNum = 1,
            getBuffNeedTime = 5,
            refreshTime = 90,
            outsideSpine = "koulou",
            insidePic = "jzthd_61",
            aboveMagicPic = ""
        },
        [5] = {
            Id = 5,
            name = "回复神符",
            intro = "玩家生命回复至满值",
            buffDuration = -1,
            refreshNum = 1,
            getBuffNeedTime = 5,
            refreshTime = 90,
            outsideSpine = "hf",
            insidePic = "",
            aboveMagicPic = ""
        }
    }
}