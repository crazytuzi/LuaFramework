KillervalleyShrinkageModel = {
    desc = {
        ID = "#毒圈ID",
        radius = "半径",
        continuedTime = "持续时间/S",
        countdown = "倒计时时间/S",
        hurtRatio = "每秒掉血比例/10000",
        produceBoxNum = "刷新箱子个数",
        produceHeroNum = "刷新将包个数"
    },
    key = {"ID"},
    items_count = 6,
    items = {
        [1] = {
            ID = 1,
            radius = 1500,
            continuedTime = 120,
            countdown = 90,
            hurtRatio = 200,
            produceBoxNum = 10,
            produceHeroNum = 20
        },
        [2] = {
            ID = 2,
            radius = 800,
            continuedTime = 90,
            countdown = 30,
            hurtRatio = 400,
            produceBoxNum = 5,
            produceHeroNum = 10
        },
        [3] = {
            ID = 3,
            radius = 500,
            continuedTime = 70,
            countdown = 30,
            hurtRatio = 800,
            produceBoxNum = 3,
            produceHeroNum = 6
        },
        [4] = {
            ID = 4,
            radius = 200,
            continuedTime = 50,
            countdown = 30,
            hurtRatio = 1200,
            produceBoxNum = 2,
            produceHeroNum = 4
        },
        [5] = {
            ID = 5,
            radius = 100,
            continuedTime = 30,
            countdown = 30,
            hurtRatio = 2000,
            produceBoxNum = 1,
            produceHeroNum = 2
        },
        [6] = {
            ID = 6,
            radius = 0,
            continuedTime = 9999,
            countdown = 0,
            hurtRatio = 2500,
            produceBoxNum = 0,
            produceHeroNum = 0
        }
    }
}