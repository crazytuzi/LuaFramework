skyladderCfg=
{
    -- ÌìÌÝ°ñ°üº¬µÄÈüÊÂÀàÐÍid
    projectsIncluded = {
        ['1']='person',['2']='alliance',['3']='person',['5']='alliance'
    },
    noShow = {
        default = {},
        efun_tw = {},
    },

    -- ÌìÌÝ°ñÅÅÃûÐèÒªÒÀ¾ÝµÄ»ý·Ö×Ö¶Î
    personCountField = {point1=1,point2=2,point3=3,point4=5},
    ptypeField = {["1"]='point1',["2"]='point2',["3"]='point3',["5"]='point4'},
    allianceCountField = {point1=1,point2=2,point3=3,point4=5},

    -- ¸öÈË¿ç·þÕ½Ê¤Àû¸ø¾üÍÅÔö¼Ó»ý·Ö
    personToAlliancePoint = 0,

    -- ¾üÍÅ¿ç·þÕ½Ê¤Àû¸øÍÅÔ±Ôö¼Ó»ý·Ö
    allianceToPersonPoint = 5,

    -- ÂÖ¿Õ¸ø·Ö
    emptyBattle = 5,

    -- ¸÷Ïî´óÕ½ÅÅÃû·Ö
    battleRankScore = {
        -- ¸öÈË¿ç·þ
        b1 = {
            {range = {1,1},point = 20},
            {range = {2,2},point = 15},
            {range = {3,4},point = 12},
            {range = {5,8},point = 10},
        },
        -- ¾üÍÅ¿ç·þ
        b2 = {
            {range = {1,1},point = 120},
            {range = {2,2},point = 80},
            {range = {3,4},point = 50},
        },
        b3 = {
            -- ÊÀ½çÕù°Ô£¨¾«Ó¢£©
            {
                {range = {1,1},point = 18},
                {range = {2,2},point = 14},
                {range = {3,4},point = 12},
                {range = {5,8},point = 10},
                {range = {9,16},point = 8},
                {range = {17,32},point = 7},
            },
            -- ÊÀ½çÕù°Ô£¨´óÊ¦£©
            {
                {range = {1,1},point = 30},
                {range = {2,2},point = 24},
                {range = {3,4},point = 20},
                {range = {5,8},point = 17},
                {range = {9,16},point = 14},
                {range = {17,32},point = 12},
            },
        },
-- ÇøÓò¿ç·þ
        b5 = {
            {range = {1,1},point = 150},
            {range = {2,2},point = 100},
            {range = {3,4},point = 70},
        },
    },


    -- ¸öÈËÇøÓòÕ½²úÉú»ý·Ö±ÈÀý

    -- ¾üÍÅÇøÓòÕ½²úÉú»ý·Ö±ÈÀý

    -- ¸öÈËÉÏ°ñ×îÐ¡»ý·Ö
    personMinScore = 1,

    -- ¾üÍÅÉÏ°ñ×îÐ¡»ý·Ö
    allianceMinScore = 1,

    -- ¸öÈË°ñÕ¹Ê¾ÈËÊý
    personShowNum = 100,

    -- ¾üÍÅ°ñÕ¹Ê¾ÈËÊý
    allianceShowNum = 100,

    -- Õ½±¨±£ÁôÌõÊý
    logLimit = 30,

    -- ½áËãÊ±³¤£¨Õ¹Ê¾ÓÃ£©
    counttime = 300,

    -- ¸öÈË½±ÀøÅäÖÃ¹ØÏµ
    personRewardMapping={
        default=1,
        efun_tw=2,
    },

    -- ¸öÈË°ñ½±Àø
    personRankReward={ --¸öÈË°ñ½±Àø
        [1]={
            {range={1,1},reward={p={p962=3000}},serverreward={props_p962=3000}},
            {range={2,2},reward={p={p962=2500}},serverreward={props_p962=2500}},
            {range={3,4},reward={p={p962=2000}},serverreward={props_p962=2000}},
            {range={5,10},reward={p={p962=1700}},serverreward={props_p962=1700}},
            {range={11,20},reward={p={p962=1500}},serverreward={props_p962=1500}},
            {range={21,50},reward={p={p962=1300}},serverreward={props_p962=1300}},
            {range={51,100},reward={p={p962=1100}},serverreward={props_p962=1100}},
            {range={101,200},reward={p={p962=900}},serverreward={props_p962=900}},
            {range={201,500},reward={p={p962=700}},serverreward={props_p962=700}},
            {range={501,1000},reward={p={p962=500}},serverreward={props_p962=500}},
            {range={1001,2000},reward={p={p962=300}},serverreward={props_p962=300}},
            {range={2001,5000},reward={p={p962=100}},serverreward={props_p962=100}},
        },

        [2]={
            {range={1,1},reward={p={p962=3000}},serverreward={props_p962=3000}},
            {range={2,2},reward={p={p962=2500}},serverreward={props_p962=2500}},
            {range={3,4},reward={p={p962=2000}},serverreward={props_p962=2000}},
            {range={5,10},reward={p={p962=1700}},serverreward={props_p962=1700}},
            {range={11,50},reward={p={p962=1500}},serverreward={props_p962=1500}},
            {range={51,100},reward={p={p962=1300}},serverreward={props_p962=1300}},
            {range={101,500},reward={p={p962=1100}},serverreward={props_p962=1100}},
            {range={501,1000},reward={p={p962=900}},serverreward={props_p962=900}},
            {range={1001,2000},reward={p={p962=700}},serverreward={props_p962=700}},
            {range={2001,5000},reward={p={p962=500}},serverreward={props_p962=500}},
            {range={5001,10000},reward={p={p962=300}},serverreward={props_p962=300}},
            {range={10001,20000},reward={p={p962=100}},serverreward={props_p962=100}},
        },
    },

     --¾üÍÅÅÅÃû½±Àø»ý·Ö
    allianceRankReward={
        {range={1,1},reward={p={{p962=1000}}},serverreward={props_p962=1000}},
        {range={2,2},reward={p={{p962=700}}},serverreward={props_p962=700}},
        {range={3,3},reward={p={{p962=500}}},serverreward={props_p962=500}},
        {range={4,4},reward={p={{p962=400}}},serverreward={props_p962=400}},
        {range={5,6},reward={p={{p962=300}}},serverreward={props_p962=300}},
        {range={7,10},reward={p={{p962=200}}},serverreward={props_p962=200}},
    },
    --ÌìÌÝµÀ¾ß
    buyitem = "p962",

     --ÉÌµê
    pShopItems=
    {
        i1 ={id="i1",buynum=1,price=300,reward={e={{p11=1}}},serverReward={accessory_p11=1}},
        i2 ={id="i2",buynum=5,price=1200,reward={p={{p535=1}}},serverReward={props_p535=1}},
        i3 ={id="i3",buynum=5,price=1200,reward={p={{p543=1}}},serverReward={props_p543=1}},
        i4 ={id="i4",buynum=5,price=1200,reward={p={{p551=1}}},serverReward={props_p551=1}},
        i5 ={id="i5",buynum=5,price=1200,reward={p={{p559=1}}},serverReward={props_p559=1}},
        i6 ={id="i6",buynum=5,price=1000,reward={p={{p230=1}}},serverReward={props_p230=1}},
        i7 ={id="i7",buynum=1,price=1500,reward={p={{p90=1}}},serverReward={props_p90=1}},
        i8 ={id="i8",buynum=1,price=3000,reward={p={{p270=1}}},serverReward={props_p270=1}},
        i9 ={id="i9",buynum=20,price=5,reward={p={{p20=1}}},serverReward={props_p20=1}},
        i10 ={id="i10",buynum=20,price=200,reward={p={{p277=50}}},serverReward={props_p277=50}},
        i11 ={id="i11",buynum=20,price=200,reward={p={{p276=10}}},serverReward={props_p276=10}},
        i12 ={id="i12",buynum=20,price=200,reward={p={{p275=5}}},serverReward={props_p275=5}},
    },
}
