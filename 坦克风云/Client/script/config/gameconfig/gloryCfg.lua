gloryCfg ={ -- 繁荣度相关配置
   glory={ -- 繁荣度等级数量
        [1]={level=0,needGloryExp=5000,troopsUp=0,productAdd=0,versionNeed=60},
        [2]={level=1,needGloryExp=10000,troopsUp=2,productAdd=0.05,versionNeed=60},
        [3]={level=2,needGloryExp=11000,troopsUp=4,productAdd=0.1,versionNeed=60},
        [4]={level=3,needGloryExp=12000,troopsUp=6,productAdd=0.15,versionNeed=60},
        [5]={level=4,needGloryExp=13000,troopsUp=8,productAdd=0.2,versionNeed=60},
        [6]={level=5,needGloryExp=14000,troopsUp=10,productAdd=0.25,versionNeed=60},
        [7]={level=6,needGloryExp=15000,troopsUp=14,productAdd=0.3,versionNeed=60},
        [8]={level=7,needGloryExp=16000,troopsUp=18,productAdd=0.35,versionNeed=60},
        [9]={level=8,needGloryExp=17000,troopsUp=22,productAdd=0.4,versionNeed=60},
        [10]={level=9,needGloryExp=18000,troopsUp=26,productAdd=0.45,versionNeed=60},
        [11]={level=10,needGloryExp=19000,troopsUp=30,productAdd=0.5,versionNeed=60},
        [12]={level=11,needGloryExp=20000,troopsUp=36,productAdd=0.55,versionNeed=60},
        [13]={level=12,needGloryExp=21000,troopsUp=42,productAdd=0.6,versionNeed=60},
        [14]={level=13,needGloryExp=22000,troopsUp=48,productAdd=0.65,versionNeed=60},
        [15]={level=14,needGloryExp=23000,troopsUp=54,productAdd=0.7,versionNeed=60},
        [16]={level=15,needGloryExp=24000,troopsUp=60,productAdd=0.75,versionNeed=60},
        [17]={level=16,needGloryExp=25000,troopsUp=68,productAdd=0.8,versionNeed=60},
        [18]={level=17,needGloryExp=26000,troopsUp=76,productAdd=0.85,versionNeed=60},
        [19]={level=18,needGloryExp=27000,troopsUp=84,productAdd=0.9,versionNeed=60},
        [20]={level=19,needGloryExp=29000,troopsUp=92,productAdd=0.95,versionNeed=60},
        [21]={level=20,needGloryExp=31000,troopsUp=100,productAdd=1,versionNeed=60},
        [22]={level=21,needGloryExp=33000,troopsUp=110,productAdd=1.1,versionNeed=60},
        [23]={level=22,needGloryExp=35000,troopsUp=120,productAdd=1.2,versionNeed=60},
        [24]={level=23,needGloryExp=37500,troopsUp=130,productAdd=1.3,versionNeed=70},
        [25]={level=24,needGloryExp=40000,troopsUp=140,productAdd=1.4,versionNeed=70},
        [26]={level=25,needGloryExp=42500,troopsUp=150,productAdd=1.5,versionNeed=80},
        [27]={level=26,needGloryExp=45000,troopsUp=160,productAdd=1.6,versionNeed=80},
        [28]={level=27,needGloryExp=47500,troopsUp=170,productAdd=1.7,versionNeed=90},
        [29]={level=28,needGloryExp=50000,troopsUp=180,productAdd=1.8,versionNeed=90},
        [30]={level=29,needGloryExp=52500,troopsUp=190,productAdd=1.9,versionNeed=100},
        [31]={level=30,needGloryExp=55000,troopsUp=200,productAdd=2,versionNeed=100},
        [32]={level=31,needGloryExp=57500,troopsUp=210,productAdd=2.1,versionNeed=110},
        [33]={level=32,needGloryExp=60000,troopsUp=220,productAdd=2.2,versionNeed=110},
    },
    destoryGlory={ -- 摧毁状态相关参数
        gemFix=1, --金币修理数额上升
        -- timeFix=-0.5, --时间回复效率减少
        prductAdd=-1, --基础资源产量减少
        atkFix=-0.5, --攻击繁荣获得效率
        removeNeedExp=5000, --解除摧毁所需繁荣
    },
    --时间恢复繁荣度 /每分钟
    timeGetBoom=20, --每分钟回复量
    baseGlory=5000, --基地基础繁荣
     
     
    --  金币回复公式
    -- point * 0.01   (向上取整）
    -- point 为 = 所需回复的繁荣度
     
    --  采集获得点数
    -- (point /  0.05 M)  ^ 0.95  (向上取整）
    -- point 为 = 采集的资源
     
    --  攻击减少点数
    -- (point /   0.5 M)  ^ 0.95  (向上取整）
    -- point 为 = 该部队的最大总载重 - 采集的资源 * 0.5
     
    --  攻击获得点数
    -- (point /   0.5 M)  ^ 0.95  (向上取整）
    -- point 为 = 采集的资源 * 0.5
     
}
