local equipCfg={
    --系统（建筑）开放所需角色等级
    equipOpenLevel=25,
    
    equipGetNumCfg={{1,5},{1,5}},
    
    equipGetCostCfg={{0,25,26,27,28,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,79,83,87,91,95,99,103,107,111,115,119,123,127,131,135,139,143,147,151,155,159,163,167,171,175,179,183,187,191,195,199,203,207,211,215,219,223,227,231,235,240,245,250,255,260,265,270,275,280,285,290,295,300},{1000,4000,13000,43000,63000,106000,168000,274000,442000,715000,1160000,1870000,3030000,4900000,7930000,12900000,20800000,33600000,54300000,87900000,143000000,230000000,373000000,603000000,975000000}},
    
    --稀土抽取
    r5Cost={1000,6000,30000,120000,360000,576000,1124000,2040000,3800000,7100000,8800000,12800000,17500000,24500000,33900000,47300000,65800000,92000000,128000000,178000000,247000000,344000000,479000000,666000000,927000000},
    
    --钻石抽取
    goldCost={0,25,26,27,28,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,79,83,87,91,95,99,103,107,111,115,119,123,127,131,135,139,143,147,151,155,159,163,167,171,175,179,183,187,191,195,199,203,207,211,215,219,223,227,231,235,240,245,250,255,260,265,270,275,280,285,290,295,300},

    -- 稀土奖池
    r5Pool={
        {100},
        {236,236,236,236,236,236,236,236,236,236,37,37,37,37,38,38,38,38,38,38,1,1,1,1,1,1,1,1,1,1},
        {{"sequip_e1",1},{"sequip_e2",1},{"sequip_e3",1},{"sequip_e4",1},{"sequip_e5",1},{"sequip_e6",1},{"sequip_e11",1},{"sequip_e12",1},{"sequip_e13",1},{"sequip_e14",1},{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1},{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1}},
    },
    
    --金币奖池
    goldPool={
        {100},
        {65,65,65,65,65,65,65,65,65,65,25,25,25,25,25,25,25,25,25,25,10,10,10,10,10,10,10,10,10,10},
        {{"sequip_e1",1},{"sequip_e2",1},{"sequip_e3",1},{"sequip_e4",1},{"sequip_e5",1},{"sequip_e6",1},{"sequip_e11",1},{"sequip_e12",1},{"sequip_e13",1},{"sequip_e14",1},{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1},{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1}},
    },
    
    --金币奖池（首抽）
    goldPoolFirst={
        {100},
        {1,1,1,1,1,1,1,1,1,1},
        {{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1}},
    },
    
    --装备进阶
    upgrade={
        prop={
            [1]={p4003=1},
            [2]={p4004=1},
            [3]={p4005=1},
            [4]={p4006=1},
        },
        pool={
            [2]={
                {100},
                {1,1,1,1,1,1,1,1,1,1},
                {{"sequip_e21",1},{"sequip_e22",1},{"sequip_e23",1},{"sequip_e24",1},{"sequip_e25",1},{"sequip_e26",1},{"sequip_e31",1},{"sequip_e32",1},{"sequip_e33",1},{"sequip_e34",1}},
            },
            
            [3]={
                {100},
                {2,2,2,2,2,1,1,1,1,1},
                {{"sequip_e41",1},{"sequip_e42",1},{"sequip_e43",1},{"sequip_e44",1},{"sequip_e45",1},{"sequip_e51",1},{"sequip_e61",1},{"sequip_e71",1},{"sequip_e81",1},{"sequip_e91",1}},
            },
            
            [4]={
                {100},
                {20,20,20,25,20,17,17,25,25,25},
                {{"sequip_e52",1},{"sequip_e62",1},{"sequip_e72",1},{"sequip_e82",1},{"sequip_e92",1},{"sequip_e101",1},{"sequip_e111",1},{"sequip_e801",1},{"sequip_e812",1},{"sequip_e822",1}},
            },
            
            [5]={
                {100},
                {10,10,10,12,0,0,15,15,15,0},
                {{"sequip_e53",1},{"sequip_e63",1},{"sequip_e73",1},{"sequip_e83",1},{"sequip_e102",1},{"sequip_e112",1},{"sequip_e802",1},{"sequip_e813",1},{"sequip_e823",1},{"sequip_e833",1}},
            },
            
        },

        equipnum=6,--升级消耗 6 个 N阶装备，获得 1个 N+1阶装备
        maxupcolor=5,--最大品阶
        advanceGet=3,--连续合成N次etype=2的超级装备，下次合成必出etype=1的超级装备（从战斗装备池抽取）
        battlePool={
            c4={
                {100},
                {20,20,20,25,20,17,17},
                {{"sequip_e52",1},{"sequip_e62",1},{"sequip_e72",1},{"sequip_e82",1},{"sequip_e92",1},{"sequip_e101",1},{"sequip_e111",1}},
            },
            
            c5={
                {100},
                {10,10,10,12},
                {{"sequip_e53",1},{"sequip_e63",1},{"sequip_e73",1},{"sequip_e83",1}},
            },
        },

    },

}

return equipCfg
