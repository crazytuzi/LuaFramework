-- 漂浮物配置
local floaterCfg = {
    multiSelectType = true,
    [1]=
    {
        -- 漂浮物拾取上限
        floaterMax = 5,
        -- 用的奖池, 1~5级用1号奖池，6~10级用2号奖池 ...
        level={5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80},
        -- 奖励
        reward =
        {
            [1]={    --1~5 级掉落
                pool={
                    {100},
                    {500,300,100,1800,1800,1800,1800,1800,100},
                    {{"userinfo_gems",1},{"userinfo_gems",2},{"userinfo_gems",5},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},}},
            },
            [2]={    --6~10 级掉落
                pool={
                    {100},
                    {500,300,100,1800,1800,1800,1800,1800,100},
                    {{"userinfo_gems",1},{"userinfo_gems",2},{"userinfo_gems",5},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},}},
            },
            [3]={    --11~15 级掉落
                pool={
                    {100},
                    {500,300,100,1700,1700,1700,1700,1700,100,100,100,100,100,100},
                    {{"userinfo_gems",2},{"userinfo_gems",3},{"userinfo_gems",5},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},}},
            },
            [4]={    --16~20 级掉落
                pool={
                    {100},
                    {500,300,100,1700,1700,1700,1700,1700,100,100,100,100,100,100},
                    {{"userinfo_gems",2},{"userinfo_gems",3},{"userinfo_gems",5},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},}},
            },
            [5]={    --21~25 级掉落
                pool={
                    {100},
                    {500,300,100,1300,1300,1300,1300,1300,300,300,300,300,300,70,150,300,450,30,100},
                    {{"userinfo_gems",3},{"userinfo_gems",5},{"userinfo_gems",10},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [6]={    --26~30 级掉落
                pool={
                    {100},
                    {500,300,100,1300,1300,1300,1300,1300,300,300,300,300,300,70,150,300,450,30,100},
                    {{"userinfo_gems",3},{"userinfo_gems",5},{"userinfo_gems",10},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [7]={    --31~35 级掉落
                pool={
                    {100},
                    {500,300,100,1000,1000,1000,1000,1000,600,600,600,600,600,70,150,300,450,30,100},
                    {{"userinfo_gems",5},{"userinfo_gems",7},{"userinfo_gems",12},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [8]={    --36~40 级掉落
                pool={
                    {100},
                    {500,300,100,1000,1000,1000,1000,1000,600,600,600,600,600,70,150,300,450,30,100},
                    {{"userinfo_gems",5},{"userinfo_gems",7},{"userinfo_gems",12},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [9]={    --41~45 级掉落
                pool={
                    {100},
                    {500,300,100,600,600,600,600,600,1000,1000,1000,1000,1000,70,150,300,450,30,100},
                    {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",15},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [10]={    --46~50 级掉落
                pool={
                    {100},
                    {500,300,100,600,600,600,600,600,1000,1000,1000,1000,1000,70,150,300,450,30,100},
                    {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",15},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [11]={    --51~55 级掉落
                pool={
                    {100},
                    {500,300,100,100,100,100,100,100,1500,1500,1500,1500,1500,70,150,300,450,30,100},
                    {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",20},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [12]={    --56~60 级掉落
                pool={
                    {100},
                    {500,300,100,100,100,100,100,100,1500,1500,1500,1500,1500,70,150,300,450,30,100},
                    {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",20},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},}},
            },
            [13]={    --61~65 级掉落
                pool={
                    {100},
                    {500,300,100,1350,1350,1350,1350,1350,50,50,50,50,50,70,150,300,450,30,250,250,250,250,100},
                    {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",30},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},}},
            },
            [14]={    --66~70 级掉落
                pool={
                    {100},
                    {500,300,100,1350,1350,1350,1350,1350,50,50,50,50,50,70,150,300,450,30,250,250,250,250,100},
                    {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",30},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},}},
            },
            [15]={    --71~75 级掉落
                pool={
                    {100},
                    {500,300,100,1250,1250,1250,1250,1250,150,150,150,150,150,70,150,300,450,30,250,250,250,250,100},
                    {{"userinfo_gems",5},{"userinfo_gems",15},{"userinfo_gems",30},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},}},
            },
            [16]={    --76~80 级掉落
                pool={
                    {100},
                    {500,300,100,1250,1250,1250,1250,1250,150,150,150,150,150,70,150,300,450,30,250,250,250,250,100},
                    {{"userinfo_gems",5},{"userinfo_gems",15},{"userinfo_gems",30},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1},{"props_p275",1},{"props_p276",1},{"props_p277",1},{"props_p281",1},{"props_p279",1},{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},}},
            },
        },
    },
}
return floaterCfg
