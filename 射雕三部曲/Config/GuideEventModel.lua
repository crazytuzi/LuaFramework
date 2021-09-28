GuideEventModel = {
    desc = {
        ID = "#事件ID",
        name = "事件描述",
        eventTypeEnum = "事件类型",
        dialogList = "提示语（直接键入文本）OR后续对话伫列(格式:对话表现模型ID;&,内容;&||对话表现模型ID;&,内容...)",
        twSound = "台湾语音",
        sound = "语音",
        saveHit = "打点"
    },
    key = {"ID"},
    items_count = 227,
    items = {
        [101] = {
            ID = 101,
            name = "新手关卡演示完毕，弹出提示介面，提示玩家前往商城抽奖",
            eventTypeEnum = 2,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10100] = {
            ID = 10100,
            name = "外部对话",
            eventTypeEnum = 3,
            dialogList = "10100",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10200] = {
            ID = 10200,
            name = "箭头指向副本按键（特殊处理直接跳转到副本介面）",
            eventTypeEnum = 1,
            dialogList = "欢迎来到金庸武侠世界，点击开始这段奇幻之旅吧",
            twSound = "xs1_tw.mp3",
            sound = "xs1.mp3",
            saveHit = "40"
        },
        [1020004] = {
            ID = 1020004,
            name = "箭头指向第一章第一个副本节点",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [1020005] = {
            ID = 1020005,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "50"
        },
        [1020001] = {
            ID = 1020001,
            name = "为玩家增加一名英雄",
            eventTypeEnum = 4,
            dialogList = "1201,12012603,1",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [1020003] = {
            ID = 1020003,
            name = "对话结束后，“洪淩波”默认加入队伍，并上阵于2号位。",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10201] = {
            ID = 10201,
            name = "箭头指向第一章第二个副本节点",
            eventTypeEnum = 1,
            dialogList = "点击这里，继续闯荡江湖",
            twSound = "xs2_tw.mp3",
            sound = "xs2.mp3",
            saveHit = ""
        },
        [10212] = {
            ID = 10212,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "60"
        },
        [10211] = {
            ID = 10211,
            name = "箭头指向第一章第三个副本节点",
            eventTypeEnum = 1,
            dialogList = "前面就是终南山了，继续向前吧",
            twSound = "xs3_tw.mp3",
            sound = "xs3.mp3",
            saveHit = ""
        },
        [10202] = {
            ID = 10202,
            name = "箭头指向关闭按键，特殊处理跳转到商城招募介面",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "70"
        },
        [10204] = {
            ID = 10204,
            name = "为玩家添加一个豪侠招募令",
            eventTypeEnum = 4,
            dialogList = "1605,16050003,1",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10205] = {
            ID = 10205,
            name = "箭头指向豪侠招募抽一次按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10206] = {
            ID = 10206,
            name = "箭头指向抽奖介面上阵按键",
            eventTypeEnum = 1,
            dialogList = "真是一个很不错的侠客，快去上阵吧",
            twSound = "xs4_tw.mp3",
            sound = "xs4.mp3",
            saveHit = "80"
        },
        [10207] = {
            ID = 10207,
            name = "箭头指向阵容3号位介面+按键",
            eventTypeEnum = 1,
            dialogList = "点击这里即可将侠客上阵",
            twSound = "xs5_tw.mp3",
            sound = "xs5.mp3",
            saveHit = "90"
        },
        [10208] = {
            ID = 10208,
            name = "箭头指向选择角色上阵介面上阵按键",
            eventTypeEnum = 1,
            dialogList = "点击这里即可完成最后一步操作，是不是很简单？",
            twSound = "xs6_tw.mp3",
            sound = "xs6.mp3",
            saveHit = ""
        },
        [10209] = {
            ID = 10209,
            name = "箭头指向副本按键（特殊处理直接跳转到节点副本介面）",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "100"
        },
        [10213] = {
            ID = 10213,
            name = "箭头指向第一章第四个副本节点",
            eventTypeEnum = 1,
            dialogList = "再往前就是全真教和活死人墓了",
            twSound = "xs7_tw.mp3",
            sound = "xs7.mp3",
            saveHit = ""
        },
        [10214] = {
            ID = 10214,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "110"
        },
        [10215] = {
            ID = 10215,
            name = "箭头指向第一章第五个副本节点",
            eventTypeEnum = 1,
            dialogList = "前面有个鬼鬼祟祟的男子，快去看看他在干什麽？",
            twSound = "xs8_tw.mp3",
            sound = "xs8.mp3",
            saveHit = ""
        },
        [10216] = {
            ID = 10216,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "升级开启，前去给侠客升级吧！",
            twSound = "xs9_tw.mp3",
            sound = "xs9.mp3",
            saveHit = "140"
        },
        [10217] = {
            ID = 10217,
            name = "箭头指向章节返回按键",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = "150"
        },
        [10301] = {
            ID = 10301,
            name = "箭头指向阵容按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "160"
        },
        [10302] = {
            ID = 10302,
            name = "箭头指向培养按键（介面直接跳转升级介面）",
            eventTypeEnum = 1,
            dialogList = "从这里可以进入升级操作介面哟！",
            twSound = "xs11_tw.mp3",
            sound = "xs11.mp3",
            saveHit = "170"
        },
        [10303] = {
            ID = 10303,
            name = "箭头指向升十级按键（升级3号位角色）",
            eventTypeEnum = 1,
            dialogList = "试试升级十次吧！",
            twSound = "xs12_tw.mp3",
            sound = "xs12.mp3",
            saveHit = ""
        },
        [10304] = {
            ID = 10304,
            name = "箭头指向副本按键（特殊处理直接跳转到第二章副本介面）",
            eventTypeEnum = 1,
            dialogList = "恭喜少侠实力大涨，快去副本继续挑战吧",
            twSound = "xs13_tw.mp3",
            sound = "xs13.mp3",
            saveHit = "180"
        },
        [10305] = {
            ID = 10305,
            name = "箭头指向第二章副本第一个副本图示",
            eventTypeEnum = 1,
            dialogList = "继续闯荡江湖吧！",
            twSound = "xs14_tw.mp3",
            sound = "xs14.mp3",
            saveHit = ""
        },
        [1030501] = {
            ID = 1030501,
            name = "外部对话",
            eventTypeEnum = 3,
            dialogList = "1030501",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10306] = {
            ID = 10306,
            name = "箭头指向确定按键（介面直接跳转到阵容介面）",
            eventTypeEnum = 1,
            dialogList = "突破开启了，前去看看吧！",
            twSound = "xs15_tw.mp3",
            sound = "xs15.mp3",
            saveHit = "190"
        },
        [10308] = {
            ID = 10308,
            name = "箭头指向培养按键（默认显示培养主角）",
            eventTypeEnum = 1,
            dialogList = "从这里可以进入突破操作介面哟！",
            twSound = "xs16_tw.mp3",
            sound = "xs16.mp3",
            saveHit = "200"
        },
        [10310] = {
            ID = 10310,
            name = "箭头指向突破按键（默认显示培养主角）",
            eventTypeEnum = 1,
            dialogList = "点击这里即可完成突破！",
            twSound = "xs17_tw.mp3",
            sound = "xs17.mp3",
            saveHit = ""
        },
        [10311] = {
            ID = 10311,
            name = "外部对话",
            eventTypeEnum = 3,
            dialogList = "10311",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10312] = {
            ID = 10312,
            name = "箭头指向副本按键（特殊处理直接跳转到第二章副本介面）",
            eventTypeEnum = 1,
            dialogList = "恭喜少侠武艺大增，快去试试拳脚吧",
            twSound = "xs18_tw.mp3",
            sound = "xs18.mp3",
            saveHit = "210"
        },
        [10313] = {
            ID = 10313,
            name = "箭头指向第二章第二个副本节点",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [104] = {
            ID = 104,
            name = "箭头指向确定按键（点击确定按键后介面自动跳转到队伍介面）",
            eventTypeEnum = 1,
            dialogList = "哇，获得一件装备，前去穿戴吧",
            twSound = "xs19_tw.mp3",
            sound = "xs19.mp3",
            saveHit = "220"
        },
        [10402] = {
            ID = 10402,
            name = "箭头指向一键穿戴按键（默认装备培养主角）",
            eventTypeEnum = 1,
            dialogList = "一键装备可以快速穿戴多件装备，真是太方便啦",
            twSound = "xs20_tw.mp3",
            sound = "xs20.mp3",
            saveHit = ""
        },
        [10404] = {
            ID = 10404,
            name = "箭头指向一键强化按键",
            eventTypeEnum = 1,
            dialogList = "装备强化可是画龙点睛之笔，能让我们的装备发挥最大实力呢！",
            twSound = "xs21_tw.mp3",
            sound = "xs21.mp3",
            saveHit = ""
        },
        [10405] = {
            ID = 10405,
            name = "箭头指向副本按键",
            eventTypeEnum = 1,
            dialogList = "继续和美女师傅闯荡江湖吧！",
            twSound = "xs22_tw.mp3",
            sound = "xs22.mp3",
            saveHit = "230"
        },
        [10406] = {
            ID = 10406,
            name = "箭头指向第二章副本图示",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = "240"
        },
        [10407] = {
            ID = 10407,
            name = "箭头指向第二章第三关图示",
            eventTypeEnum = 1,
            dialogList = "开始挑战吧！",
            twSound = "xs23_tw.mp3",
            sound = "xs23.mp3",
            saveHit = ""
        },
        [104071] = {
            ID = 104071,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "260"
        },
        [10408] = {
            ID = 10408,
            name = "箭头指向第二章第四关图示",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [104081] = {
            ID = 104081,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "270"
        },
        [10409] = {
            ID = 10409,
            name = "箭头指向第二章第五关图示",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [1101] = {
            ID = 1101,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "又有新功能开启啦！",
            twSound = "xs24_tw.mp3",
            sound = "xs24.mp3",
            saveHit = "280"
        },
        [11001] = {
            ID = 11001,
            name = "箭头指向历练按键",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = "290"
        },
        [11002] = {
            ID = 11002,
            name = "箭头指向闯荡江湖按键",
            eventTypeEnum = 1,
            dialogList = "据传曾有江湖少侠在闯荡江湖时获得奇遇从此成为天下第一，快去看看吧！",
            twSound = "xs25_tw.mp3",
            sound = "xs25.mp3",
            saveHit = "300"
        },
        [11003] = {
            ID = 11003,
            name = "箭头指向筛子按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [120] = {
            ID = 120,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "自动推图功能开启了，这可是一个解放双手的贴心功能",
            twSound = "xs28_tw.mp3",
            sound = "xs28.mp3",
            saveHit = ""
        },
        [1201] = {
            ID = 1201,
            name = "箭头指向副本按键",
            eventTypeEnum = 1,
            dialogList = "点击江湖",
            twSound = "xs29_tw.mp3",
            sound = "xs29.mp3",
            saveHit = ""
        },
        [1202] = {
            ID = 1202,
            name = "箭头指向挂机按键",
            eventTypeEnum = 1,
            dialogList = "点击这里即可开始自动推图，减少了大量重复且低效的操作",
            twSound = "xs30_tw.mp3",
            sound = "xs30.mp3",
            saveHit = ""
        },
        [1121] = {
            ID = 1121,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "神兵锻造功能开启啦！",
            twSound = "xs32_tw.mp3",
            sound = "xs32.mp3",
            saveHit = ""
        },
        [112] = {
            ID = 112,
            name = "外部对话（介绍神兵）",
            eventTypeEnum = 3,
            dialogList = "112",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [112021] = {
            ID = 112021,
            name = "为玩家增加一个判官笔图纸",
            eventTypeEnum = 4,
            dialogList = "1503,15032601,1",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11201] = {
            ID = 11201,
            name = "箭头指向队伍按键",
            eventTypeEnum = 1,
            dialogList = "行走江湖没有一件趁手的兵器可不行",
            twSound = "xs33_tw.mp3",
            sound = "xs33.mp3",
            saveHit = ""
        },
        [11202] = {
            ID = 11202,
            name = "箭头指向神兵道具框按键",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [11204] = {
            ID = 11204,
            name = "箭头指向去矿场按键",
            eventTypeEnum = 1,
            dialogList = "锻造需要足够的矿石，快去襄阳城外矿场收集一些吧",
            twSound = "xs35_tw.mp3",
            sound = "xs35.mp3",
            saveHit = ""
        },
        [11206] = {
            ID = 11206,
            name = "箭头指向矿藏图示",
            eventTypeEnum = 1,
            dialogList = "点击此处矿场",
            twSound = "xs36_tw.mp3",
            sound = "xs36.mp3",
            saveHit = ""
        },
        [11207] = {
            ID = 11207,
            name = "箭头指向挖矿介面按钮",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11208] = {
            ID = 11208,
            name = "箭头指向锻造按键",
            eventTypeEnum = 1,
            dialogList = "矿石已经足够，开始进行神兵锻造吧",
            twSound = "xs37_tw.mp3",
            sound = "xs37.mp3",
            saveHit = ""
        },
        [11209] = {
            ID = 11209,
            name = "箭头指向队伍按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [112091] = {
            ID = 112091,
            name = "箭头指向主角神兵图示",
            eventTypeEnum = 1,
            dialogList = "快试试兵器是否趁手！",
            twSound = "xs38_tw.mp3",
            sound = "xs38.mp3",
            saveHit = ""
        },
        [11210] = {
            ID = 11210,
            name = "箭头指向选择按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [1131] = {
            ID = 1131,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "神兵升级功能开启啦！",
            twSound = "xs39_tw.mp3",
            sound = "xs39.mp3",
            saveHit = ""
        },
        [113] = {
            ID = 113,
            name = "箭头指向队伍按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11301] = {
            ID = 11301,
            name = "箭头指向神兵icon图示",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [113011] = {
            ID = 113011,
            name = "为玩家增加2个神兵升级道具",
            eventTypeEnum = 4,
            dialogList = "1401,14010801,2",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11302] = {
            ID = 11302,
            name = "箭头指向强化按键",
            eventTypeEnum = 1,
            dialogList = "点击这里即可进入神兵强化相关介面",
            twSound = "xs40_tw.mp3",
            sound = "xs40.mp3",
            saveHit = ""
        },
        [113021] = {
            ID = 113021,
            name = "箭头指向自动放入按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11303] = {
            ID = 11303,
            name = "箭头指向强化按键",
            eventTypeEnum = 1,
            dialogList = "点击这里即可完成强化操作！同时获得大量属性增益",
            twSound = "xs41_tw.mp3",
            sound = "xs41.mp3",
            saveHit = ""
        },
        [1121011] = {
            ID = 1121011,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "拼酒功能开启了",
            twSound = "xs42_tw.mp3",
            sound = "xs42.mp3",
            saveHit = ""
        },
        [112101] = {
            ID = 112101,
            name = "箭头指向历练按键",
            eventTypeEnum = 1,
            dialogList = "传闻斗酒神僧最近常出没于醉仙楼",
            twSound = "xs43_tw.mp3",
            sound = "xs43.mp3",
            saveHit = ""
        },
        [112102] = {
            ID = 112102,
            name = "箭头指向斗酒神僧按键",
            eventTypeEnum = 1,
            dialogList = "和斗酒神僧拼酒可获得武艺指点",
            twSound = "xs44_tw.mp3",
            sound = "xs44.mp3",
            saveHit = ""
        },
        [112103] = {
            ID = 112103,
            name = "箭头指向拼酒按键",
            eventTypeEnum = 1,
            dialogList = "武艺指点后可获得属性奖励哦",
            twSound = "xs45_tw.mp3",
            sound = "xs45.mp3",
            saveHit = ""
        },
        [1081] = {
            ID = 1081,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "武林谱开启啦！",
            twSound = "xs46_tw.mp3",
            sound = "xs46.mp3",
            saveHit = ""
        },
        [108] = {
            ID = 108,
            name = "箭头指向副本按键",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [10801] = {
            ID = 10801,
            name = "箭头指向精英副本第一关",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [10802] = {
            ID = 10802,
            name = "箭头指向挑战按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10803] = {
            ID = 10803,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10804] = {
            ID = 10804,
            name = "箭头指向首通奖励图示",
            eventTypeEnum = 1,
            dialogList = "我们来看看丰厚的首通奖励吧！",
            twSound = "xs47_tw.mp3",
            sound = "xs47.mp3",
            saveHit = ""
        },
        [108041] = {
            ID = 108041,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "获得了一枚恶徒搜捕令，我们快去行侠仗义吧！",
            twSound = "xs48_tw.mp3",
            sound = "xs48.mp3",
            saveHit = ""
        },
        [113051] = {
            ID = 113051,
            name = "箭头指向挑战按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11305] = {
            ID = 11305,
            name = "箭头指向行侠仗义",
            eventTypeEnum = 1,
            dialogList = "点击行侠仗义",
            twSound = "xs49_tw.mp3",
            sound = "xs49.mp3",
            saveHit = ""
        },
        [11306] = {
            ID = 11306,
            name = "箭头指向搜寻按键",
            eventTypeEnum = 1,
            dialogList = "哼，恶贼，终于找到你了",
            twSound = "xs50_tw.mp3",
            sound = "xs50.mp3",
            saveHit = ""
        },
        [11307] = {
            ID = 11307,
            name = "箭头指向奋力一击按键",
            eventTypeEnum = 1,
            dialogList = "速速击杀此贼",
            twSound = "xs51_tw.mp3",
            sound = "xs51.mp3",
            saveHit = ""
        },
        [113071] = {
            ID = 113071,
            name = "箭头指向继续按键",
            eventTypeEnum = 1,
            dialogList = "奋力一击将在短时间内极大的提升自己的实力，不过你将消耗三次挑战次数",
            twSound = "xs52_tw.mp3",
            sound = "xs52.mp3",
            saveHit = ""
        },
        [116] = {
            ID = 116,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "华山论剑开启了！",
            twSound = "xs53_tw.mp3",
            sound = "xs53.mp3",
            saveHit = ""
        },
        [11601] = {
            ID = 11601,
            name = "箭头指向挑战按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11602] = {
            ID = 11602,
            name = "箭头指向华山论剑图示",
            eventTypeEnum = 1,
            dialogList = "华山论剑可遇到各门派武林豪杰",
            twSound = "xs54_tw.mp3",
            sound = "xs54.mp3",
            saveHit = ""
        },
        [11603] = {
            ID = 11603,
            name = "箭头指向“”玩家",
            eventTypeEnum = 1,
            dialogList = "先和他切磋一下吧",
            twSound = "xs55_tw.mp3",
            sound = "xs55.mp3",
            saveHit = ""
        },
        [11604] = {
            ID = 11604,
            name = "三个箭头分别指向三张牌",
            eventTypeEnum = 1,
            dialogList = "随便选择一个试试运气吧！",
            twSound = "xs56_tw.mp3",
            sound = "xs56.mp3",
            saveHit = ""
        },
        [11605] = {
            ID = 11605,
            name = "箭头指向“确定”按钮",
            eventTypeEnum = 1,
            dialogList = "运气不错，获得了一个很有用的奖励。",
            twSound = "xs57_tw.mp3",
            sound = "xs57.mp3",
            saveHit = ""
        },
        [11607] = {
            ID = 11607,
            name = "箭头指向华山论剑介面兑换图示",
            eventTypeEnum = 1,
            dialogList = "商店可以兑换大量珍贵道具哦",
            twSound = "xs58_tw.mp3",
            sound = "xs58.mp3",
            saveHit = ""
        },
        [11608] = {
            ID = 11608,
            name = "箭头指向商店返回按键",
            eventTypeEnum = 1,
            dialogList = "兑换值现在还太少，等攒到足够数量一定要常来哦",
            twSound = "xs59_tw.mp3",
            sound = "xs59.mp3",
            saveHit = ""
        },
        [801] = {
            ID = 801,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "每日任务开启啦！",
            twSound = "xs60_tw.mp3",
            sound = "xs60.mp3",
            saveHit = ""
        },
        [802] = {
            ID = 802,
            name = "箭头指向箭头指向首页每日任务功能按键",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [803] = {
            ID = 803,
            name = "箭头指向每日任务第一个任务前往/领取按键",
            eventTypeEnum = 1,
            dialogList = "完成每日任务可以获得丰厚奖励哟！",
            twSound = "xs61_tw.mp3",
            sound = "xs61.mp3",
            saveHit = ""
        },
        [1091] = {
            ID = 1091,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "拜师学艺开启啦！",
            twSound = "xs62_tw.mp3",
            sound = "xs62.mp3",
            saveHit = ""
        },
        [10805] = {
            ID = 10805,
            name = "外部对话（介绍拜师学艺）",
            eventTypeEnum = 3,
            dialogList = "10805",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [109] = {
            ID = 109,
            name = "箭头指向历练按键",
            eventTypeEnum = 1,
            dialogList = "点击历练",
            twSound = "xs63_tw.mp3",
            sound = "xs63.mp3",
            saveHit = ""
        },
        [10901] = {
            ID = 10901,
            name = "箭头指向拜师学艺按键",
            eventTypeEnum = 1,
            dialogList = "正所谓技多不压身，多学点技能总是好的",
            twSound = "xs64_tw.mp3",
            sound = "xs64.mp3",
            saveHit = ""
        },
        [10902] = {
            ID = 10902,
            name = "箭头指向拜师按键",
            eventTypeEnum = 1,
            dialogList = "要拜师，必须得有拜师贴",
            twSound = "xs65_tw.mp3",
            sound = "xs65.mp3",
            saveHit = ""
        },
        [10904] = {
            ID = 10904,
            name = "箭头指向送礼按键",
            eventTypeEnum = 1,
            dialogList = "尊师重道，礼物最重要！这可是行走江湖不变的真理呢！",
            twSound = "xs66_tw.mp3",
            sound = "xs66.mp3",
            saveHit = ""
        },
        [901] = {
            ID = 901,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "您收到一封密信，快去看看吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [902] = {
            ID = 902,
            name = "箭头指向卷轴",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [903] = {
            ID = 903,
            name = "箭头指向“点击萤幕继续”",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [904] = {
            ID = 904,
            name = "",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [905] = {
            ID = 905,
            name = "箭头指向首页帮派建筑图示",
            eventTypeEnum = 1,
            dialogList = "哇，帮派开启了！点击这里即可进入帮派！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [1151011] = {
            ID = 1151011,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "比武招亲开启啦！",
            twSound = "xs67_tw.mp3",
            sound = "xs67.mp3",
            saveHit = ""
        },
        [115101] = {
            ID = 115101,
            name = "箭头指向挑战按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [115102] = {
            ID = 115102,
            name = "箭头指向比武招亲图示",
            eventTypeEnum = 1,
            dialogList = "前面有个大户人家在设擂台比武招亲呢，听说他家小姐可是方圆百里有名的大美人呢",
            twSound = "xs68_tw.mp3",
            sound = "xs68.mp3",
            saveHit = ""
        },
        [115103] = {
            ID = 115103,
            name = "箭头指向挑战按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [115104] = {
            ID = 115104,
            name = "箭头指向关闭按钮",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [115105] = {
            ID = 115105,
            name = "箭头指向比武招亲介面商店图示",
            eventTypeEnum = 1,
            dialogList = "庄主家的兵器库里有大量装备，但是需要击败足够多的人才能获得",
            twSound = "xs69_tw.mp3",
            sound = "xs69.mp3",
            saveHit = ""
        },
        [115107] = {
            ID = 115107,
            name = "箭头指向商店返回按键",
            eventTypeEnum = 1,
            dialogList = "快去击败更多的挑战者再来领取吧",
            twSound = "xs70_tw.mp3",
            sound = "xs70.mp3",
            saveHit = ""
        },
        [117] = {
            ID = 117,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "武林大会开启了",
            twSound = "xs71_tw.mp3",
            sound = "xs71.mp3",
            saveHit = ""
        },
        [11701] = {
            ID = 11701,
            name = "箭头指向挑战按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11702] = {
            ID = 11702,
            name = "箭头指向武林大会图示",
            eventTypeEnum = 1,
            dialogList = "据说最近江湖在举行武林大会，我们前去看看吧！",
            twSound = "xs72_tw.mp3",
            sound = "xs72.mp3",
            saveHit = ""
        },
        [11705] = {
            ID = 11705,
            name = "箭头指向挑战序列中间的玩家",
            eventTypeEnum = 1,
            dialogList = "击败挑战者可以提高排名",
            twSound = "xs73_tw.mp3",
            sound = "xs73.mp3",
            saveHit = ""
        },
        [117501] = {
            ID = 117501,
            name = "箭头指向第一张牌",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [117502] = {
            ID = 117502,
            name = "箭头指向确定按钮",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11709] = {
            ID = 11709,
            name = "箭头指向排名兑换",
            eventTypeEnum = 1,
            dialogList = "商店可以兑换大量珍贵道具哦",
            twSound = "xs74_tw.mp3",
            sound = "xs74.mp3",
            saveHit = ""
        },
        [11710] = {
            ID = 11710,
            name = "箭头指向奖励兑换返回按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [115011] = {
            ID = 115011,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "江湖悬赏开启啦！",
            twSound = "xs75_tw.mp3",
            sound = "xs75.mp3",
            saveHit = ""
        },
        [11501] = {
            ID = 11501,
            name = "箭头指向历练按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11502] = {
            ID = 11502,
            name = "箭头指向江湖悬赏按键",
            eventTypeEnum = 1,
            dialogList = "行走江湖，财货不可缺！我们可以通过完成江湖悬赏的任务来获得达量奖励！",
            twSound = "xs76_tw.mp3",
            sound = "xs76.mp3",
            saveHit = ""
        },
        [11503] = {
            ID = 11503,
            name = "箭头指向刷新按键",
            eventTypeEnum = 1,
            dialogList = "刷新可获得难度更高的悬赏任务，但是奖励也更丰厚！",
            twSound = "xs77_tw.mp3",
            sound = "xs77.mp3",
            saveHit = ""
        },
        [11504] = {
            ID = 11504,
            name = "箭头指向悬赏icon",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11505] = {
            ID = 11505,
            name = "箭头指向讨伐按键",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [4001] = {
            ID = 4001,
            name = "（江湖悬赏）箭头指向战斗失败介面的“确定”按钮",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4002] = {
            ID = 4002,
            name = "箭头指向江湖悬赏介面佣兵招募图示",
            eventTypeEnum = 1,
            dialogList = "战斗有些吃力麽？没关系，让强力帮手来帮忙！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4003] = {
            ID = 4003,
            name = "送玩家5个佣兵牌",
            eventTypeEnum = 4,
            dialogList = "1605,16050016,5",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4004] = {
            ID = 4004,
            name = "箭头指向阵容介面+框位置",
            eventTypeEnum = 1,
            dialogList = "点击这里即可进入佣兵招募介面",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4005] = {
            ID = 4005,
            name = "默认选中“神将试用”的页签，箭头指向首个神将右边的招募按钮",
            eventTypeEnum = 1,
            dialogList = "这个人物看起来很厉害，就请他来帮忙吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4006] = {
            ID = 4006,
            name = "箭头指向招募确认介面招募按键",
            eventTypeEnum = 1,
            dialogList = "再厉害的神宠也要上阵才有效果哦~",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4007] = {
            ID = 4007,
            name = "箭头选中人物的位置，并拖动到上阵的5号位，重复表现这一个效果",
            eventTypeEnum = 1,
            dialogList = "快快让他上阵吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4008] = {
            ID = 4008,
            name = "箭头指向我的‘我的阵容’介面的‘确认’按钮",
            eventTypeEnum = 1,
            dialogList = "现在应该实力大涨了，继续战斗吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4009] = {
            ID = 4009,
            name = "箭头指向悬赏令介面",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [4010] = {
            ID = 4010,
            name = "箭头指向“战斗”按钮",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [1191] = {
            ID = 1191,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "蒙古大军再次进攻襄阳城，快去助郭大侠一臂之力",
            twSound = "xs78_tw.mp3",
            sound = "xs78.mp3",
            saveHit = ""
        },
        [119] = {
            ID = 119,
            name = "外部对话（蒙古大军入侵襄阳，襄阳危急万分！）",
            eventTypeEnum = 3,
            dialogList = "119",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11901] = {
            ID = 11901,
            name = "箭头指向历练按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11902] = {
            ID = 11902,
            name = "箭头指向据守襄阳图示",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [11903] = {
            ID = 11903,
            name = "箭头指向襄阳“白虎”图示",
            eventTypeEnum = 1,
            dialogList = "白虎门危急，速速驰援！",
            twSound = "xs79_tw.mp3",
            sound = "xs79.mp3",
            saveHit = ""
        },
        [1190301] = {
            ID = 1190301,
            name = "箭头指向组队挑战按键",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "xs10_tw.mp3",
            sound = "xs10.mp3",
            saveHit = ""
        },
        [1190302] = {
            ID = 1190302,
            name = "箭头指向右边点击邀请按键",
            eventTypeEnum = 1,
            dialogList = "快飞鸽传书通知江湖好友共同镇守襄阳",
            twSound = "xs80_tw.mp3",
            sound = "xs80.mp3",
            saveHit = ""
        },
        [1190303] = {
            ID = 1190303,
            name = "箭头指向自动匹配",
            eventTypeEnum = 1,
            dialogList = "点击这里，可广邀各路英雄豪杰",
            twSound = "xs81_tw.mp3",
            sound = "xs81.mp3",
            saveHit = ""
        },
        [11903031] = {
            ID = 11903031,
            name = "箭头指向开始战斗按键",
            eventTypeEnum = 1,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [1190304] = {
            ID = 1190304,
            name = "箭头指向确定按键",
            eventTypeEnum = 1,
            dialogList = "白虎门危急暂时解除了，我们看看襄阳军备库有什麽物资吧",
            twSound = "xs82_tw.mp3",
            sound = "xs82.mp3",
            saveHit = ""
        },
        [11903041] = {
            ID = 11903041,
            name = "箭头指向内功商店图示",
            eventTypeEnum = 1,
            dialogList = "这里面可兑换各门派内功秘笈哟！",
            twSound = "xs83_tw.mp3",
            sound = "xs83.mp3",
            saveHit = ""
        },
        [3002] = {
            ID = 3002,
            name = "节点1115战斗前触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "120"
        },
        [3003] = {
            ID = 3003,
            name = "节点1115战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "130"
        },
        [3004] = {
            ID = 3004,
            name = "节点1211战斗前触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "330"
        },
        [3005] = {
            ID = 3005,
            name = "节点1213战斗前触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = "250"
        },
        [3006] = {
            ID = 3006,
            name = "节点1215战斗前触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [3007] = {
            ID = 3007,
            name = "节点1217战斗前触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [3008] = {
            ID = 3008,
            name = "节点1217战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [13112] = {
            ID = 13112,
            name = "节点1311战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [13132] = {
            ID = 13132,
            name = "节点1313战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [13152] = {
            ID = 13152,
            name = "节点1315战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [13172] = {
            ID = 13172,
            name = "节点1317战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [13182] = {
            ID = 13182,
            name = "节点1318战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [14112] = {
            ID = 14112,
            name = "节点1411战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [14142] = {
            ID = 14142,
            name = "节点1414战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [14172] = {
            ID = 14172,
            name = "节点1417战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [14191] = {
            ID = 14191,
            name = "节点1419战斗前触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [14192] = {
            ID = 14192,
            name = "节点1419战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [15111] = {
            ID = 15111,
            name = "节点1511战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [15141] = {
            ID = 15141,
            name = "节点1514战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [15171] = {
            ID = 15171,
            name = "节点1517战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [15201] = {
            ID = 15201,
            name = "节点1520战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [16111] = {
            ID = 16111,
            name = "节点1611战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [16141] = {
            ID = 16141,
            name = "节点1614战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [16171] = {
            ID = 16171,
            name = "节点1617战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [16201] = {
            ID = 16201,
            name = "节点1620战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [17111] = {
            ID = 17111,
            name = "节点1711战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [17141] = {
            ID = 17141,
            name = "节点1714战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [17171] = {
            ID = 17171,
            name = "节点1717战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [17201] = {
            ID = 17201,
            name = "节点1720战斗后触发",
            eventTypeEnum = 3,
            dialogList = "",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [401] = {
            ID = 401,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "守卫光明顶开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [402] = {
            ID = 402,
            name = "箭头指向首页挑战图示",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [403] = {
            ID = 403,
            name = "箭头指向挑战介面内守卫光明顶",
            eventTypeEnum = 1,
            dialogList = "守卫光明顶开启了，可以获取大量的外功材料奖励！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [5001] = {
            ID = 5001,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "武林争霸开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [5002] = {
            ID = 5002,
            name = "箭头指向首页挑战图示",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [5003] = {
            ID = 5003,
            name = "箭头指向挑战介面内武林争霸",
            eventTypeEnum = 1,
            dialogList = "武林争霸开启了，可以获取大量的天玉、神兵精魄和神将碎片",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [6001] = {
            ID = 6001,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "决战桃花岛开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [6002] = {
            ID = 6002,
            name = "箭头指向首页挑战图示",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [6003] = {
            ID = 6003,
            name = "箭头指向挑战介面内决战桃花岛",
            eventTypeEnum = 1,
            dialogList = "决战桃花岛开启了，可以获取大量的珍稀道具",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [7001] = {
            ID = 7001,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "经脉开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [7002] = {
            ID = 7002,
            name = "箭头指向队伍按键",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [7003] = {
            ID = 7003,
            name = "箭头指向队伍介面的培养按钮（特殊处理切换到经脉介面）",
            eventTypeEnum = 1,
            dialogList = "打通侠客经脉，将极大的提升侠客实力！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [8001] = {
            ID = 8001,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "八大门派开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [8002] = {
            ID = 8002,
            name = "箭头指向首页的八大门派按钮",
            eventTypeEnum = 1,
            dialogList = "拜入门派，将有机会机会获得绝世武功！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [9001] = {
            ID = 9001,
            name = "箭头指向“点击萤幕继续”",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [9002] = {
            ID = 9002,
            name = "箭头指向“大侠之路”图示",
            eventTypeEnum = 1,
            dialogList = "大侠之路开启了，完成任务领取丰富奖励！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10001] = {
            ID = 10001,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "群侠谱开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10002] = {
            ID = 10002,
            name = "箭头指向“更多”图示",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10003] = {
            ID = 10003,
            name = "箭头指向首页群侠谱图示",
            eventTypeEnum = 1,
            dialogList = "群侠谱开启了，启动群侠谱可解锁侠客立绘，提升侠客实力！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10011] = {
            ID = 10011,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "练气开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10017] = {
            ID = 10017,
            name = "箭头指向首页修炼图示",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10012] = {
            ID = 10012,
            name = "箭头指向首页练气图示",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10013] = {
            ID = 10013,
            name = "箭头指向练气按钮",
            eventTypeEnum = 1,
            dialogList = "点击练气，运功打坐，气运丹田，练出合适的真元！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10014] = {
            ID = 10014,
            name = "箭头指向返回按钮",
            eventTypeEnum = 1,
            dialogList = "练气之余，还需配合丹药淬体，方能修炼绝世神功！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10018] = {
            ID = 10018,
            name = "箭头指向修炼按钮",
            eventTypeEnum = 1,
            dialogList = "点击修炼",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10015] = {
            ID = 10015,
            name = "箭头指向首页炼丹图示",
            eventTypeEnum = 1,
            dialogList = "点击这里，进入炼丹阁，炼制丹药！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10016] = {
            ID = 10016,
            name = "箭头指向规则按钮",
            eventTypeEnum = 1,
            dialogList = "点击炼丹秘笈，学习炼丹手法，成为炼丹圣手！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10021] = {
            ID = 10021,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "侠影戏开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10022] = {
            ID = 10022,
            name = "箭头指向更多",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10023] = {
            ID = 10023,
            name = "箭头指向侠影戏",
            eventTypeEnum = 1,
            dialogList = "点击侠影戏，观看侠影戏，可领取丰厚奖励！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10031] = {
            ID = 10031,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 1,
            dialogList = "绝情谷开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10032] = {
            ID = 10032,
            name = "箭头指向首页挑战图示",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10033] = {
            ID = 10033,
            name = "箭头指向挑战介面绝情谷",
            eventTypeEnum = 1,
            dialogList = "开始准备挑战绝情谷吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10034] = {
            ID = 10034,
            name = "箭头指向规则按钮",
            eventTypeEnum = 1,
            dialogList = "情谷中危机四伏，查看规则，才能取得胜利!",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10041] = {
            ID = 10041,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "名望开启了",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10042] = {
            ID = 10042,
            name = "箭头指向更多",
            eventTypeEnum = 1,
            dialogList = "点击这里！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10043] = {
            ID = 10043,
            name = "箭头指向名望",
            eventTypeEnum = 1,
            dialogList = "点击名望，启动名望，让你在江湖之中无人不知，无人不晓！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10051] = {
            ID = 10051,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "江湖杀开启了！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10052] = {
            ID = 10052,
            name = "箭头指向首页江湖杀图示",
            eventTypeEnum = 1,
            dialogList = "点击这里，前往各大门派，争夺天机残页，扬名江湖！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10061] = {
            ID = 10061,
            name = "箭头指向升级介面，点击升级介面后介面跳转到首页",
            eventTypeEnum = 2,
            dialogList = "哇，发现了一只珍兽，快去看看吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10062] = {
            ID = 10062,
            name = "送玩家1只珍兽阿黄",
            eventTypeEnum = 4,
            dialogList = "2101,21010001,1",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10063] = {
            ID = 10063,
            name = "箭头指向首页珍兽图示",
            eventTypeEnum = 1,
            dialogList = "点击这里",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10064] = {
            ID = 10064,
            name = "箭头指向加号",
            eventTypeEnum = 1,
            dialogList = "点击这里，查看已有的珍兽",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10065] = {
            ID = 10065,
            name = "箭头指向选择按钮",
            eventTypeEnum = 1,
            dialogList = "点击这里，上阵珍兽",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10066] = {
            ID = 10066,
            name = "箭头指向首页图示",
            eventTypeEnum = 1,
            dialogList = "珍兽上阵成功，为全体侠客提供了属性加成，让我们去获取更多珍兽吧！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10067] = {
            ID = 10067,
            name = "箭头指向首页修炼图示",
            eventTypeEnum = 1,
            dialogList = "点击修炼",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10068] = {
            ID = 10068,
            name = "箭头指向珍兽塔图示",
            eventTypeEnum = 1,
            dialogList = "听闻珍兽塔里关着许多奇珍异兽，快去看看！",
            twSound = "",
            sound = "",
            saveHit = ""
        },
        [10069] = {
            ID = 10069,
            name = "箭头指向关卡人物形象",
            eventTypeEnum = 1,
            dialogList = "点击挑战守卫，通关层数越高奖励越丰厚哦！",
            twSound = "",
            sound = "",
            saveHit = ""
        }
    }
}