local skyladderCfg=
{
    -- 天梯榜包含的赛事类型id
    projectsIncluded = {
        ['1']='person',['2']='alliance',['3']='person',['5']='alliance'
    },
    noShow = {
        default = {},
        --efun_tw = {["5"]=1},
        android3kwan = {["5"]=1},
    },

    -- 天梯榜排名需要依据的积分字段
    personCountField = {point1=1,point2=2,point3=3,point4=5},
    ptypeField = {["1"]='point1',["2"]='point2',["3"]='point3',["5"]='point4'},
    allianceCountField = {point1=1,point2=2,point3=3,point4=5},

    -- 个人跨服战胜利给军团增加积分
    personToAlliancePoint = 0,

    -- 军团跨服战胜利给团员增加积分
    allianceToPersonPoint = 5,

    -- 轮空给分
    emptyBattle = 5,

    -- 各项大战排名分
    battleRankScore = {
        -- 个人跨服
        b1 = {
            {range = {1,1},point = 20},
            {range = {2,2},point = 15},
            {range = {3,4},point = 12},
            {range = {5,8},point = 10},
        },
        -- 军团跨服
        b2 = {
            {range = {1,1},point = 120},
            {range = {2,2},point = 80},
            {range = {3,4},point = 50},
        },
        b3 = {
            -- 世界争霸（精英）
            {
                {range = {1,1},point = 18},
                {range = {2,2},point = 14},
                {range = {3,4},point = 12},
                {range = {5,8},point = 10},
                {range = {9,16},point = 8},
                {range = {17,32},point = 7},
            },
            -- 世界争霸（大师）
            {
                {range = {1,1},point = 30},
                {range = {2,2},point = 24},
                {range = {3,4},point = 20},
                {range = {5,8},point = 17},
                {range = {9,16},point = 14},
                {range = {17,32},point = 12},
            },
        },
-- 区域跨服
        b5 = {
            {range = {1,1},point = 150},
            {range = {2,2},point = 100},
            {range = {3,4},point = 70},
        },
    },


    -- 个人区域战产生积分比例

    -- 军团区域战产生积分比例

    -- 个人上榜最小积分
    personMinScore = 1,

    -- 军团上榜最小积分
    allianceMinScore = 1,

    -- 个人榜展示人数
    personShowNum = 100,

    -- 军团榜展示人数
    allianceShowNum = 100,

    -- 战报保留条数
    logLimit = 30,

    -- 结算时长（展示用）
    counttime = 300,

    -- 个人奖励配置关系
    personRewardMapping={
        default=1,
        efun_tw=2,
    },

    -- 个人榜奖励
    personRankReward={ --个人榜奖励
        [1]={
            {range={1,1},reward={p={p4813=3000}},serverreward={props_p4813=3000}},
            {range={2,2},reward={p={p4813=2500}},serverreward={props_p4813=2500}},
            {range={3,4},reward={p={p4813=2000}},serverreward={props_p4813=2000}},
            {range={5,10},reward={p={p4813=1700}},serverreward={props_p4813=1700}},
            {range={11,20},reward={p={p4813=1500}},serverreward={props_p4813=1500}},
            {range={21,50},reward={p={p4813=1300}},serverreward={props_p4813=1300}},
            {range={51,100},reward={p={p4813=1100}},serverreward={props_p4813=1100}},
            {range={101,200},reward={p={p4813=900}},serverreward={props_p4813=900}},
            {range={201,500},reward={p={p4813=700}},serverreward={props_p4813=700}},
            {range={501,1000},reward={p={p4813=500}},serverreward={props_p4813=500}},
            {range={1000,2000},reward={p={p4813=300}},serverreward={props_p4813=300}},
            {range={2000,5000},reward={p={p4813=100}},serverreward={props_p4813=100}},
        },

        [2]={
            {range={1,1},reward={p={p4813=3000}},serverreward={props_p4813=3000}},
            {range={2,2},reward={p={p4813=2500}},serverreward={props_p4813=2500}},
            {range={3,4},reward={p={p4813=2000}},serverreward={props_p4813=2000}},
            {range={5,10},reward={p={p4813=1700}},serverreward={props_p4813=1700}},
            {range={11,50},reward={p={p4813=1500}},serverreward={props_p4813=1500}},
            {range={51,100},reward={p={p4813=1300}},serverreward={props_p4813=1300}},
            {range={101,500},reward={p={p4813=1100}},serverreward={props_p4813=1100}},
            {range={501,1000},reward={p={p4813=900}},serverreward={props_p4813=900}},
            {range={1000,2000},reward={p={p4813=700}},serverreward={props_p4813=700}},
            {range={2000,5000},reward={p={p4813=500}},serverreward={props_p4813=500}},
            {range={5001,10000},reward={p={p4813=300}},serverreward={props_p4813=300}},
            {range={10001,20000},reward={p={p4813=100}},serverreward={props_p4813=100}},
        },
    },

     --军团排名奖励积分
    allianceRankReward={
        {range={1,1},reward={p={{p4813=1000}}},serverreward={props_p4813=1000}},
        {range={2,2},reward={p={{p4813=700}}},serverreward={props_p4813=700}},
        {range={3,3},reward={p={{p4813=500}}},serverreward={props_p4813=500}},
        {range={4,4},reward={p={{p4813=400}}},serverreward={props_p4813=400}},
        {range={5,6},reward={p={{p4813=300}}},serverreward={props_p4813=300}},
        {range={7,10},reward={p={{p4813=200}}},serverreward={props_p4813=200}},
    },
    --天梯道具
    buyitem = "p4813",

     --商店
	pShopItems=						
	{						
	i1	 ={	id="i1",	buynum=1,	price=300,	reward={e={{p11=1}}},	serverReward={accessory_p11=1}},
	i2	 ={	id="i2",	buynum=1,	price=2500,	reward={p={{p535=1}}},	serverReward={props_p535=1}},
	i3	 ={	id="i3",	buynum=1,	price=2500,	reward={p={{p543=1}}},	serverReward={props_p543=1}},
	i4	 ={	id="i4",	buynum=1,	price=2500,	reward={p={{p551=1}}},	serverReward={props_p551=1}},
	i5	 ={	id="i5",	buynum=1,	price=2500,	reward={p={{p559=1}}},	serverReward={props_p559=1}},
	i6	 ={	id="i6",	buynum=5,	price=1000,	reward={p={{p230=1}}},	serverReward={props_p230=1}},
	i7	 ={	id="i7",	buynum=1,	price=1500,	reward={p={{p90=1}}},	serverReward={props_p90=1}},
	i8	 ={	id="i8",	buynum=1,	price=3000,	reward={p={{p270=1}}},	serverReward={props_p270=1}},
	i9	 ={	id="i9",	buynum=20,	price=5,	reward={p={{p20=1}}},	serverReward={props_p20=1}},
	i10	 ={	id="i10",	buynum=20,	price=200,	reward={p={{p277=50}}},	serverReward={props_p277=50}},
	i11	 ={	id="i11",	buynum=20,	price=200,	reward={p={{p276=10}}},	serverReward={props_p276=10}},
	i12	 ={	id="i12",	buynum=20,	price=200,	reward={p={{p275=5}}},	serverReward={props_p275=5}},
	},						

		
    battleDataCmd = {
        ['1']={cmd='crossserver.battlelist'},
        ['2']={cmd='acrossserver.battlelist'},
        ['3']={cmd='worldserver.battlelist'},
        ['5']={cmd='areateamwarserver.battlelist'},
    },
    keeppoint = 0.5,
}
return skyladderCfg
