local believerCfgVer={
        --新服开启时开启版本1，开服时间不到84天（四个赛季）的次新服也开启版本1
        --每日赠送（group：1-青铜  2-白银4   3-白银3   4-白银2   5-白银1   6-黄金4   7-黄金3  8-黄金2   9-黄金1   10-白金4   11-白金3   12-白金2   13-白金1   14-王者）
        -- weight,giveNum
        troopsGive={
            {
                {{100,0},6},
            },
            {
                {{100,0},6},
                {{100,0},6},
                {{100,0},6},
            },
            {
                {{100,0},6},
                {{100,0},6},
                {{100,0},6},
            },
            {
                {{55,45},6},
                {{55,45},6},
                {{55,45},6},
            },
            {
                {{55,45},6},
            },
        },
        --【阶位信息】（group：1-青铜  2-白银3   3-白银2   4-白银1   5-黄金3   6-黄金2   7-黄金1   8-白金3   9-白金2   10-白金1   11-王者）--所属段位:stepBelong（1-青铜   2-白银   3-黄金   4-白金   5-王者）积分需求:scoreRequire，是否限制数量:limit，限制数量:numLimit，战胜基础分winScoreBase，留存率系数（留存率=胜利后己方剩余数量/初始数量）:killRateScore，胜利赠送代币:KgoldReward，限制船参战级别:boatLimit(阶段下限(主要用于任务），阶段上限）,seasonBoat(赛季参战级别下限，赛季参战级别上限）
        --赛季参战级别
        seasonBoat={5.5,7.5},
        troopPoolLimit={
            {5.5},
            {6},
            {6.5},
            {7,7.5},
            {7,7.5},
        },
        groupMsg={
            {
                {scoreRequire=0,limit=0,numLimit=-1,winScoreBase=150,killRateScore=50,KgoldReward=50,boatLimit={5.5,5.5},up=true},
            },
            {
                {scoreRequire=1000,limit=0,numLimit=-1,winScoreBase=300,killRateScore=100,KgoldReward=80,boatLimit={6,6},},
                {scoreRequire=2000,limit=0,numLimit=-1,winScoreBase=300,killRateScore=100,KgoldReward=80,boatLimit={6,6},},
                {scoreRequire=3000,limit=0,numLimit=-1,winScoreBase=300,killRateScore=100,KgoldReward=80,boatLimit={6,6},up=true},
            },
            {
                {scoreRequire=6000,limit=0,numLimit=-1,winScoreBase=600,killRateScore=200,KgoldReward=200,boatLimit={6.5,6.5},},
                {scoreRequire=9000,limit=0,numLimit=-1,winScoreBase=600,killRateScore=200,KgoldReward=200,boatLimit={6.5,6.5},},
                {scoreRequire=12000,limit=0,numLimit=-1,winScoreBase=600,killRateScore=200,KgoldReward=200,boatLimit={6.5,6.5},up=true},
            },
            {
                {scoreRequire=18000,limit=1,numLimit=30,winScoreBase=1000,killRateScore=300,KgoldReward=300,boatLimit={7,7.5},},
                {scoreRequire=24000,limit=1,numLimit=25,winScoreBase=1000,killRateScore=300,KgoldReward=300,boatLimit={7,7.5},},
                {scoreRequire=30000,limit=1,numLimit=20,winScoreBase=1000,killRateScore=300,KgoldReward=300,boatLimit={7,7.5},up=true},
            },
            {
                {scoreRequire=40000,limit=1,numLimit=20,winScoreBase=1000,killRateScore=400,KgoldReward=350,boatLimit={7,7.5},final=true},
            },
        },
        --【商店】(openLimit:开启条件。price：代币标价。limitNum:限购,clientItem:前端道具,serverItem:后端道具）（5-王者  4-白金  3-黄金  2-白银  1-青铜）
        raceShop={
            {
                i1={1,200,99,{p={{p393=10,index=5}}},{props_p393=10}},
                i2={1,200,99,{p={{p394=10,index=6}}},{props_p394=10}},
                i3={1,200,99,{p={{p395=10,index=7}}},{props_p395=10}},
                i4={1,200,99,{p={{p396=10,index=8}}},{props_p396=10}},
            },
            {
                i1={1,300,5,{am={{exp=2000,index=3}}},{armor_exp=2000}},
                i2={1,500,3,{p={{p3414=1,index=4}}},{props_p3414=1}},
            },
            {
                i1={1,500,30,{p={{p1359=1,index=1}}},{props_p1359=1}},
                i2={1,500,30,{p={{p1360=1,index=2}}},{props_p1360=1}},
            },
        },
        --【NPC】(出现各组船的概率，各组船贡献的留存率系数）（group：1-青铜  2-白银3   3-白银2   4-白银1   5-黄金3   6-黄金2   7-黄金1   8-白金3   9-白金2   10-白金1   11-王者）
        npc={
            {{100,0},{681,572,452,391,324,270,452}},
            {{100,0},{682,573,453,392,325,271,453}},
            {{100,0},{683,597,485,423,372,322,485}},
            {{60,40},{684,598,486,424,373,323,274}},
            {{40,60},{685,599,487,425,374,324,275}},
        },

}
return believerCfgVer