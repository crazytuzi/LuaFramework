﻿local oceanExpedition={
    --onePoint=ΣsingleWinP+singleLoseP+singleByeP
    --个人最终积分=total*onePoint/ΣonePoinnt*(win or Lose)Point
    --报名等级
    levelLimit=40,
    --元帅竞选条件,全服前x人
    marLimit=10,
    --队长竞选条件,全服前x人
    tlLimit=30,
    --队伍申请上限
    ApplyLimit=20,
    --兑换比例
    ratio=25,
    --元帅属性继承
    marAtt=0.6,
    --队长属性继承
    tlAtt=0.3,
    --元帅属性*x倍
    marAdd=3,
    --队长属性*x倍
    tlAdd=1.5,
    --异星固定值转换
    alienValue=2.3,
    --疲劳buff
    fatigueBuff=1,
    --前x分钟不允许布阵
    noLineupTime=5,
    --竞选远帅给的积分
    marChoosePoint=150,
    --竞选队长给的积分
    tlChoosePoint=80,
    --可以多少分钟提前进场(单位s)
    advanceTime=300,
    --队伍数量
    teamNum=6,
    --队长人数
    tlNum=5,
    --队员人数(包含队长)
    tpNum=10,
    --宣传时间
    proTime=1,
    --元帅选拔时间
    marTime=2,
    --队长选拔时间
    tlTime=3,
    --队伍调整
    tpTime=4,
    --比赛时间
    matchTime1=5,
    --比赛时间
    matchTime2=6,
    --比赛时间
    matchTime3=7,
    --领奖时间
    rewardTime=8,
    --24-deffTime每日截止时间
    diffTime=30,
    --比赛时间
    matchTime={{20,0},{20,30}},
    --三个场次总分数(1.3场,2.2场,3.单场)
    total={
        [8]=12000,
        [4]=16000,
        [2]=28000,
    },
    --胜利系数
    winValue=1,
    --失败系数
    loseValue=0.8,
    --单场胜利点数
    singleWinP=50,
    --单场轮空点数
    singleByeP=10,
    --单场失败点数
    singleLoseP=20,
    --队长提成
    tlAddValue=1.2,
    --司令奖励邮件道具
    marMailReward={
        q={
            p={{p4766=1},{p4767=1},{p4769=1},{p4770=1},},
        },
        h={
            props_p4766=1,props_p4767=1,props_p4769=1,props_p4770=1,
        },
    },
    --获胜方司令所属军团增加属性,moveSpeed 行军速度,madeSpeed 生产速度,buildSpeed 建筑速度,studySpeed 科研速度
    winnerBuff={
        moveSpeed=0.1,
        madeSpeed=0.1,
        buildSpeed=0.1,
        studySpeed=0.1,
    },
    --Buff持续时间(单位s)
    winnerBuffTime=604800,
    --胜利方全服奖励(稀土,军舰)
    winSeverReward={
        q={
            u={{gold=10000000},},p={{p988=25},},
        },
        h={
            userinfo_gold=10000000,props_p988=25,
        },
    },
    --胜利方邮件发放等级限制
    mailLevel=40,
    matchList={
        [8]={
            {1,8},{2,7},{3,6},{4,5},
        },
        [4]={
            {1,4},{2,3},
        },
        [2]={
            {1,2},
        },
    },
    serverReward8={
        [1]={rank=1,point=4000},
        [2]={rank=2,point=3000},
        [3]={rank={3,4},point=2000},
        [5]={rank={5,8},point=1200},
    },
    serverReward4={
        [1]={rank=1,point=8000},
        [2]={rank=2,point=6000},
        [3]={rank={3,4},point=3200},
    },
    serverReward2={
        [1]={rank=1,point=12000},
        [2]={rank=2,point=9000},
    },
    --士气值系统
    morale={
        --贡献1多花=x点士气值
        costFlowerMor=6,
        --献花给积分
        costFlowerP=2,
        --献花胜利再给积分向下取整
        costFlowerWinP=0.1,
        --1朵花=x金币
        fowler2Money=1,
        moralereward={
            exp={200,1150,3480,7940,15300,26500,42200,63600,91500,128000,172000,226000,291000,368000,459000,565000,687000,827000,985000,1170000,1370000,1600000,1850000,2120000,2430000,2770000,3140000,3540000,3980000,4460000,4990000,5550000,6160000,6820000,7520000,8280000,9100000,9970000,10900000,11900000,13000000,14100000,15300000,16600000,18000000,19400000,20900000,22500000,24200000,26000000,},
            first={12,24,36,48,60,72,84,96,108,120,132,144,156,168,180,192,204,216,228,240,252,264,276,288,300,312,324,336,348,360,372,384,396,408,420,432,444,456,468,480,492,504,516,528,540,552,564,576,588,600,},
            morAtt={{{"arp",3},{"armor",3}},{{"arp",6},{"armor",6}},{{"arp",9},{"armor",9}},{{"arp",12},{"armor",12}},{{"arp",15},{"armor",15}},{{"arp",18},{"armor",18}},{{"arp",21},{"armor",21}},{{"arp",24},{"armor",24}},{{"arp",27},{"armor",27}},{{"arp",30},{"armor",30}},{{"arp",33},{"armor",33}},{{"arp",36},{"armor",36}},{{"arp",39},{"armor",39}},{{"arp",42},{"armor",42}},{{"arp",45},{"armor",45}},{{"arp",48},{"armor",48}},{{"arp",51},{"armor",51}},{{"arp",54},{"armor",54}},{{"arp",57},{"armor",57}},{{"arp",60},{"armor",60}},{{"arp",63},{"armor",63}},{{"arp",66},{"armor",66}},{{"arp",69},{"armor",69}},{{"arp",72},{"armor",72}},{{"arp",75},{"armor",75}},{{"arp",78},{"armor",78}},{{"arp",81},{"armor",81}},{{"arp",84},{"armor",84}},{{"arp",87},{"armor",87}},{{"arp",90},{"armor",90}},{{"arp",93},{"armor",93}},{{"arp",96},{"armor",96}},{{"arp",99},{"armor",99}},{{"arp",102},{"armor",102}},{{"arp",105},{"armor",105}},{{"arp",108},{"armor",108}},{{"arp",111},{"armor",111}},{{"arp",114},{"armor",114}},{{"arp",117},{"armor",117}},{{"arp",120},{"armor",120}},{{"arp",123},{"armor",123}},{{"arp",126},{"armor",126}},{{"arp",129},{"armor",129}},{{"arp",132},{"armor",132}},{{"arp",135},{"armor",135}},{{"arp",138},{"armor",138}},{{"arp",141},{"armor",141}},{{"arp",144},{"armor",144}},{{"arp",147},{"armor",147}},{{"arp",150},{"armor",150}},},
        },
    },
    --1.环形防御 2.中央突破 3.两翼迂回 4.一字横队 5.一字纵队///dmg 伤害  dmg_reduce 伤害减免
    formation={
        {att={"dmg_reduce"},value={0.1}},{att={"dmg_reduce"},value={0.1}},{att={"dmg_reduce"},value={-0.05}},{att={"dmg"},value={-0.05}},{att={"dmg"},value={0.1}},{att={"dmg"},value={0.1}},
        {att={"dmg"},value={-0.05}},{att={"dmg"},value={0.1}},{att={"dmg_reduce"},value={0.1}},{att={"dmg_reduce"},value={0.1}},{att={"dmg"},value={0.1}},{att={"dmg_reduce"},value={-0.05}},
        {att={"dmg_reduce"},value={0.1}},{att={"dmg"},value={-0.05}},{att={"dmg"},value={0.1}},{att={"dmg"},value={0.1}},{att={"dmg_reduce"},value={0.1}},{att={"dmg_reduce"},value={-0.05}},
        {att={"dmg"},value={-0.05}},{att={"dmg_reduce"},value={0.1}},{att={"dmg_reduce"},value={-0.05}},{att={"dmg"},value={0.1}},{att={"dmg"},value={0.1}},{att={"dmg_reduce"},value={0.1}},
        {att={"dmg"},value={-0.05}},{att={"dmg"},value={0.1}},{att={"dmg_reduce"},value={0.1}},{att={"dmg_reduce"},value={-0.05}},{att={"dmg_reduce"},value={0.1}},{att={"dmg"},value={0.1}},
    },
    --商店配置
    --常规商店
    lowShop ={
        i1={bn=2,p=1151,flash=1,r={p={p4835=1}},sr={props_p4835=1},},
        i2={bn=2,p=719,flash=1,r={p={p4831=1}},sr={props_p4831=1},},
        i3={bn=2,p=652,flash=1,r={p={p4830=1}},sr={props_p4830=1},},
        i4={bn=2,p=878,flash=1,r={p={p4829=1}},sr={props_p4829=1},},
        i5={bn=2,p=810,flash=1,r={p={p4828=1}},sr={props_p4828=1},},
        i6={bn=1,p=450,flash=0,r={p={p4768=1}},sr={props_p4768=1},},
        i7={bn=1,p=10800,flash=0,r={p={p4917=1}},sr={props_p4917=1},},
        i8={bn=10,p=180,flash=0,r={e={p2=2}},sr={accessory_p2=2},},
        i9={bn=50,p=360,flash=0,r={e={p3=20}},sr={accessory_p3=20},},
        i10={bn=50,p=360,flash=0,r={e={p4=1000}},sr={accessory_p4=1000},},
        i11={bn=20,p=2250,flash=0,r={e={p5=5}},sr={accessory_p5=5},},
        i12={bn=20,p=90,flash=0,r={e={p6=1}},sr={accessory_p6=1},},
    },
    --精英商店
    middleShop ={
        i1={bn=10,p=1151,flash=1,r={p={p4835=1}},sr={props_p4835=1},},
        i2={bn=2,p=1170,flash=1,r={p={p4833=1}},sr={props_p4833=1},},
        i3={bn=2,p=1080,flash=1,r={p={p4832=1}},sr={props_p4832=1},},
        i4={bn=1,p=10800,flash=1,r={p={p4917=1}},sr={props_p4917=1},},
        i5={bn=2,p=17550,flash=0,r={p={p4703=1}},sr={props_p4703=1},},
        i6={bn=2,p=17550,flash=0,r={p={p4702=1}},sr={props_p4702=1},},
        i7={bn=2,p=16200,flash=0,r={p={p4701=1}},sr={props_p4701=1},},
        i8={bn=2,p=16200,flash=0,r={p={p4700=1}},sr={props_p4700=1},},
    },
    --元帅商店
    highShop ={
        i1={bn=1,p=34560,flash=1,r={p={p4707=1}},sr={props_p4707=1},},
        i2={bn=1,p=26100,flash=1,r={p={p4705=1}},sr={props_p4705=1},},
        i3={bn=1,p=26100,flash=1,r={p={p4704=1}},sr={props_p4704=1},},
        i4={bn=10,p=10800,flash=1,r={p={p4917=1}},sr={props_p4917=1},},
    },
}
return oceanExpedition
