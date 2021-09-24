local function returnCfg(clientPlat)
    local commonCfg = { 
    --情人节-长相厮守我们天天在一起
    -- name 活动名称，字段唯一，活动的标识
    -- type 活动类型
        -- 1 道具类奖励活动（此类活动奖励需要手动领取）
        -- 2 经验,声望类奖励活动（此类活动，游戏中自动发放）
        -- 3 按当前累积值发放奖励（此类活动，按累积值折算出道具数据，然后手动领取）
        -- 4 首充活动 (首充活动，只有一次，手动领取)
        -- 5 道具打折活动
    -- reward 活动奖励，需要用户手动领取
    -- extra 活动期间对原值进行倍数附加
    -- add 直接相加
    -- clientReward 返回客户端的奖励数据，纯显示用
    -- condition 活动条件 （活动计数的值）
    firstRecharge = {
        type        = 1 ,
        sortId = 1,
        -- value={exp=1,honors=2},
       serverreward = {
            props_p235=1,
            props_p2=1,
            troops_a10004=3,
            userinfo_gems = "@c",
        },
        reward = {
            u={gems=0},
            p={p2=1,p235=1},
            o={a10004=3}
        },
        condition = 1,
        value=2,
    },
	
	armor_firstRecharge = {
        type        = 1 ,
        sortId = 1,
        -- value={exp=1,honors=2},
       serverreward = {
            props_p235=1,
            props_p4519=1,
            troops_a10004=3,
            userinfo_gems = "@c",
        },
        reward = {
            u={gems=0},
            p={p4519=1,p235=1},
            o={a10004=3}
        },
        condition = 1,
        value=2,
    },

        --老玩家回归活动
        oldUserReturn = {
            type=1,
            sortId = 10,
            global=true,
            serverreward={
                box = {
                    {userinfo_r1=2419200,userinfo_r2=1814400,userinfo_r3=1209600,userinfo_r4=604800,userinfo_gold=604800,userinfo_exp=406210,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=2661120,userinfo_r2=1995840,userinfo_r3=1330560,userinfo_r4=665280,userinfo_gold=665280,userinfo_exp=497700,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=2914560,userinfo_r2=2185920,userinfo_r3=1457280,userinfo_r4=728640,userinfo_gold=728640,userinfo_exp=602000,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=3179520,userinfo_r2=2384640,userinfo_r3=1589760,userinfo_r4=794880,userinfo_gold=794880,userinfo_exp=719950,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=3456000,userinfo_r2=2592000,userinfo_r3=1728000,userinfo_r4=864000,userinfo_gold=864000,userinfo_exp=852390,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=3744000,userinfo_r2=2808000,userinfo_r3=1872000,userinfo_r4=936000,userinfo_gold=936000,userinfo_exp=1000160,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=4043520,userinfo_r2=3032640,userinfo_r3=2021760,userinfo_r4=1010880,userinfo_gold=1010880,userinfo_exp=1164100,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=4354560,userinfo_r2=3265920,userinfo_r3=2177280,userinfo_r4=1088640,userinfo_gold=1088640,userinfo_exp=1345050,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=4677120,userinfo_r2=3507840,userinfo_r3=2338560,userinfo_r4=1169280,userinfo_gold=1169280,userinfo_exp=1543850,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=5011200,userinfo_r2=3758400,userinfo_r3=2505600,userinfo_r4=1252800,userinfo_gold=1252800,userinfo_exp=1761340,userinfo_gems=100,props_p88=2,props_p20=10,props_p19=40,},
                    {userinfo_r1=5356800,userinfo_r2=4017600,userinfo_r3=2678400,userinfo_r4=1339200,userinfo_gold=1339200,userinfo_exp=1998360,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=5713920,userinfo_r2=4285440,userinfo_r3=2856960,userinfo_r4=1428480,userinfo_gold=1428480,userinfo_exp=2255750,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=6082560,userinfo_r2=4561920,userinfo_r3=3041280,userinfo_r4=1520640,userinfo_gold=1520640,userinfo_exp=2534350,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=6462720,userinfo_r2=4847040,userinfo_r3=3231360,userinfo_r4=1615680,userinfo_gold=1615680,userinfo_exp=2835000,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=6854400,userinfo_r2=5140800,userinfo_r3=3427200,userinfo_r4=1713600,userinfo_gold=1713600,userinfo_exp=3158540,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=7257600,userinfo_r2=5443200,userinfo_r3=3628800,userinfo_r4=1814400,userinfo_gold=1814400,userinfo_exp=3505810,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=7672320,userinfo_r2=5754240,userinfo_r3=3836160,userinfo_r4=1918080,userinfo_gold=1918080,userinfo_exp=3877650,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=8098560,userinfo_r2=6073920,userinfo_r3=4049280,userinfo_r4=2024640,userinfo_gold=2024640,userinfo_exp=4274900,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=8536320,userinfo_r2=6402240,userinfo_r3=4268160,userinfo_r4=2134080,userinfo_gold=2134080,userinfo_exp=4698400,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=8985600,userinfo_r2=6739200,userinfo_r3=4492800,userinfo_r4=2246400,userinfo_gold=2246400,userinfo_exp=5148990,userinfo_gems=160,props_p89=2,props_p20=15,props_p19=70,},
                    {userinfo_r1=9446400,userinfo_r2=7084800,userinfo_r3=4723200,userinfo_r4=2361600,userinfo_gold=2361600,userinfo_exp=5627510,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=9918720,userinfo_r2=7439040,userinfo_r3=4959360,userinfo_r4=2479680,userinfo_gold=2479680,userinfo_exp=6134800,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=10402560,userinfo_r2=7801920,userinfo_r3=5201280,userinfo_r4=2600640,userinfo_gold=2600640,userinfo_exp=6671700,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=10897920,userinfo_r2=8173440,userinfo_r3=5448960,userinfo_r4=2724480,userinfo_gold=2724480,userinfo_exp=7239050,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=11404800,userinfo_r2=8553600,userinfo_r3=5702400,userinfo_r4=2851200,userinfo_gold=2851200,userinfo_exp=7837690,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=11923200,userinfo_r2=8942400,userinfo_r3=5961600,userinfo_r4=2980800,userinfo_gold=2980800,userinfo_exp=8468460,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=12451200,userinfo_r2=9339840,userinfo_r3=6226560,userinfo_r4=3113280,userinfo_gold=3113280,userinfo_exp=9132200,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=12994560,userinfo_r2=9745920,userinfo_r3=6497280,userinfo_r4=3248640,userinfo_gold=3248640,userinfo_exp=9829750,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=13547520,userinfo_r2=10160640,userinfo_r3=6773760,userinfo_r4=3386880,userinfo_gold=3386880,userinfo_exp=10561950,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=14112000,userinfo_r2=10584000,userinfo_r3=7056000,userinfo_r4=3528000,userinfo_gold=3528000,userinfo_exp=11329640,userinfo_gems=220,props_p89=2,props_p20=20,props_p19=100,},
                    {userinfo_r1=14688000,userinfo_r2=11016000,userinfo_r3=7344000,userinfo_r4=3672000,userinfo_gold=3672000,userinfo_exp=12133660,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=15225600,userinfo_r2=11452800,userinfo_r3=7641600,userinfo_r4=3816000,userinfo_gold=3816000,userinfo_exp=12974850,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=15912000,userinfo_r2=11904000,userinfo_r3=7944000,userinfo_r4=3979200,userinfo_gold=3979200,userinfo_exp=13854050,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=16459200,userinfo_r2=12374400,userinfo_r3=8246400,userinfo_r4=4118400,userinfo_gold=4118400,userinfo_exp=14772100,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=17145600,userinfo_r2=12840000,userinfo_r3=8558400,userinfo_r4=4281600,userinfo_gold=4281600,userinfo_exp=15729840,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=17692800,userinfo_r2=13305600,userinfo_r3=8875200,userinfo_r4=4444800,userinfo_gold=4444800,userinfo_exp=16728110,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=18379200,userinfo_r2=13852800,userinfo_r3=9192000,userinfo_r4=4608000,userinfo_gold=4608000,userinfo_exp=17767750,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=19065600,userinfo_r2=14265600,userinfo_r3=9518400,userinfo_r4=4776000,userinfo_gold=4776000,userinfo_exp=18849600,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=19752000,userinfo_r2=14812800,userinfo_r3=9864000,userinfo_r4=4939200,userinfo_gold=4939200,userinfo_exp=19974500,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=20438400,userinfo_r2=15360000,userinfo_r3=10190400,userinfo_r4=5102400,userinfo_gold=5102400,userinfo_exp=21143290,userinfo_gems=280,props_p89=2,props_p20=25,props_p19=130,},
                    {userinfo_r1=21120000,userinfo_r2=15772800,userinfo_r3=10550400,userinfo_r4=5270400,userinfo_gold=5270400,userinfo_exp=22356810,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=21840000,userinfo_r2=16320000,userinfo_r3=10944000,userinfo_r4=5472000,userinfo_gold=5472000,userinfo_exp=23615900,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=22560000,userinfo_r2=16848000,userinfo_r3=11328000,userinfo_r4=5664000,userinfo_gold=5664000,userinfo_exp=24921400,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=23280000,userinfo_r2=17376000,userinfo_r3=11712000,userinfo_r4=5856000,userinfo_gold=5856000,userinfo_exp=26274150,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=23952000,userinfo_r2=17904000,userinfo_r3=12048000,userinfo_r4=6048000,userinfo_gold=6048000,userinfo_exp=27674990,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=24624000,userinfo_r2=18432000,userinfo_r3=12384000,userinfo_r4=6240000,userinfo_gold=6240000,userinfo_exp=29124760,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=25296000,userinfo_r2=18912000,userinfo_r3=12720000,userinfo_r4=6432000,userinfo_gold=6432000,userinfo_exp=36836100,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=25920000,userinfo_r2=19392000,userinfo_r3=13056000,userinfo_r4=6624000,userinfo_gold=6624000,userinfo_exp=70000000,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=26544000,userinfo_r2=19872000,userinfo_r3=13392000,userinfo_r4=6816000,userinfo_gold=6816000,userinfo_exp=105000000,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=27168000,userinfo_r2=20304000,userinfo_r3=13728000,userinfo_r4=7008000,userinfo_gold=7008000,userinfo_exp=140000000,userinfo_gems=340,props_p89=2,props_p20=30,props_p19=160,},
                    {userinfo_r1=27744000,userinfo_r2=20736000,userinfo_r3=14016000,userinfo_r4=7152000,userinfo_gold=7152000,userinfo_exp=175000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=28320000,userinfo_r2=21168000,userinfo_r3=14304000,userinfo_r4=7296000,userinfo_gold=7296000,userinfo_exp=210000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=28848000,userinfo_r2=21600000,userinfo_r3=14592000,userinfo_r4=7440000,userinfo_gold=7440000,userinfo_exp=245000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=29376000,userinfo_r2=21984000,userinfo_r3=14880000,userinfo_r4=7584000,userinfo_gold=7584000,userinfo_exp=280000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=29904000,userinfo_r2=22368000,userinfo_r3=15168000,userinfo_r4=7728000,userinfo_gold=7728000,userinfo_exp=315000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=30384000,userinfo_r2=22752000,userinfo_r3=15408000,userinfo_r4=7872000,userinfo_gold=7872000,userinfo_exp=350000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=30864000,userinfo_r2=23088000,userinfo_r3=15648000,userinfo_r4=8016000,userinfo_gold=8016000,userinfo_exp=350000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=31296000,userinfo_r2=23424000,userinfo_r3=15888000,userinfo_r4=8160000,userinfo_gold=8160000,userinfo_exp=350000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=31728000,userinfo_r2=23760000,userinfo_r3=16128000,userinfo_r4=8304000,userinfo_gold=8304000,userinfo_exp=350000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=32160000,userinfo_r2=24096000,userinfo_r3=16368000,userinfo_r4=8448000,userinfo_gold=8448000,userinfo_exp=350000000,userinfo_gems=400,props_p90=2,props_p20=35,props_p19=190,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=460,props_p90=2,props_p20=40,props_p19=220,},
                    {userinfo_r1=32544000,userinfo_r2=24384000,userinfo_r3=16608000,userinfo_r4=8592000,userinfo_gold=8592000,userinfo_exp=350000000,userinfo_gems=520,props_p90=2,props_p20=45,props_p19=250,},
                },
                staybehindreward ={
                    {props_p20=5,props_p47=10,accessory_p6=10,accessory_p3=20},
                },
                totalreward = {
                    {troops_a10053=1},
                },
                need=10,
                minlevel=10,
                oldtime=864000 --1天
            },
        },

    -- 限时折扣礼包
    discount = {
        multiSelectType=true,
        --限时购买
        [1]={
            type=1,
            sortId=20,
            version=1,
            props={
                p678=0.5,
                p19=0.5,
				p601=0.75,
                p20=0.8,
                p2=0.7,
                p4=0.5,
            },
            maxCount={
                p678=1,
                p19=50,
				p601=20,
                p20=10,
                p2=5,
                p4=1,
            },
        },        
        [2]={
            type=1,
            sortId=20,
            version=1,
            props={
                p48=0.4989,
                p49=0.889,
				p863=0.8,
                p50=0.646,
                p51=0.199,
                p96=0.299,
            },
            maxCount={
                p48=5,
                p49=3,
				p863=1,
                p50=2,
                p51=2,
                p96=5,
            },
        },
        --黑色星期五（高级版）
        [3]={
            type=1,
            sortId=20,
            version=2,
            props={
                p674=0.6,
                p675=0.25,
                p676=0.15,
            },
            maxCount={
                p674=5,
                p675=20,
                p676=10,
            },
        },
        --黑色星期五（北美运营需求版）
        [4]={
            type=1,
            sortId=20,
            version=3,
            props={
                p1093=0.4,
                p1094=0.3,
                p1095=0.3,
            },
            maxCount={
                p1093=10,
                p1094=5,
                p1095=5,
            },
        },
                --17年5月将领技能升级/进阶包
                [5]={
                    type=1,
                    sortId=20,
                    version=4,
                    props={
                        p4652=0.8496,
                        p4653=0.8496,
                        p4654=0.8496,
                        p4655=0.8496,
                        p4656=0.8496,
                        p4662=0.7997,
                        p4663=0.7997,
                        p4664=0.7997,
                        p4665=0.7997,
                        p4666=0.7997,
                    },
                    maxCount={
                        p4652=5,
                        p4653=5,
                        p4654=5,
                        p4655=5,
                        p4656=5,
                        p4662=5,
                        p4663=5,
                        p4664=5,
                        p4665=5,
                        p4666=5,
                    },
                },
                --17年5月将领技能升级/进阶包2
                [6]={
                    type=1,
                    sortId=20,
                    version=5,
                    props={
                        p4657=0.8496,
                        p4658=0.8496,
                        p4659=0.8496,
                        p4660=0.8496,
                        p4661=0.8496,
                        p4667=0.7997,
                        p4668=0.7997,
                        p4669=0.7997,
                        p4670=0.7997,
                        p4671=0.7997,
                    },
                    maxCount={
                        p4657=5,
                        p4658=5,
                        p4659=5,
                        p4660=5,
                        p4661=5,
                        p4667=5,
                        p4668=5,
                        p4669=5,
                        p4670=5,
                        p4671=5,
                    },
                },
        --原德国版本,version不要改
        [7]={
            type=1,
            sortId=20,
            version=6,
            props={
                p48=0.4989,
                p49=0.889,
                p863=0.8,
                p50=0.646,
                p51=0.199,
                p87=0.63,
            },
            maxCount={
                p48=5,
                p49=3,
                p863=1,
                p50=2,
                p51=2,
                p87=99,
            },
        },
        --年终大礼（含7,8配件）
        [8]={
            type=1,
            sortId=20,
            version=7,
            props={
                p678=0.5,
                p675=0.25,
                p801=0.1,
                p802=0.5,
            },
            maxCount={
                p678=1,
                p675=3,
                p801=5,
                p802=1,
            },
        },
        --年终大礼（含5,6配件）
        [9]={
            type=1,
            sortId=20,
            version=8,
            props={
                p678=0.5,
                p675=0.25,
                p676=0.15,
                p803=0.5,
            },
            maxCount={
                p678=1,
                p675=3,
                p676=5,
                p803=1,
            },
        },
        --限时购买--异星资源和将领魂石
        [10]={
            type=1,
            sortId=20,
            version=9,
            props={
                p867=0.5,
                p868=0.5,
                p869=0.5,
                p870=0.5,
                p871=0.5,
                p872=0.5,
                p96=0.199,
                p51=0.199,
                p818=0.38,
                p819=0.38,
            },
            maxCount={
                p867=1,
                p868=1,
                p869=1,
                p870=1,
                p871=1,
                p872=1,
                p96=1,
                p51=3,
                p818=20,
                p819=20,
            },
        },
        --金秋回馈
        [11]={
            type=1,
            sortId=20,
            version=10,
            props={
                p928=0.75,
                p929=0.75,
                p930=0.75,
                p863=0.75,
                p803=0.45,
            },
            maxCount={
                p928=1,
                p929=1,
                p930=1,
                p863=1,
                p803=1,
            },
        },
		--紫配打折
		[12]={
			type=1,
			sortId=20,
			version=11,
			props={
				p928=0.75,
				p929=0.75,
				p930=0.75,
				p90=0.5,
				p270=0.6,
				p566=0.7,
				p96=0.3,
			},
			maxCount={
				p928=3,
				p929=3,
				p930=3,
				p90=10,
				p270=10,
				p566=10,
				p96=5,
			},
		},
                --限时购买--异星资源
                [13]={
                    type=1,
                    sortId=20,
                    version=13,
                    props={
                        p867=0.5,
                        p868=0.5,
                        p870=0.5,
                        p871=0.5,
                        p872=0.5,
                    },
                    maxCount={
                        p867=8,
                        p868=8,
                        p870=6,
                        p871=6,
                        p872=6,
                    },
                },        
                --限时购买--7号先进碎片礼包版
                [14]={
                    type=1,
                    sortId=20,
                    version=14,
                    props={
                        p928=0.75,
                        p929=0.75,
                        p930=0.75,
                        p96=0.3,
                        p4890=0.5,
                        p230=0.75,
                    },
                    maxCount={
                        p928=3,
                        p929=3,
                        p930=3,
                        p96=5,
                        p4890=3,
                        p230=1,
                    },
                },
                --限时购买--8号先进碎片礼包版
                [15]={
                    type=1,
                    sortId=20,
                    version=15,
                    props={
                        p928=0.75,
                        p929=0.75,
                        p930=0.75,
                        p96=0.3,
                        p4891=0.5,
                        p230=0.75,
                    },
                    maxCount={
                        p928=3,
                        p929=3,
                        p930=3,
                        p96=5,
                        p4891=3,
                        p230=1,
                    },
                },
                --限时购买--异星宝石
                [16]={
                    type=1,
                    sortId=20,
                    version=16,
                    props={
                        p4892=0.9,
                        p4893=0.95,
                        p4894=0.9,
                        p4895=0.9,
                        p4896=0.9,
                        p4897=0.9,
                        p4898=0.9,
                        p4899=0.9,
                    },
                    maxCount={
                        p4892=2,
                        p4893=2,
                        p4894=3,
                        p4895=3,
                        p4896=3,
                        p4897=3,
                        p4898=3,
                        p4899=3,
                    },
                },
                --限时购买--异星宝石
                [17]={
                    type=1,
                    sortId=20,
                    version=17,
                    props={
                        p4901=0.4,
                        p4893=0.8,
                        p4902=0.3,
                    },
                    maxCount={
                        p4901=10,
                        p4893=2,
                        p4902=10,
                    },
                },

                --限时购买--名将魂石箱
                [18]={
                    type=1,
                    sortId=20,
                    version=18,
                    props={
                        p3360=0.25,
                        p3361=0.25,
                        p3362=0.25,
                        p3363=0.25,
                    },
                    maxCount={
                        p3360=100,
                        p3361=100,
                        p3362=100,
                        p3363=100,
                    },
                },
                --限时购买--7.5级战舰
                [19]={
                    type=1,
                    sortId=20,
                    version=19,
                    props={
                        p5150=0.35,
                        p5151=0.35,
                        p5152=0.35,
                        p5153=0.35,
                        p5154=0.35,
                        p5155=0.35,
                        p5156=0.35,
                        p5157=0.35,
                        p5158=0.35,
                    },
                    maxCount={
                        p5150=10,
                        p5151=10,
                        p5152=10,
                        p5153=10,
                        p5154=10,
                        p5155=10,
                        p5156=10,
                        p5157=10,
                        p5158=10,
                    },
                },

    },

    -- 莫斯科赌局
    moscowGambling = {
        type = 1,
        sortId = 30,
        data={
           pool={{100},{23,23,17,17,7,7,3,3},{{"part2",2},{"part2",4},{"part1",2},{"part1",4},{"props_p11",2},{"props_p12",1},{"props_p42",1},{"props_p43",1},}},
           upgradePartConsume = 20,
           gemCost=38,
        },
    },

    -- 莫斯科赌局(vip价格优惠，鼠式坦克和突击虎)
        moscowGamblingGai = {
            multiSelectType=true,
            --T-90黑鹰VIP折扣
            [1] = {
                type = 1,
                sortId = 30,
                version =1,
                data={
                    pool={{100},
                        {23,23,17,17,7,3,7,3,},
                        {{"part1",2},{"part1",4},{"part2",2},{"part2",4},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},},
                    },
                    upgradePartConsume = 20,
                    --碎片对应的合成坦克
                    partMap = {"a10043","a10053"},
                    gemCost=38,
                },
            },
            --突击虎鼠式坦克VIP折扣
            [2] = {
                type = 1,
                sortId = 30,
                version=2,
                data={
                    pool={{100},
                        {22,22,16,16,7,5,7,5,},
                        {{"part1",2},{"part1",4},{"part2",2},{"part2",4},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},},
                    },
                    upgradePartConsume = 20,
                    --碎片对应的合成坦克
                    partMap = {"a10063","a10073"},
                    gemCost=38,
                },
            },
            --谢尔曼虎式坦克VIP折扣
            [3] = {
                type = 1,
                sortId = 30,
                version=3,
                data={
                    pool={{100},
                        {19,19,19,19,7,5,7,5,},
                        {{"part1",2},{"part1",4},{"part2",2},{"part2",4},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},},
                    },
                    upgradePartConsume = 20,
                    --碎片对应的合成坦克
                    partMap = {"a10113","a10123"},
                    gemCost=38,
                },
            },
				 --T-90黑鹰VIP折扣									
								
				[4] = {									
				type = 1,									
				sortId = 30,									
				version=4,									
				data={									
				pool={{100},									
				{	130,	108,	150,	136,	173,	65,	173,	65,	},
				{	{"part1",2},	{"part1",4},	{"part2",2},	{"part2",4},	{"props_p12",1},	{"props_p42",1},	{"props_p11",1},	{"props_p43",1},	},
				},									
				upgradePartConsume = 20,									
				 --碎片对应的合成坦克									
				partMap = {"a10043","a10053"},									
				gemCost=38,									
				},									
				},									
	

 --突击虎鼠式坦克VIP折扣									
									
									
				[5] = {									
				type = 1,									
				sortId = 30,									
				version=5,									
				data={									
				pool={{100},									
				{	130,	108,	116,	100,	130,	87,	105,	50,	},
				{	{"part1",2},	{"part1",4},	{"part2",2},	{"part2",4},	{"props_p12",1},	{"props_p42",1},	{"props_p11",1},	{"props_p43",1},	},
				},									
				upgradePartConsume = 20,									
				 --碎片对应的合成坦克									
				partMap = {"a10063","a10073"},									
				gemCost=38,									
				},									
				},									

 --谢尔曼虎式坦克VIP折扣									
									
									
				[6] = {									
				type = 1,									
				sortId = 30,									
				version=6,									
				data={									
				pool={{100},									
				{	150,	136,	116,	100,	159,	90,	159,	90,	},
				{	{"part1",2},	{"part1",4},	{"part2",2},	{"part2",4},	{"props_p12",1},	{"props_p42",1},	{"props_p11",1},	{"props_p43",1},	},
				},									
				upgradePartConsume = 20,									
				 --碎片对应的合成坦克									
				partMap = {"a10113","a10123"},									
				gemCost=38,									
				},									
				},									
							
								
							
        },

    -- 军团关卡，赢豪礼
    fbReward = {
        type = 1,
        sortId = 40,
        serverreward = {
            box = {
                {{'props_p56',20,1},},
                {{'props_p56',20,1},},
                {{'props_p56',20,1},},
                {{'props_p56',20,1},},
                {{'props_p56',30,1},{'props_p57',1,1},},
                {{'props_p56',25,1},},
                {{'props_p56',25,1},},
                {{'props_p56',25,1},},
                {{'props_p56',25,1},},
                {{'props_p56',35,1},{'props_p57',3,1},},
                {{'props_p56',30,1},},
                {{'props_p56',30,1},},
                {{'props_p56',30,1},},
                {{'props_p56',30,1},},
                {{'props_p56',40,1},{'props_p57',6,1},},
                {{'props_p56',45,1},},
                {{'props_p56',45,1},},
                {{'props_p56',45,1},},
                {{'props_p56',45,1},},
                {{'props_p56',55,1},{'props_p57',10,1},},
            },
            ranking = {
                {AllianceExp=300,userinfo_r1=5000000,userinfo_r2=5000000,userinfo_r3=5000000,userinfo_r4=5000000,userinfo_gold=5000000,},
                {AllianceExp=200,userinfo_r1=3000000,userinfo_r2=3000000,userinfo_r3=3000000,userinfo_r4=3000000,userinfo_gold=3000000,},
                {AllianceExp=100,userinfo_r1=1000000,userinfo_r2=1000000,userinfo_r3=1000000,userinfo_r4=1000000,userinfo_gold=1000000,},
            }
        },
        reward = {
            {a={aexp=300},u={r1=5000000,r2=5000000,r3=5000000,r4=5000000,gold=5000000,}},
            {a={aexp=200},u={r1=3000000,r2=3000000,r3=3000000,r4=3000000,gold=3000000,}},
            {a={aexp=100},u={r1=1000000,r2=1000000,r3=1000000,r4=1000000,gold=1000000,}},
        }
    },

    -- 所有杂的活动，提升概率之类的 隐藏活动不显示给前台 修改为周末狂欢活动
    luckUp = {
        type = 1,
        sortId = 50,
        data={
            attackIsland={exp=0.2,propRate=0.3},
            attackChallenge={exp=0.2},
            troopsup = {upRate=0.1},
        },
    },

        -- 幸运转盘
        wheelFortune = {
            multiSelectType=true,
            [1] = {
                type=1,
                sortId=60,
                version=1,
                serverreward={
                    --排行奖励（前10名）
                    r={
                        {props_p90=1,props_p1=2},
                        {props_p90=1,props_p1=1},
                        {props_p267=3,props_p1=1},
                        {props_p267=2,props_p19=40},
                        {props_p267=2,props_p19=40},
                        {props_p267=1,props_p19=30},
                        {props_p267=1,props_p19=30},
                        {props_p267=1,props_p19=30},
                        {props_p267=1,props_p19=30},
                        {props_p267=1,props_p19=30},
                    },
                    --奖池
                    pool={{100},{5,10,17,10,3,13,3,6,8,8,8,9,},{{"accessory_p1",1},{"accessory_p2",1},{"accessory_p3",1},{"accessory_p4",100},{"accessory_p5",1},{"accessory_p6",1},{"props_p267",1},{"props_p266",1},{"troops_a10004",1},{"troops_a10014",1},{"troops_a10024",1},{"troops_a10034",1},}},
                    --资源对应的积分数
                    res4point={
                        accessory_p1={{100},{1,1,1},{4,5,6}},
                        accessory_p2={{100},{1,1,1},{2,3,4}},
                        accessory_p3={{100},{1,1,1},{1,2,3}},
                        accessory_p4={{100},{1,1,1},{1,2,3}},
                        accessory_p5={{100},{1,1,1},{10,11,12}},
                        accessory_p6={{100},{1,1,1},{2,3,4}},
                        props_p267={{100},{1,1,1},{20,21,22}},
                        props_p266={{100},{1,1,1},{8,9,10}},
                        troops_a10004={{100},{1,1,1},{3,4,5}},
                        troops_a10014={{100},{1,1,1},{4,5,6}},
                        troops_a10024={{100},{1,1,1},{6,7,8}},
                        troops_a10034={{100},{1,1,1},{8,9,10}},
                    },
                    --进行排行需要的最低积分
                    rankPoint=200,
                    --抽奖需要的金币
                    lotteryConsume=199,

                    -- 积分对应的奖励 1是需要的积分，2号位是实际奖励
                    pointReward = {20,{props_p20=1,props_p13=1}}
                },
                reward={
                    --排行奖励（前10名）
                    r={
                        {p={p90=1,p1=2}},--1
                        {p={p90=1,p1=1}},--2
                        {p={p267=3,p1=1}},--3
                        {p={p267=2,p19=40}},--4~5
                        {p={p267=1,p19=30}},--6~10
                    },
                    --奖池
                    pool={e={{p1=1,index=1},{p2=1,index=2},{p3=1,index=3},{p4=100,index=4},{p5=1,index=5},{p6=1,index=6},},p={{p267=1,index=7},{p266=1,index=8},},o={{a10004=1,index=9},{a10014=1,index=10},{a10024=1,index=11},{a10034=1,index=12},}},
                    --资源对应的积分数
                    res4point={
                        accessory_p1={{100},{1,1,1},{4,5,6}},
                        accessory_p2={{100},{1,1,1},{2,3,4}},
                        accessory_p3={{100},{1,1,1},{1,2,3}},
                        accessory_p4={{100},{1,1,1},{1,2,3}},
                        accessory_p5={{100},{1,1,1},{10,11,12}},
                        accessory_p6={{100},{1,1,1},{2,3,4}},
                        props_p267={{100},{1,1,1},{20,21,22}},
                        props_p266={{100},{1,1,1},{8,9,10}},
                        troops_a10004={{100},{1,1,1},{3,4,5}},
                        troops_a10014={{100},{1,1,1},{4,5,6}},
                        troops_a10024={{100},{1,1,1},{6,7,8}},
                        troops_a10034={{100},{1,1,1},{8,9,10}},
                    },
                    --进行排行需要的最低积分(后台）
                    rankPoint=200,
                    --抽奖需要的金币
                    lotteryConsume=199,
                    -- 积分对应的奖励 1是需要的积分，2号位是实际奖励
                    pointReward = {20,{p={p20=1,index=1},{p13=1,index=2}}}
                },
            },
            --奖励加强版本
            [2] = {
                type = 1,
                sortId = 60,
                version=2,
                serverreward = {
                    r = {
                        {props_p20=20,userinfo_gems=1000},
                        {props_p20=15,userinfo_gems=600},
                        {props_p20=12,userinfo_gems=400},
                        {props_p20=8,userinfo_gems=300},
                        {props_p20=8,userinfo_gems=300},
                        {props_p20=6,userinfo_gems=200},
                        {props_p20=6,userinfo_gems=200},
                        {props_p20=6,userinfo_gems=200},
                        {props_p20=6,userinfo_gems=200},
                        {props_p20=6,userinfo_gems=200},
                    },
                    pool={
                        {100},
                        {10,10,10,10,10,10,10,10,5,5,5,10},
                        {
                            {"userinfo_r1",120000},{"userinfo_r2",90000},{"userinfo_r3",60000},{"userinfo_r4",30000},{"userinfo_gems",50},{"userinfo_energy",10},{"userinfo_honors",200},{"userinfo_exp",10000},{"troops_a10004",1},{"troops_a10014",1},{"troops_a10024",1},{"troops_a10034",1}
                        }
                    },
                    res4point = {
                        userinfo_r1={{100},{1,1,1},{3,4,5}},
                        userinfo_r2={{100},{1,1,1},{3,4,5}},
                        userinfo_r3={{100},{1,1,1},{3,4,5}},
                        userinfo_r4={{100},{1,1,1},{3,4,5}},
                        userinfo_gems={{100},{1,1,1},{4,5,6}},
                        userinfo_energy={{100},{1,1,1},{3,4,5}},
                        userinfo_honors={{100},{1,1,1},{2,3,4}},
                        userinfo_exp={{100},{1,1,1},{3,4,5}},
                        troops_a10004={{100},{1,1,1},{5,6,7}},
                        troops_a10014={{100},{1,1,1},{7,8,9}},
                        troops_a10024={{100},{1,1,1},{9,10,11}},
                        troops_a10034={{100},{1,1,1},{13,14,15}},
                    },
                    --进行排行需要的最低积分
                    rankPoint=200,
                    --抽奖需要的金币
                    lotteryConsume=88,

                    -- 积分对应的奖励 1是需要的积分，2号位是实际奖励
                    pointReward = {20,{props_p20=1,props_p13=1}}
                },
                reward={
                    r = {
                        {p={p20=20},u={gems=1000}},
                        {p={p20=15},u={gems=600}},
                        {p={p20=12},u={gems=400}},
                        {p={p20=8},u={gems=300}},
                        {p={p20=6},u={gems=200}},
                    },
                    pool={
                        u={{r1=120000,index=1},{r2=90000,index=4},{r3=60000,index=7},{r4=30000,index=10},{gems=50,index=2},{energy=10,index=5},{honors=200,index=8},{exp=10000,index=11}},
                        o={{a10004=1,index=3},{a10014=1,index=6},{a10024=1,index=9},{a10034=1,index=12}}
                    },
                    res4point = {
                        userinfo_r1={{100},{1,1,1},{3,4,5}},
                        userinfo_r2={{100},{1,1,1},{3,4,5}},
                        userinfo_r3={{100},{1,1,1},{3,4,5}},
                        userinfo_r4={{100},{1,1,1},{3,4,5}},
                        userinfo_gems={{100},{1,1,1},{4,5,6}},
                        userinfo_energy={{100},{1,1,1},{3,4,5}},
                        userinfo_honors={{100},{1,1,1},{2,3,4}},
                        userinfo_exp={{100},{1,1,1},{3,4,5}},
                        troops_a10004={{100},{1,1,1},{5,6,7}},
                        troops_a10014={{100},{1,1,1},{7,8,9}},
                        troops_a10024={{100},{1,1,1},{9,10,11}},
                        troops_a10034={{100},{1,1,1},{13,14,15}},
                    },
                    --进行排行需要的最低积分(后台）
                    rankPoint=200,
                    --抽奖需要的金币
                    lotteryConsume=88,
                    -- 积分对应的奖励 1是需要的积分，2号位是实际奖励
                    pointReward = {20,{p={p20=1,index=1},{p13=1,index=2}}}
                },
            },
--异星资源版本
			[3]={
				type=1,																											
				sortId=60,																											
				serverreward={																											
				--排行奖励（前10名）																											
				r={																											
				{	alien_r2=50000	,	alien_r6=2000	},																							
				{	alien_r2=30000	,	alien_r6=1500	},																							
				{	alien_r2=20000	,	alien_r6=1000	},																							
				{	alien_r2=12000	,	alien_r6=500	},																							
				{	alien_r2=12000	,	alien_r6=500	},																							
				{	alien_r2=5000	,	alien_r6=300	},																							
				{	alien_r2=5000	,	alien_r6=300	},																							
				{	alien_r2=5000	,	alien_r6=300	},																							
				{	alien_r2=5000	,	alien_r6=300	},																							
				{	alien_r2=5000	,	alien_r6=300	},																							
				},																											
				--奖池																											
				pool={{100},{	20,	10,	10,	20,	20,	10,	20,	10,	10,	20,	20,	20,	},	{	{"alien_r2",50},	{"alien_r5",50},	{"alien_r1",400},	{"alien_r6",2},	{"alien_r2",100},	{"alien_r4",50},	{"alien_r1",100},	{"alien_r6",5},	{"alien_r2",200},	{"alien_r5",20},	{"alien_r1",200},	{"alien_r4",20},	}},
				--资源对应的积分数																											
				res4point={																											
				alien_r2=	{{100},{1,1,1},	{	1,2,3	}},																							
				alien_r5=	{{100},{1,1,1},	{	3,4,5	}},																							
				alien_r1=	{{100},{1,1,1},	{	2,3,4	}},																							
				alien_r6=	{{100},{1,1,1},	{	2,3,4	}},																							
				alien_r2=	{{100},{1,1,1},	{	1,2,3	}},																							
				alien_r4=	{{100},{1,1,1},	{	3,4,5	}},																							
				alien_r1=	{{100},{1,1,1},	{	1,2,3	}},																							
				alien_r6=	{{100},{1,1,1},	{	4,5,6	}},																							
				alien_r2=	{{100},{1,1,1},	{	2,3,4	}},																							
				alien_r5=	{{100},{1,1,1},	{	2,3,4	}},																							
				alien_r1=	{{100},{1,1,1},	{	1,2,3	}},																							
				alien_r4=	{{100},{1,1,1},	{	1,2,3	}},																							
				},																											
				--进行排行需要的最低积分																											
				rankPoint=200,																											
				--抽奖需要的金币																											
				lotteryConsume=	199	,																									
				--积分对应的奖励1是需要的积分，2号位是实际奖励																											
				pointReward={20,{alien_r2=200,alien_r6=2}}																											
				},																											

																
				reward={														
				--排行奖励（前10名）														
				r={														
				{	r={r2=50000	,	r6=2000	}},	--1									
				{	r={r2=30000	,	r6=1500	}},	--2									
				{	r={r2=20000	,	r6=1000	}},	--3									
				{	r={r2=12000	,	r6=500	}},	--4~5									
				{	r={r2=5000	,	r6=300	}},	--6~10									
				},														
				--奖池														
				pool={	r={	{r2=50,index=1},	{r5=50,index=2},	{r1=400,index=3},	{r6=2,index=4},	{r2=100,index=5},	{r4=50,index=6},	{r1=100,index=7},	{r6=5,index=8},	{r2=200,index=9},	{r5=20,index=10},	{r1=200,index=11},	{r4=20,index=12},	}},
				-- 资源对应的积分数														
				res4point={														
				alien_r2=	{{100},{1,1,1},	{	1,2,3	}},										
				alien_r5=	{{100},{1,1,1},	{	3,4,5	}},										
				alien_r1=	{{100},{1,1,1},	{	2,3,4	}},										
				alien_r6=	{{100},{1,1,1},	{	2,3,4	}},										
				alien_r2=	{{100},{1,1,1},	{	1,2,3	}},										
				alien_r4=	{{100},{1,1,1},	{	3,4,5	}},										
				alien_r1=	{{100},{1,1,1},	{	1,2,3	}},										
				alien_r6=	{{100},{1,1,1},	{	4,5,6	}},										
				alien_r2=	{{100},{1,1,1},	{	2,3,4	}},										
				alien_r5=	{{100},{1,1,1},	{	2,3,4	}},										
				alien_r1=	{{100},{1,1,1},	{	1,2,3	}},										
				alien_r4=	{{100},{1,1,1},	{	1,2,3	}},										
				},														
				-- 进行排行需要的最低积分(后台）														
				rankPoint=200,														
				-- 抽奖需要的金币														
				lotteryConsume=199	,												
				--积分对应的奖励1是需要的积分，2号位是实际奖励														
				pointReward={20,{alien_r2=200,alien_r6=2}}														
				},   														
				},														
																

        },

    -- 幸运转盘(10连抽版)
    wheelFortune2={
        type=1,
        sortId=60,
        serverreward={
        --排行奖励（前10名）
        r={
        {props_p20=50,props_p1=2},
        {props_p20=30,props_p1=1},
        {props_p20=20,props_p1=1},
        {props_p20=15,props_p19=40},
        {props_p20=15,props_p19=40},
        {props_p20=10,props_p19=30},
        {props_p20=10,props_p19=30},
        {props_p20=10,props_p19=30},
        {props_p20=10,props_p19=30},
        {props_p20=10,props_p19=30},
        },
        --奖池
        pool={{100},{5,10,17,10,3,13,3,6,8,8,8,9,},{{"props_p30",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p14",1},{"props_p2",1},{"props_p15",2},{"troops_a10004",1},{"troops_a10014",1},{"troops_a10024",1},{"troops_a10034",1},}},
        --资源对应的积分数
        res4point={
        props_p30={{100},{1,1,1},{4,5,6}},
        props_p26={{100},{1,1,1},{4,5,6}},
        props_p27={{100},{1,1,1},{4,5,6}},
        props_p28={{100},{1,1,1},{4,5,6}},
        props_p29={{100},{1,1,1},{4,5,6}},
        props_p14={{100},{1,1,1},{3,4,5}},
        props_p2={{100},{1,1,1},{23,24,25}},
        props_p15={{100},{1,1,1},{6,7,8}},
        troops_a10004={{100},{1,1,1},{1,2,3}},
        troops_a10014={{100},{1,1,1},{1,2,3}},
        troops_a10024={{100},{1,1,1},{2,3,4}},
        troops_a10034={{100},{1,1,1},{2,3,4}},
        },
        --进行排行需要的最低积分
        rankPoint=200,
        --抽奖需要的金币
        lotteryConsume=199,
        --积分对应的奖励1是需要的积分，2号位是实际奖励
        pointReward={20,{props_p20=1,props_p13=1}}
        },
        reward={
        --排行奖励（前10名）
        r={
        {p={p20=50,p1=2}},--1
        {p={p20=30,p1=1}},--2
        {p={p20=20,p1=1}},--3
        {p={p20=15,p19=40}},--4~5
        {p={p20=10,p19=30}},--6~10
        },
        --奖池
        pool={p={{p30=1,index=1},{p26=1,index=2},{p27=1,index=3},{p28=1,index=4},{p29=1,index=5},{p14=1,index=6},{p2=1,index=7},{p15=2,index=8},},o={{a10004=1,index=9},{a10014=1,index=10},{a10024=1,index=11},{a10034=1,index=12},}},
        -- 资源对应的积分数
        res4point={
        props_p30={{100},{1,1,1},{4,5,6}},
        props_p26={{100},{1,1,1},{4,5,6}},
        props_p27={{100},{1,1,1},{4,5,6}},
        props_p28={{100},{1,1,1},{4,5,6}},
        props_p29={{100},{1,1,1},{4,5,6}},
        props_p14={{100},{1,1,1},{3,4,5}},
        props_p2={{100},{1,1,1},{23,24,25}},
        props_p15={{100},{1,1,1},{6,7,8}},
        troops_a10004={{100},{1,1,1},{1,2,3}},
        troops_a10014={{100},{1,1,1},{1,2,3}},
        troops_a10024={{100},{1,1,1},{2,3,4}},
        troops_a10034={{100},{1,1,1},{2,3,4}},
        },
        -- 进行排行需要的最低积分(后台）
        rankPoint=200,
        -- 抽奖需要的金币
        lotteryConsume=199,
        --积分对应的奖励1是需要的积分，2号位是实际奖励
        pointReward={20,{p={p20=1,p13=1},}}
        },   
    },



    -- 轮盘之约
wheelFortune3={
	multiSelectType=true,
	[1]={
		type=1,
		sortId=62,
		serverreward={
			r={
			{props_p284=2,props_p36=2},
			{props_p284=1,props_p36=2},
			{props_p283=3,props_p36=2},
			{props_p283=2,props_p30=5},
			{props_p283=2,props_p30=5},
			{props_p283=1,props_p30=3},
			{props_p283=1,props_p30=3},
			{props_p283=1,props_p30=3},
			{props_p283=1,props_p30=3},
			{props_p283=1,props_p30=3},
			},
			pool={{100},{11,11,11,11,8,2,10,10,10,10,4,2,},{{"accessory_p4",100},{"accessory_p3",1},{"accessory_p2",1},{"accessory_p1",1},{"props_p30",1},{"accessory_p5",1},{"accessory_p4",500},{"accessory_p3",5},{"accessory_p2",5},{"accessory_p1",5},{"props_p36",1},{"accessory_p6",1},}},
			res4point={
				{1,3},
				{1,3},
				{2,4},
				{4,6},
				{3,5},
				{10,12},
				{4,6},
				{2,4},
				{10,12},
				{20,22},
				{12,14},
				{2,4},
			},
			rankPoint=300,
			lotteryConsume_1x=58,
			lotteryConsume_10x=528,
			pointReward={20,{props_p20=1,props_p13=1}}
		},
		reward={
		r={
		{p={p284=2,p36=2}},--1
		{p={p284=1,p36=2}},--2
		{p={p283=3,p36=2}},--3
		{p={p283=2,p30=5}},--4~5
		{p={p283=1,p30=3}},--6~10
		},
		--奖池
		pool={e={{p4=100,index=1},{p3=1,index=2},{p2=1,index=3},{p1=1,index=4},{p5=1,index=6},{p4=500,index=7},{p3=5,index=8},{p2=5,index=9},{p1=5,index=10},{p6=1,index=12},},p={{p30=1,index=5},{p36=1,index=11},}},
		res4point={
		{1,3},
		{1,3},
		{2,4},
		{4,6},
		{3,5},
		{10,12},
		{4,6},
		{2,4},
		{10,12},
		{20,22},
		{12,14},
		{2,4},
		},
		rankPoint=300,
		lotteryConsume_1x=58,
		lotteryConsume_10x=528,
		pointReward={20,{p={p20=1,index=1},{p13=1,index=2}}}
		},
	},
	[2]={																																
		type=1,																															
		sortId=62,																															
		serverreward={																															
			r={																														
				{	props_p284=2	,	props_p36=2	},																									
				{	props_p284=1	,	props_p36=2	},																									
				{	props_p283=3	,	props_p36=2	},																									
				{	props_p283=2	,	props_p30=5	},																									
				{	props_p283=2	,	props_p30=5	},																									
				{	props_p283=1	,	props_p30=3	},																									
				{	props_p283=1	,	props_p30=3	},																									
				{	props_p283=1	,	props_p30=3	},																									
				{	props_p283=1	,	props_p30=3	},																									
				{	props_p283=1	,	props_p30=3	},																									
			},																														
			pool={{100},{	1,	12,	12,	12,	1,	5,	8,	8,	8,	8,	13,	12,	},	{	{"props_p230",1},	{"accessory_p3",20},	{"accessory_p2",2},	{"accessory_p1",1},	{"props_p96",1},	{"accessory_p5",1},	{"accessory_p4",500},	{"accessory_p3",10},	{"accessory_p2",5},	{"accessory_p1",5},	{"props_p36",1},	{"accessory_p6",1},	}},			
			res4point={																														
				{	24,26	},																											
				{	8,10	},																											
				{	4,6	},																											
				{	4,6	},																											
				{	26,28	},																											
				{	10,12	},																											
				{	4,6	},																											
				{	4,6	},																											
				{	10,12	},																											
				{	20,22	},																											
				{	12,14	},																											
				{	2,4	},																											
			},																														
			rankPoint=	300	,																												
			lotteryConsume_1x=	88	,																												
			lotteryConsume_10x=	828	,																												
			pointReward={20,{props_p20=1,props_p13=1}}																														
		},																															
		reward={																															
			r={																														
				{	p={p284=2	,	p36=2	}},	--1																								
				{	p={p284=1	,	p36=2	}},	--2																								
				{	p={p283=3	,	p36=2	}},	--3																								
				{	p={p283=2	,	p30=5	}},	--4~5																								
				{	p={p283=1	,	p30=3	}},	--6~10																								
			},																														
			--奖池																														
			pool={	e={	{p3=20,index=2},	{p2=2,index=3},	{p1=1,index=4},	{p5=1,index=6},	{p4=500,index=7},	{p3=10,index=8},	{p2=5,index=9},	{p1=5,index=10},	{p6=1,index=12},},	p={{p230=1,index=1},	{p96=1,index=5},	{p36=1,index=11},	}},																
			res4point={																														
				{	24,26	},																											
				{	8,10	},																											
				{	4,6	},																											
				{	4,6	},																											
				{	26,28	},																											
				{	10,12	},																											
				{	4,6	},																											
				{	4,6	},																											
				{	10,12	},																											
				{	20,22	},																											
				{	12,14	},																											
				{	2,4	},																											
			},																														
			rankPoint=300,																												
			lotteryConsume_1x=88,																												
			lotteryConsume_10x=828,																												
			pointReward={20,{p={p20=1,index=1},{p13=1,index=2}}}																														
		},																															
	},																																
															

},

    -- 坦克轮盘（北美实物奖励，坦克驾驶体验steelavenger）
    wheelFortune4={
        type=1,
        sortID=180,
        serverreward = {
            zonePool = {
                [1]={{100},{1,1,2},{{"props_p293",1},{"props_p294",1},{"props_p295",1},},},
                [2]={{100},{0,1,3},{{"props_p293",1},{"props_p294",1},{"props_p295",1},},},
            },
            ranksort={props_p293=1,props_p294=2,props_p295=3},
            luckchance=5,   -- 2%的概率可以出超级幸运儿
            poolReward={{100},{14,14,8,14,9,9,9,9,14,},{{"props_p19",2},{"props_p13",1},{"props_p20",1},{"props_p25",1},{"troops_a10003",1},{"troops_a10013",1},{"troops_a10023",1},{"troops_a10033",1},{"userinfo_exp",5000},}},
        },
        pool={p={{p293=1,index=10},{p294=1,index=11},{p295=1,index=12},{p19=2,index=1},{p13=1,index=2},{p20=1,index=3},{p25=1,index=4},},o={{a10003=1,index=5},{a10013=1,index=6},{a10023=1,index=7},{a10033=1,index=8},},u={{exp=5000,index=9},}},
        startTime={f1={11,30},f2={18,30}},    -- 在线起始时间(送领奖次数)
        durationTime = 1800,    -- 在线送'领奖次数'持续时长
        lotteryConsume=400, -- 抽奖消耗的金币数
        propConsume = {"p296",1}, -- 投资消耗的道具与数量
    },


        -- 每日充值送礼
        dayRecharge={
            multiSelectType=true,
            [1]={ --原版本
                type=1,
                sortId = 70,
                version=1,
                serverreward = {
                    r={
                        {props_p20=1,props_p13=1,},--统率书*1加速前行*1
                        {props_p20=3,props_p12=1,},--统率书*3热核炸药*1
                        {props_p20=5,props_p2=1,},--统率书*5小型资源箱*1
                        {props_p20=10,props_p5=2,},--统率书*10加速生产*2
                    },
                },
                reward = {
                    {p={{p20=1,index=1},{p13=1,index=2}}},
                    {p={{p20=3,index=1},{p12=1,index=2}}},
                    {p={{p20=5,index=1},{p2=1,index=2}}},
                    {p={{p20=10,index=1},{p5=2,index=2}}},
                },
                cost={160,960,3420,8400},
            },
            [2]={ --原俄罗斯版本
                type=1,
                sortId = 70,
                version=2,
                serverreward = {
                    r={
                        {props_p47=1,props_p12=1,},--幸运币*1热核炸药*1
                        {props_p20=4,props_p17=1,},--统率书*4空中支援*1
                        {props_p20=6,props_p5=2,},--统率书*6加速生产*2
                        {props_p20=12,props_p3=1,},--统率书*12中型资源箱*1
                    },
                },
                reward = {
                    {p={{p47=1,index=1},{p12=1,index=2}}},
                    {p={{p20=4,index=1},{p17=1,index=2}}},
                    {p={{p20=6,index=1},{p5=2,index=2}}},
                    {p={{p20=12,index=1},{p3=1,index=2}}},
                },
                cost={200,900,2500,5800},
            },
            [3]={ --360周年回馈
                type=1,
                sortId = 70,
                version=3,
                serverreward = {
                    r={
                        {props_p627=1,props_p601=10,},--初级决战心得*1精锐勋章*10
                        {props_p611=1,props_p601=20,},--装甲作战学说*1精锐勋章*20
                        {props_p447=5,props_p601=40,},--中级将领经验书*5精锐勋章*40
                        {props_p448=2,props_p601=80,},--高级将领经验书*2精锐勋章*80
                    },
                },
                reward = {
                    {p={{p627=1,index=1},{p601=10,index=2}}},
                    {p={{p611=1,index=1},{p601=20,index=2}}},
                    {p={{p447=5,index=1},{p601=40,index=2}}},
                    {p={{p448=2,index=1},{p601=80,index=2}}},
                },
                cost={160,960,3420,8400},
            },
		
			[4]={	 --后期版本充值送船					
				type=1,						
				sortId = 70,						
				version=4,						
				serverreward = {						
					r={						
						{	troops_a10082=5,	props_p13=1,	},	--辽宁级航空母舰*5	加速前行*1	
						{	troops_a10082=10,	props_p12=1,	},	--辽宁级航空母舰*10	热核炸药*1	
						{	troops_a10082=15,	props_p11=1,	},	--辽宁级航空母舰*15	小型能量盾*1	
						{	troops_a10082=20,	props_p42=1,	},	--辽宁级航空母舰*20	高能火药*1	
					},						
				},						
				reward = {						
					{	o={{	a10082=5,index=1}	},p={{	p13=1,index=2}	}},	
					{	o={{	a10082=10,index=1}	},p={{	p12=1,index=2}	}},	
					{	o={{	a10082=15,index=1}	},p={{	p11=1,index=2}	}},	
					{	o={{	a10082=20,index=1}	},p={{	p42=1,index=2}	}},	
				},						
				cost={	160,	960,	3420,	8400	},													
			},		
			[5]={	 --增加一个最高充值档					
				type=1,						
				sortId = 70,						
				version=5,						
				serverreward = {						
					r={						
					{	props_p20=1,	props_p13=1,	},	--统率书*1	加速前行*1	
					{	props_p20=3,	props_p12=1,	},	--统率书*3	热核炸药*1	
					{	props_p20=5,	props_p2=1,	},	--统率书*5	小型资源箱*1	
					{	props_p20=10,	props_p5=2,	},	--统率书*10	加速生产*2	
					{	props_p20=20,	troops_a10082=50,	},	--统率书*20	辽宁级航空母舰*50	
					},						
				},						
				reward = {						
					{	p={{	p20=1,index=1}	,{	p13=1,index=2}	}},	
					{	p={{	p20=3,index=1}	,{	p12=1,index=2}	}},	
					{	p={{	p20=5,index=1}	,{	p2=1,index=2}	}},	
					{	p={{	p20=10,index=1}	,{	p5=2,index=2}	}},	
					{	p={{	p20=20,index=1}}	,o={{	a10082=50,index=2}	}},
				},						
				cost={	160,	960,	3420,	8400,	25200	},
									
			},						

        },

     --每日充值送礼(装备)（军备升级）
    dayRechargeForEquip={
        multiSelectType= true,
        [1]={ --老版本
        type=1,
        sortId = 71,
        version=1,
        serverreward = {
        r={
            {props_p88=1,props_p25=5,},--普通配件箱*1少量水晶*5
            {accessory_p6=3,props_p41=1,},--工具箱*3中型水晶开采*1
            {props_p266=1,props_p20=10,},--精良碎片箱*1统率书*10
            {accessory_f0=1,accessory_p1=5,},--万能碎片*1设计蓝图*5
            },
        },
        reward = {
            {p={{p88=1,index=1},{p25=5,index=2}}},
            {e={{p6=3,index=1}},p={{p41=1,index=2}}},
            {p={{p266=1,index=1},{p20=10,index=2}}},
            {e={{f0=1,index=1},{p1=5,index=2}}},
        },
        cost={160,960,3420,8400},
        },
        [2]={ --投放7,8先进碎片
            type=1,
            sortId = 71,
            version=2,
            serverreward = {
            r={
                {props_p20=1,props_p12=1,},--统率书*1热核炸药*1
                {props_p20=4,props_p17=1,},--统率书*4空中支援*1
                {props_p815=1,accessory_p6=20,},--4号精良碎片箱*1工具箱*20
                {props_p816=1,props_p672=20,},--4号先进碎片箱*1配件改造包*20
                },
            },
            reward = {
                {p={{p20=1,index=1},{p12=1,index=2}}},
                {p={{p20=4,index=1},{p17=1,index=2}}},
                {p={{p815=1,index=1}},e={{p6=20,index=2}}},
                {p={{p816=1,index=1},{p672=20,index=2}}},
            },
            cost={160,960,3420,8400},
        },

    },

    -- 开服七天战力大比拼
    fightRank = {
	multiSelectType = true,
	[1]={
        type=1,
			sortId = 73,
			serverreward={
				box = {
					{userinfo_gems=3888},
					{userinfo_gems=1888},
					{userinfo_gems=888},
					{userinfo_gems=588},
					{userinfo_gems=588},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},

				},
			},
		},
	[2]={
        type=1,
			sortId = 73,
			serverreward={
				box = {
					{userinfo_gems=3888,userinfo_honors=600},
					{userinfo_gems=1888,userinfo_honors=500},
					{userinfo_gems=888,userinfo_honors=300},
					{userinfo_gems=588},
					{userinfo_gems=588},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=388},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=188},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},
					{userinfo_gems=88},

				},
				allCanGet={
					{fight=20000,r={userinfo_gems=10}},
					{fight=30000,r={userinfo_gems=20}},
					{fight=50000,r={userinfo_gems=50}},
				},
			},
		},
	},

    -- 新手主基地冲级送礼
    baseLeveling = {
        type = 1,
	sortId = 75,
         serverreward={
            box = {
                [3]={props_p19=1},
                [5]={userinfo_gems=5,props_p19=3},
                [10]={userinfo_gems=10,props_p19=5},
                [15]={userinfo_gems=15,props_p19=10},
                [16]={userinfo_gems=20,props_p20=1},
                [17]={userinfo_gems=25,props_p20=1},
                [18]={userinfo_gems=30,props_p20=2},
                [19]={userinfo_gems=40,props_p20=3},
                [20]={userinfo_gems=50,props_p20=5,props_p5=1},
            },
        },
        reward = {
                {lv = 3, award={p={{p19=1,index=1}}}},
                {lv = 5, award={u={{gems=5,index=1}},p={{p19=3,index=2}}}},
                {lv = 10, award={u={{gems=10,index=1}},p={{p19=5,index=2}}}},
                {lv = 15, award={u={{gems=15,index=1}},p={{p19=10,index=2}}}},
                {lv = 16, award={u={{gems=20,index=1}},p={{p20=1,index=2}}}},
                {lv = 17, award={u={{gems=25,index=1}},p={{p20=1,index=2}}}},
                {lv = 18, award={u={{gems=30,index=1}},p={{p20=2,index=2}}}},
                {lv = 19, award={u={{gems=40,index=1}},p={{p20=3,index=2}}}},
                {lv = 20, award={u={{gems=50,index=1}},p={{p20=5,index=2},{p5=1,index=3}}}},
        }
    },
	--绑定活动
		bindbaseLeveling = {						
			type = 1,						
			--是否有领奖时间0,无,1为1天						
			rewardTime=0,						
			--从注册开始第几天						
			bindTime={0,7},						
			sortId = 75,						
			serverreward={						
			box={						
			[3]={	props_p19=1,	props_p3406=1,		},		
			[5]={	userinfo_gems=5,	props_p19=3,	props_p3406=2,	},		
			[10]={	userinfo_gems=10,	props_p19=5,	props_p3406=2,	},		
			[15]={	userinfo_gems=15,	props_p19=10,	props_p3407=2,	},		
			[16]={	userinfo_gems=20,	props_p20=1,	props_p3407=3,	},		
			[17]={	userinfo_gems=25,	props_p20=1,	props_p3407=4,	},		
			[18]={	userinfo_gems=30,	props_p20=2,	props_p3408=2,	},		
			[19]={	userinfo_gems=40,	props_p20=3,	props_p3408=3,	},		
			[20]={	userinfo_gems=50,	props_p20=5,	props_p3409=1,	},		
			},						
			},						
			reward={						
			{lv=3,	award={	p={	{p19=1,index=1},	{p3406=1,index=2},		}}},
			{lv=5,	award={	u={	{gems=5,index=1},	},p={{p19=3,index=2},	{p3406=2,index=3},	}}},
			{lv=10,	award={	u={	{gems=10,index=1},	},p={{p19=5,index=2},	{p3406=2,index=3},	}}},
			{lv=15,	award={	u={	{gems=15,index=1},	},p={{p19=10,index=2},	{p3407=2,index=3},	}}},
			{lv=16,	award={	u={	{gems=20,index=1},	},p={{p20=1,index=2},	{p3407=3,index=3},	}}},
			{lv=17,	award={	u={	{gems=25,index=1},	},p={{p20=1,index=2},	{p3407=4,index=3},	}}},
			{lv=18,	award={	u={	{gems=30,index=1},	},p={{p20=2,index=2},	{p3408=2,index=3},	}}},
			{lv=19,	award={	u={	{gems=40,index=1},	},p={{p20=3,index=2},	{p3408=3,index=3},	}}},
			{lv=20,	award={	u={	{gems=50,index=1},	},p={{p20=5,index=2},	{p3409=1,index=3},	}}},
			},						
			flick={						
			{						},
			{						},
			{						},
			{						},
			{						},
			{						},
			{						},
			{						},
			{	p={			p3409=3,	},	},
			},						
			},						

			
				
						

	--绑定活动每日充值送好礼
		bindDayRecharge ={						
		--持续时间						
		bindTime={0,7},						
		rewardTime=0,						
		reward={						
		[1]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p6=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=10,index=3},	{p12=2,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p6=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=10,	props_p12=2,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
		flick={						
		{						},
		{						},
		{	p={	p4603=3,	p54=3,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
								
		[2]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p7=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=10,index=3},	{p13=4,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p7=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=10,	props_p13=4,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
								
		flick={						
		{						},
		{						},
		{	p={	p4603=3,	p54=3,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
								
		[3]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p8=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=15,index=3},	{p14=2,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p8=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=15,	props_p14=2,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
								
		flick={						
		{						},
		{						},
		{	p={	p4603=3,	p54=3,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
								
		[4]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p9=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=15,index=3},	{p15=2,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p9=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=15,	props_p15=2,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
								
		flick={						
		{						},
		{						},
		{	p={	p4603=3,	p54=3,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
								
		[5]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p10=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=15,index=3},	{p11=2,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p10=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=15,	props_p11=2,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
								
		flick={						
		{						},
		{						},
		{	p={	p4603=3,	p54=3,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
								
		[6]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p6=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=15,index=3},	{p12=2,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p6=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=15,	props_p12=2,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
								
		flick={						
		{						},
		{						},
		{	p={	p4603=2,	p54=2,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
								
		[7]={						
		reward={						
		{	p={	{p21=2,index=1},	{p22=2,index=2},	{p23=2,index=3},	{p24=2,index=4},	}},
		{	p={	{p4602=1,index=1},	{p20=2,index=2},	{p19=2,index=3},	{p7=1,index=4},	}},
		{	p={	{p4603=2,index=1},	{p54=1,index=2},	{p20=15,index=3},	{p13=4,index=4},	}},
		{	p={	{p4604=1,index=1},	{p55=1,index=2},	{p43=1,index=3},	{p4=1,index=4},	}},
		},						
		cost={50,300,2000,8400},						
		serverreward={						
		r={						
			{	props_p21=2,	props_p22=2,	props_p23=2,	props_p24=2,	},
			{	props_p4602=1,	props_p20=2,	props_p19=2,	props_p7=1,	},
			{	props_p4603=2,	props_p54=1,	props_p20=15,	props_p13=4,	},
			{	props_p4604=1,	props_p55=1,	props_p43=1,	props_p4=1,	},
		 },						
		 },						
								
		flick={						
		{						},
		{						},
		{	p={	p4603=3,	p54=3,		},	},
		{	p={	p4604=2,	p55=2,		},	},
		},						
		 },						
		},						
		},						
					
					

			--绑定活动,累计充值
		bindTotalRecharge ={					
							
			bindTime={0,7},					
			rewardTime=0,					
			type=1,					
			sortId=80,					
			serverreward={					
			r = {					
				{	troops_a10014=5,	props_p19=2,	props_p3401=5,	props_p3=1,	},
				{	troops_a10024=10,	props_p19=15,	props_p3402=5,	props_p4=1,	},
				{	props_p4603=1,	troops_a10004=15,	props_p3403=5,	props_p4=2,	},
				{	props_p4603=2,	troops_a10004=25,	props_p3404=3,	props_p4=2,	},
				{	props_p4603=2,	troops_a10034=25,	props_p3404=6,	props_p4=3,	},
				{	armor_m23=1,	troops_a10034=30,	props_p3404=8,	props_p4=3,	},
			},					
			cost={1000,5000,10000,20000,35000,60000},					
								
			},					
		},					
				
				
				
				
				

			--绑定活动,限时商店
			bindrestricted={
			bindTime={0,3},
			rewardTime=0,
			props={
			p1=0.8,
			p863=0.8,
			p20=0.8,
			p4=0.5,
			p3=0.5,
			p2=0.5,
			},
			maxCount={
			p1=2,
			p863=2,
			p20=50,
			p4=5,
			p3=5,
			p2=50,
			},
			flick={
			p={p1=2,
			p863=2,
			p20=2,
			p4=3,


			}},
			},


	
	--绑定活动,连续充值	--1,黄色,2紫色,3蓝色						
	--1,黄色,2紫色,3蓝色				
	bindcontinueRecharge={						
				bindTime={0,7},						
				rewardTime=0,						
										
				reward={						
				{	o={	{a10003=5,index=1},	{a10013=5,index=2},	},p={{p3=1,index=3},	{p6=1,index=4},	}},
				{	o={	{a10023=5,index=1},	{a10033=5,index=2},	},p={{p3=1,index=3},	{p7=1,index=4},	}},
				{	o={	{a10003=5,index=1},	{a10023=5,index=2},	},p={{p3=1,index=3},	{p8=1,index=4},	}},
				{	o={	{a10013=5,index=1},	{a10033=5,index=2},	},p={{p3=1,index=3},	{p9=1,index=4},	}},
				{	o={	{a10013=5,index=1},	{a10023=5,index=2},	},p={{p3=1,index=3},	{p10=1,index=4},	}},
				{	o={	{a10003=5,index=1},	{a10033=5,index=2},	},p={{p3=1,index=3},	{p10=1,index=4},	}},
				{	o={	{a10033=5,index=1},	{a10013=5,index=2},	},p={{p3=1,index=3},	{p10=1,index=4},	}},
				},						
				dC={500,500,500,500,500,500,500},						
				serverreward={						
				r={						
					{	troops_a10003=5,	troops_a10013=5,	props_p3=1,	props_p6=1,	},
					{	troops_a10023=5,	troops_a10033=5,	props_p3=1,	props_p7=1,	},
					{	troops_a10003=5,	troops_a10023=5,	props_p3=1,	props_p8=1,	},
					{	troops_a10013=5,	troops_a10033=5,	props_p3=1,	props_p9=1,	},
					{	troops_a10013=5,	troops_a10023=5,	props_p3=1,	props_p10=1,	},
					{	troops_a10003=5,	troops_a10033=5,	props_p3=1,	props_p10=1,	},
					{	troops_a10033=5,	troops_a10013=5,	props_p3=1,	props_p10=1,	},
				},						
				endserverward={						
					{	armor_m22=1,	troops_a10033=10,	troops_a10013=10,	props_p45=1,	},
				},						
				},						
										
				--连续充值天数						
				continueDay=7,						
				--终极大奖						
				bR={						
					am={	{m22=1,index=1},	},o={{a10033=10,index=2},	{a10013=10,index=3},	},p={{p45=1,index=4},	},
				},						
				flick={						
				{						},
				{						},
				{						},
				{						},
				{						},
				{						},
				{						},
				},						
				endflick={						
					am={	m22=2,				},
				},						
				},						


    -- 军团充级活动
    allianceLevel = {
        type = 1,
        sortId = 80,
        serverreward={
            box={
                {commander={props_p19=60,userinfo_gems=500},members={props_p19=40,props_p5=1}},
                {commander={props_p19=40,userinfo_gems=300},members={props_p19=30,props_p43=1}},
                {commander={props_p19=30,userinfo_gems=200},members={props_p19=20,props_p42=1}},
                {commander={props_p19=20,userinfo_gems=100},members={props_p19=10,props_p11=1}},
                {commander={props_p19=20,userinfo_gems=100},members={props_p19=10,props_p11=1}},
                {commander={props_p19=10,userinfo_gems=50},members={props_p19=3,props_p47=1}},
                {commander={props_p19=10,userinfo_gems=50},members={props_p19=3,props_p47=1}},
                {commander={props_p19=10,userinfo_gems=50},members={props_p19=3,props_p47=1}},
                {commander={props_p19=10,userinfo_gems=50},members={props_p19=3,props_p47=1}},
                {commander={props_p19=10,userinfo_gems=50},members={props_p19=3,props_p47=1}},
            },
        },
    },
        -- 军团战力活动
    allianceFight = {
        type = 1,
        sortId = 80,
        serverreward={
            box={
                [1]={userinfo_gems=600},
                [2]={userinfo_gems=300},
                [3]={userinfo_gems=200},
            },
        },
    },

    -- vip冲级送豪礼
    userVip = {
        type = 1,
        sortId = 80,
        serverreward={
            box={
                [1]={props_p47=1,},
                [2]={props_p47=2,props_p19=2,},
                [3]={props_p47=3,props_p19=2,props_p20=1,},
                [4]={props_p20=5,props_p19=10,props_p12=3,},
                [5]={props_p20=5,props_p19=10,props_p2=1,},
                [6]={props_p20=10,props_p19=20,props_p2=2,props_p15=10,},
                [7]={props_p20=20,props_p19=100,props_p2=8,props_p16=3,},
                [8]={props_p20=30,props_p19=300,props_p4=3,props_p42=10,},
                [9]={props_p20=50,props_p19=500,props_p4=10,props_p5=20,},
            },
        },
    },
        --个人荣誉
    personalHonor = {
        type = 1,
        sortId = 80,
        serverreward={
            box={
                [1]={props_p20=20,troops_a10004=20,}, 
                [2]={props_p20=15,troops_a10004=15,}, 
                [3]={props_p20=10,troops_a10004=10,}, 
                [4]={props_p20=5,troops_a10004=5,}, 
                [5]={props_p20=5,troops_a10004=5,}, 
                [6]={props_p20=3,troops_a10004=3,}, 
                [7]={props_p20=3,troops_a10004=3,}, 
                [8]={props_p20=3,troops_a10004=3,}, 
                [9]={props_p20=3,troops_a10004=3,}, 
                [10]={props_p20=3,troops_a10004=3,}, 

            },
        },
    },

            --个人关卡

    personalCheckPoint = {
	multiSelectType = true,
	[1]={
        type = 1,
        sortId = 80,
        serverreward={
            box={
                [1]={userinfo_gems=500,userinfo_honors=800,}, 
                [2]={userinfo_gems=300,userinfo_honors=500,}, 
                [3]={userinfo_gems=200,userinfo_honors=300,}, 
                [4]={userinfo_gems=100,userinfo_honors=200,}, 
                [5]={userinfo_gems=100,userinfo_honors=200,}, 
            },
			
        },
    },
	[2]={
        type = 1,
        sortId = 80,
        serverreward={
            box={
                [1]={userinfo_gems=500,userinfo_honors=800,}, 
                [2]={userinfo_gems=300,userinfo_honors=500,}, 
                [3]={userinfo_gems=200,userinfo_honors=300,}, 
                [4]={userinfo_gems=100,userinfo_honors=200,}, 
                [5]={userinfo_gems=100,userinfo_honors=200,}, 
            },
				allCanGet={
					{star=96,r={userinfo_gems=30,userinfo_honors=50,}},

				},			
        },
    },	
	},

    --累计充值
    totalRecharge = {
        multiSelectType= true,
        [1]=
		{
			type = 1,
			sortId = 80,
			serverreward={
				 r = {
					{props_p89=1,props_p10=3,},--精良配件箱*1小型水晶开采*3 
					{accessory_p6=5,accessory_p2=10,},--工具箱*5神秘矿物*10 
					{props_p89=5,accessory_p3=15,},--精良配件箱*5电钻*15 
					{accessory_f0=2,props_p1 =1,},--万能碎片*2荣誉勋章包*1 
					{props_p90=2,props_p20=10,},--先进配件箱*2统率书*10 
				},
				cost = {1000,3000,9000,17000,26000},
			},
		},
        [2]= --送蓝配					
		{			
			type = 1,		
			sortId = 80,		
			serverreward={		
				 r = {	
					{props_p89=5,accessory_p6=3,},--精良配件箱*5工具箱*5
					{props_p89=5,accessory_p2=10,},--精良配件箱*5神秘矿物*10 
					{props_p89=5,accessory_p3=15,},--精良配件箱*5电钻*15 
					{props_p269=5,accessory_p5=1,},--弗利特的精良配件箱*5复原图纸*5 
					{props_p565=5,accessory_p1=10,},--弗利特的精良配件箱改*5舰船蓝图*10 
				},	
				cost = {1000,3000,5000,7000,9000},	
			},		
		},		
		[3]= --送军徽					
		{			
			type = 1,		
			sortId = 80,		
			serverreward={		
				 r = {	
				 {props_p4003=3,props_p19=5,},--基础进阶图纸（初级进阶图纸）*3,荣誉勋章*5
				 {props_p4004=3,props_p19=10,},--普通进阶图纸（中级进阶图纸）*3,荣誉勋章*10
				 {props_p4005=1,props_p20=10,},--精良进阶图纸（高级进阶图纸）*1,统率书*10
				 {props_p4005=2,props_p4001=500,},--精良进阶图纸（高级进阶图纸）*2,军徽部件（装备原件）*500
				 {sequip_e111=1,props_p4002=1,},--急速军徽0*1,高级军徽部件（高级装备原件）*1,
				},	
				cost = {10,460,960,1920,3420},	
			},		
		},		
		[4]= --送矩阵				
		{				
			type = 1,				
			sortId = 80,				
				serverreward={				
				r={				
								
					{	props_p4603=1,		armor_exp=500,	},
					{	props_p4605=1,		armor_exp=1000,	},
					{	props_p4605=1,		armor_exp=2500,	},
					{	props_p4604=1,		armor_exp=2500,	},
					{	props_p4606=2,		armor_exp=2500,	},
				},				
				cost = {1000,3000,5000,7000,9000},				
			},				
		},	
		[5]= --送橙色超级装备（电磁轨道炮）（高返利比）											
		{									
			type = 1,								
			sortId = 80,								
			serverreward={								
				 r = {							
				 {props_p19=5,props_p4001=20,},--荣誉勋章*5，装备原件*20							
				 {props_p19=10,props_p4001=180,},--荣誉勋章*10，装备原件*180							
				 {props_p20=10,props_p4001=300,},--统率书*10，装备原件*300							
				 {props_p4005=2,props_p4001=500,},--高级进阶图纸*2,装备原件*500							
				 {sequip_e73=1,props_p4002=1,},--电磁轨道炮*1,高级装备原件*1,							
				},							
				cost = {10,460,960,3420,8400},							
			},								
		},									
											
        [6]= --送橙色超级装备（海神之戟）											
		{									
			type = 1,								
			sortId = 80,								
			serverreward={								
				 r = {							
				 {props_p19=5,props_p4001=50,},--荣誉勋章*5，装备原件*50							
				 {props_p19=10,props_p4001=200,},--荣誉勋章*10，装备原件*200							
				 {props_p20=10,props_p4001=350,},--统率书*10，装备原件*350							
				 {props_p4005=2,props_p4001=600,},--高级进阶图纸*2,装备原件*600							
				 {sequip_e53=1,props_p4002=1,},--海神之戟*1,高级装备原件*1,							
				},							
				cost = {50,960,3420,8400,16800},							
			},								
		},									

		[7]= --送军用计算机													
		{											
			type = 1,										
			sortId = 80,										
			serverreward={										
				 r = {									
				 {props_p4003=3,props_p19=5,},--基础进阶图纸（初级进阶图纸）*3,荣誉勋章*5									
				 {props_p4004=3,props_p19=10,},--普通进阶图纸（中级进阶图纸）*3,荣誉勋章*10									
				 {props_p4005=1,props_p20=10,},--精良进阶图纸（高级进阶图纸）*1,统率书*10									
				 {props_p4005=2,props_p4001=500,},--精良进阶图纸（高级进阶图纸）*2,军徽部件（装备原件）*500									
				 {sequip_e132=1,props_p4002=1,},--军用计算机*1,高级军徽部件（高级装备原件）*1,									
				},									
				cost = {10,460,960,1920,3420},									
			},										
		},	
		
        [8]= --送三星马瑞娜												
		{										
			type = 1,									
			sortId = 80,									
			serverreward={									
				 r = {								
				 {props_p601=10,props_p20=2,},--精锐勋章*10，统率书*2								
				 {props_p601=20,props_p19=20,},--精锐勋章*20，荣誉勋章*20								
				 {props_p613=10,props_p621=10,},--迂回打击学说*10，初级指挥心得*10								
				 {props_p611=15,props_p627=15,},--大国海权学说*15，初级决战心得*15								
				 {hero_h27=3,props_p601=50,},--三星马瑞娜*1,精锐勋章*50								
				},								
				cost = {50,460,960,1920,3888},								
			},									
		},										
												
        [9]= --送三星瑟德梅特												
		{										
			type = 1,									
			sortId = 80,									
			serverreward={									
				 r = {								
				 {props_p601=10,props_p20=2,},--精锐勋章*10，统率书*2								
				 {props_p601=20,props_p19=20,},--精锐勋章*20，荣誉勋章*20								
				 {props_p613=10,props_p621=10,},--迂回打击学说*10，初级指挥心得*10								
				 {props_p611=15,props_p627=15,},--大国海权学说*15，初级决战心得*15								
				 {hero_h6=3,props_p601=50,},--三星瑟德梅特*1,精锐勋章*50								
				},								
				cost = {50,460,960,1920,3888},								
			},									
		},										
												
        [10]= --送加速道具											
		{									
			type = 1,								
			sortId = 80,								
			serverreward={								
				 r = {							
				 {props_p3403=1,},--120分钟建造加速*1							
				 {props_p3408=1,props_p3413=1,},--120分钟训练加速*1,120分钟研究加速*1							
				 {props_p3403=1,props_p3408=1,},--120分钟建造加速*1,120分钟训练加速*1							
				 {props_p3403=1,props_p3413=1,},--120分钟建造加速*1,120分钟研究加速*1							
				 {props_p3408=1,props_p3413=1,},--120分钟训练加速*1,120分钟研究加速*1							
				},							
				cost = {1000,3000,5000,7000,9000},							
			},								
		},									
        [11]= --送润滑剂						
		{				
			type = 1,			
			sortId = 80,			
			serverreward={			
				 r = {		
				 {alien_r6=20,},--润滑剂*20		
				 {alien_r6=25,alien_r1=500,},--润滑剂*25		
				 {alien_r6=30,alien_r2=300,},--润滑剂*30		
				 {alien_r6=45,alien_r4=300,},--润滑剂*45		
				 {alien_r6=70,alien_r5=400,},--润滑剂*70		
				},		
				cost = {900,1800,2700,4500,7200},		
			},			
		},				
        [12]= --送润滑剂							
		{					
			type = 1,				
			sortId = 80,				
			serverreward={				
				 r = {			
				 {alien_r6=40,},--润滑剂*40			
				 {alien_r6=45,alien_r1=1000,},--润滑剂*45			
				 {alien_r6=50,alien_r2=600,},--润滑剂*50			
				 {alien_r6=90,alien_r4=600,},--润滑剂*90			
				 {alien_r6=135,alien_r5=800,},--润滑剂*135			
				},			
				cost = {900,1800,2700,4500,7200},			
			},				
		},
        [13]= --送三星迈德希普											
		{									
			type = 1,								
			sortId = 80,								
			serverreward={								
				 r = {							
				 {props_p601=10,props_p20=2,},--精锐勋章*10，统率书*2							
				 {props_p601=20,props_p19=20,},--精锐勋章*20，荣誉勋章*20							
				 {props_p616=10,props_p621=10,},--猎杀集群学说*10，初级指挥心得*10							
				 {props_p611=15,props_p627=15,},--大国海权学说*15，初级决战心得*15							
				 {hero_h9=3,props_p601=50,},--3星迈德希普，精锐勋章*50							
				},							
				cost = {50,460,960,1920,3888},							
			},								
		},									
											
        [14]= --送三星利佛											
		{									
			type = 1,								
			sortId = 80,								
			serverreward={								
				 r = {							
				 {props_p601=10,props_p20=2,},--精锐勋章*10，统率书*2							
				 {props_p601=20,props_p19=20,},--精锐勋章*20，荣誉勋章*20							
				 {props_p613=10,props_p621=10,},--迂回打击学说*10，初级指挥心得*10							
				 {props_p611=15,props_p621=15,},--大国海权学说*15，初级指挥心得*15							
				 {hero_h32=3,props_p601=50,},--3星利佛，精锐勋章*50							
				},							
				cost = {50,460,960,1920,3888},							
			},								
		},	
        [15]= --7号紫配碎2个									
		{							
			type = 1,						
			sortId = 80,						
			serverreward={						
				 r = {					
				 {accessory_p1=2,accessory_p4=100,},--舰船蓝图*2，零件*100					
				 {accessory_p1=8,accessory_p3=10,},--舰船蓝图*8，组装工具*10					
				 {props_p269=1,accessory_p2=5,},--弗利特的精良配件箱*1，高能矿石*5					
				 {accessory_p5=6,accessory_p3=80,},--参考图纸*6，组装工具*80					
				 {props_p587=2,accessory_p4=1000,},--7号位可选先进碎片箱*2，零件*1000					
				},					
				cost = {50,460,960,1920,3888},					
			},						
	
		},	
        [16]= --5000钻送防护力场									
		{							
			type = 1,						
			sortId = 80,						
			serverreward={						
				 r = {					
				 {props_p19=5,props_p4001=20,},--荣誉勋章*5，装备原件*20					
				 {props_p19=10,props_p4001=180,},--荣誉勋章*10，装备原件*180					
				 {props_p20=10,props_p4001=300,},--统率书*10，装备原件*300					
				 {props_p4005=2,props_p4001=500,},--高级进阶图纸*2，装备原件*500					
				 {sequip_e63=1,props_p4002=1,},--防护力场*1，高级装备原件*1					
				},					
				cost = {50,500,1500,3000,5000},					
			},						
		},							
        [17]= --5000钻送AI指挥官										
		{								
			type = 1,							
			sortId = 80,							
			serverreward={							
				 r = {						
				 {props_p19=5,props_p4001=20,},--荣誉勋章*5，装备原件*20						
				 {props_p19=10,props_p4001=180,},--荣誉勋章*10，装备原件*180						
				 {props_p20=10,props_p4001=300,},--统率书*10，装备原件*300						
				 {props_p4005=2,props_p4001=500,},--高级进阶图纸*2，装备原件*500						
				 {sequip_e83=1,props_p4002=1,},--AI指挥官*1，高级装备原件*1						
				},						
				cost = {50,500,1500,3000,5000},						
			},							
		},								
        [18]= --送精工石										
		{								
			type = 1,							
			sortId = 80,							
			serverreward={							
				 r = {						
				 {props_p933=5,equip_e1=1000,},--精工石碎片*5，装备Exp*1000						
				 {props_p933=15,equip_e1=5000,},--精工石碎片*15，装备Exp*5000						
				 {props_p933=40,equip_e1=10000,},--精工石碎片*40，装备Exp*10000						
				 {props_p4900=1,equip_e1=20000,},--将领奖章讲义选择包*1，装备Exp*20000						
				 {props_p4900=1,props_p481=2,},--将领奖章讲义选择包*1，精工石*2						
				},						
				cost = {10,460,960,3420,8400},						
			},							
		},								
				
										
        [19]= --送矩阵经验									
		{							
			type = 1,						
			sortId = 80,						
			serverreward={						
				 r = {					
				 {armor_exp=5000,},--装甲经验*5000					
				 {armor_exp=10000,},--装甲经验*10000					
				 {armor_exp=20000,},--装甲经验*20000					
				 {armor_exp=30000,},--装甲经验*30000					
				 {armor_exp=50000,},--装甲经验*50000					
				},					
				cost = {50,500,1500,3000,5000},					
			},						
		},							
        [20]= --送四星克莱克									
		{							
			type = 1,						
			sortId = 80,						
			serverreward={						
				 r = {					
				 {props_p601=10,props_p20=2,},--精锐勋章*10，统率书*2					
				 {props_p601=20,props_p19=20,},--精锐勋章*20，荣誉勋章*20					
				 {props_p611=10,props_p617=10,},--大国海权学说*10，海军火力学说*10					
				 {props_p657=20,props_p651=20,},--专家决战心得*20，专家指挥心得*20					
				 {hero_h15=4,props_p601=50,},--4星克莱克，精锐勋章*50					
				},					
				cost = {1000,3000,5000,7000,9000},					
			},						
		},							
							
										
        [21]= --送武装直升机									
		{							
			type = 1,						
			sortId = 80,						
			serverreward={						
				 r = {					
				 {props_p19=5,props_p4001=20,},--荣誉勋章*5，装备原件*20					
				 {props_p19=10,props_p4001=180,},--荣誉勋章*10，装备原件*180					
				 {props_p20=10,props_p4001=300,},--统率书*10，装备原件*300					
				 {props_p4005=2,props_p4001=500,},--高级进阶图纸*2，装备原件*500					
				 {sequip_e101=1,props_p4002=1,},--武装直升机*1，高级装备原件*1					
				},					
				cost = {50,460,960,1920,3888},					
			},						
		},							
        [22]= --送矩阵经验							
		{					
			type = 1,				
			sortId = 80,				
			serverreward={				
				 r = {			
				 {armor_exp=8000,},--装甲经验*8000			
				 {armor_exp=15000,},--装甲经验*15000			
				 {armor_exp=30000,},--装甲经验*30000			
				 {armor_exp=45000,},--装甲经验*45000			
				 {armor_exp=75000,},--装甲经验*75000			
				},			
				cost = {260,800,1800,3400,6000},			
			},				
		},					
        [23]= --高阶荣誉勋章										
		{								
			type = 1,							
			sortId = 80,							
			serverreward={							
				 r = {						
				 {props_p3302=5,props_p19=20,},--进阶荣誉勋章*5，荣誉勋章*20						
				 {props_p3302=10,props_p19=50,},--进阶荣誉勋章*10，荣誉勋章*50						
				 {props_p3302=20,props_p19=100,},--进阶荣誉勋章*20，荣誉勋章*100						
				 {props_p3303=2,props_p3302=10,},--高阶荣誉勋章*2，进阶荣誉勋章*10						
				 {props_p3303=8,props_p3302=20,},--高阶荣誉勋章*8，进阶荣誉勋章*20						
				},						
				cost = {260,900,1900,3400,8000},						
			},							
		},								

    },

    --七夕
    qixi = {
        multiSelectType= true,
        [1]=
        {
            type=1, 
            sortID=267,         
            reward={ -- 对应奖励
            {p={{p19=15,index=1}}},
            {p={{p19=20,index=1},{p89=1,index=2}}},
            {p={{p19=30,index=1},{p277=100,index=2}}},
            {p={{p20=5,index=1},{p276=20,index=2},{p278=3,index=3},{p247=20,index=4}}},
            {p={{p20=5,index=1},{p275=10,index=2},{p89=1,index=3},{p247=40,index=4}}},
            {p={{p279=25,index=1},{p90=1,index=2},{p247=60,index=3},{p230=1,index=4}}},

            },
            serverreward={
            {props_p19=15,},--荣誉勋章*15
            {props_p19=20,props_p89=1,},--荣誉勋章*20 精良配件箱*1
            {props_p19=30,props_p277=100,},--荣誉勋章*30 组装工具*100
            {props_p20=5,props_p276=20,props_p278=3,props_p247=20,},--统率书*5 高能矿石*20 参考图纸*3 声望级战列舰*20
            {props_p20=5,props_p275=10,props_p89=1,props_p247=40,},--统率书*5 舰船蓝图*10 精良配件箱*1 声望级战列舰*40
            {props_p279=25,props_p90=1,props_p247=60,props_p230=1,},--统率书*10 工具箱*10 先进配件箱*1 声望级战列舰*60 通用碎片*1
            },

            cost = {100,500,1000,3000,5000,10000}, -- 使用掉的钻石数量
        },

         [2]={ 
         type=1, 
         sortID=267, 
        reward={
        {p={{p19=20,index=1}}},
        {p={{p19=25,index=1},{p89=1,index=2}}},
        {p={{p19=30,index=1},{p282=2,index=2}}},
        {p={{p20=10,index=1},{p277=100,index=2},{p276=20,index=3},{p275=10,index=4}}},
        {p={{p20=15,index=1},{p90=1,index=2},{p278=10,index=3}},o={{a10035=50,index=4}}},
        {p={{p230=1,index=1},{p279=20,index=2}},o={{a10035=100,index=3},{a10082=100,index=4}}},
        },
        cost = {100,500,1000,3000,6000,18888},
        serverreward={
        {props_p19=20,},
        {props_p19=25,props_p89=1,},
        {props_p19=30,props_p282=2,},
        {props_p20=10,props_p277=100,props_p276=20,props_p275=10,},
        {props_p20=15,props_p90=1,props_p278=10,troops_a10035=50,},
        {props_p230=1,props_p279=20,troops_a10035=100,troops_a10082=100,},
        },
        },

    },

    -- 配件探索
    equipSearch = {
        multiSelectType = true,
        [1] = {
            type = 1,
            sortId = 90,
            version = 1,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {props_p90=2,accessory_f0=3}, -- 先进配件箱 * 2 万能碎片 * 3
                     {props_p90=1,accessory_f0=3}, -- 先进配件箱 * 1 万能碎片 * 3
                     {props_p90=1,accessory_f0=1}, -- 先进配件箱 * 1 万能碎片 * 1
                     {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                     {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的金币
                searchConsume_1x = 58,
                searchConsume_10x = 528,

                -- 资源对应的积分数
                res4point = {
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {6,10},
                    {6,10},
                    {3,5},
                },

                -- 奖池
                pool={
                    {100},
                    {10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,2,24,64,144},
                    {
                        {"props_p181",1},
                        {"props_p193",1},
                        {"props_p205",1},
                        {"props_p217",1},
                        {"props_p184",1},
                        {"props_p196",1},
                        {"props_p208",1},
                        {"props_p220",1},
                        {"props_p187",1},
                        {"props_p199",1},
                        {"props_p211",1},
                        {"props_p223",1},
                        {"props_p190",1},
                        {"props_p202",1},
                        {"props_p214",1},
                        {"props_p226",1},
                        {"props_p181",2},
                        {"props_p193",2},
                        {"props_p205",2},
                        {"props_p217",2},
                        {"props_p184",2},
                        {"props_p196",2},
                        {"props_p208",2},
                        {"props_p220",2},
                        {"props_p187",2},
                        {"props_p199",2},
                        {"props_p211",2},
                        {"props_p223",2},
                        {"props_p190",2},
                        {"props_p202",2},
                        {"props_p214",2},
                        {"props_p226",2},
                        {"props_p181",3},
                        {"props_p193",3},
                        {"props_p205",3},
                        {"props_p217",3},
                        {"props_p184",3},
                        {"props_p196",3},
                        {"props_p208",3},
                        {"props_p220",3},
                        {"props_p187",3},
                        {"props_p199",3},
                        {"props_p211",3},
                        {"props_p223",3},
                        {"props_p190",3},
                        {"props_p202",3},
                        {"props_p214",3},
                        {"props_p226",3},
                        {"props_p182",1},
                        {"props_p194",1},
                        {"props_p206",1},
                        {"props_p218",1},
                        {"props_p185",1},
                        {"props_p197",1},
                        {"props_p209",1},
                        {"props_p221",1},
                        {"props_p188",1},
                        {"props_p200",1},
                        {"props_p212",1},
                        {"props_p224",1},
                        {"props_p191",1},
                        {"props_p203",1},
                        {"props_p215",1},
                        {"props_p227",1},
                        {"accessory_f0",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                    },
                },

                -- 客户端用奖池
                clientpool={
                    {index=1,aid="f2",content={    p={ {p181=1,index=1,wz={6,10},},    {p193=1,index=2,wz={6,10},},    {p205=1,index=3,wz={6,10},},    {p217=1,index=4,wz={6,10},},    },},},  
                    {index=2,aid="f6",content={ p={ {p184=1,index=1,wz={6,10},},    {p196=1,index=2,wz={6,10},},    {p208=1,index=3,wz={6,10},},    {p220=1,index=4,wz={6,10},},    },},},  
                    {index=3,aid="f10",content={    p={ {p187=1,index=1,wz={6,10},},    {p199=1,index=2,wz={6,10},},    {p211=1,index=3,wz={6,10},},    {p223=1,index=4,wz={6,10},},    },},},  
                    {index=4,aid="f14",content={    p={ {p190=1,index=1,wz={6,10},},    {p202=1,index=2,wz={6,10},},    {p214=1,index=3,wz={6,10},},    {p226=1,index=4,wz={6,10},},    },},},  
                    {index=5,aid="p3",content={ e={ {p3=5,index=1,wz={3,5},},               },},},  
                    {index=6,aid="f18",content={    p={ {p181=2,index=1,wz={12,20},},   {p193=2,index=2,wz={12,20},},   {p205=2,index=3,wz={12,20},},   {p217=2,index=4,wz={12,20},},   },},},  
                    {index=7,aid="f22",content={    p={ {p184=2,index=1,wz={12,20},},   {p196=2,index=2,wz={12,20},},   {p208=2,index=3,wz={12,20},},   {p220=2,index=4,wz={12,20},},   },},},  
                    {index=8,aid="f26",content={    p={ {p187=2,index=1,wz={12,20},},   {p199=2,index=2,wz={12,20},},   {p211=2,index=3,wz={12,20},},   {p223=2,index=4,wz={12,20},},   },},},  
                    {index=9,aid="f30",content={    p={ {p190=2,index=1,wz={12,20},},   {p202=2,index=2,wz={12,20},},   {p214=2,index=3,wz={12,20},},   {p226=2,index=4,wz={12,20},},   },},},  
                    {index=10,aid="p2",content={    e={ {p2=2,index=1,wz={6,10},},              },},},  
                    {index=11,aid="f34",content={   p={ {p181=3,index=1,wz={18,30},},   {p193=3,index=2,wz={18,30},},   {p205=3,index=3,wz={18,30},},   {p217=3,index=4,wz={18,30},},   },},},  
                    {index=12,aid="f38",content={   p={ {p184=3,index=1,wz={18,30},},   {p196=3,index=2,wz={18,30},},   {p208=3,index=3,wz={18,30},},   {p220=3,index=4,wz={18,30},},   },},},  
                    {index=13,aid="f42",content={   p={ {p187=3,index=1,wz={18,30},},   {p199=3,index=2,wz={18,30},},   {p211=3,index=3,wz={18,30},},   {p223=3,index=4,wz={18,30},},   },},},  
                    {index=14,aid="f46",content={   p={ {p190=3,index=1,wz={18,30},},   {p202=3,index=2,wz={18,30},},   {p214=3,index=3,wz={18,30},},   {p226=3,index=4,wz={18,30},},   },},},  
                    {index=15,aid="p1",content={    e={ {p1=1,index=1,wz={6,10},},              },},},  
                    {index=16,aid="f51",content={   p={ {p182=1,index=1,wz={24,40},},   {p194=1,index=2,wz={24,40},},   {p206=1,index=3,wz={24,40},},   {p218=1,index=4,wz={24,40},},   },},},  
                    {index=17,aid="f55",content={   p={ {p185=1,index=1,wz={24,40},},   {p197=1,index=2,wz={24,40},},   {p209=1,index=3,wz={24,40},},   {p221=1,index=4,wz={24,40},},   },},},  
                    {index=18,aid="f59",content={   p={ {p188=1,index=1,wz={24,40},},   {p200=1,index=2,wz={24,40},},   {p212=1,index=3,wz={24,40},},   {p224=1,index=4,wz={24,40},},   },},},  
                    {index=19,aid="f63",content={   p={ {p191=1,index=1,wz={24,40},},   {p203=1,index=2,wz={24,40},},   {p215=1,index=3,wz={24,40},},   {p227=1,index=4,wz={24,40},},   },},},  
                    {index=20,aid="f0",content={    p={ {p230=1,index=1,wz={48,80},},               },},},  
                },                 
            },

            reward = {
                -- 排行奖励（前10名）
                r = {
                    {p={p90=2},e={f0=3}},--1 先进配件箱 * 2  万能碎片 * 3
                    {p={p90=1},e={f0=3}},--2 先进配件箱 * 1  万能碎片 * 3
                    {p={p90=1},e={f0=1}},--3 先进配件箱 * 1  万能碎片 * 1
                    {p={p89=2},e={f0=1}},--4~5 精良配件箱 * 2  万能碎片 * 1
                    {p={p89=2},e={p6=5}},--6~10 精良配件箱 * 2 工具箱 * 5
                },
                -- 进行排行需要的最低积分
                rankPoint = 300,       
                --探索1次花费
                oneCost={1,58},
                --探索10次花费   91折
                tenCost={10,{580,528},},
             
            },    
        },
        -- 后端配置 1，2号部位橙色
        [2] = { 
            type = 1,
            sortId = 90,
            version = 2,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {accessory_p11=3,accessory_f0=1}, -- 熔炼核心碎片 * 3 万能碎片 * 1
                     {accessory_p11=2,accessory_f0=1}, -- 熔炼核心碎片 * 2 万能碎片 * 1
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_p6=10}, -- 熔炼核心碎片 * 1 工具箱 * 10
                     {accessory_p11=1,accessory_p6=10}, -- 熔炼核心碎片 * 1 工具箱 * 10
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint =300,

                -- 探索需要的钻石
                searchConsume_1x = 98,
                searchConsume_10x = 928,

                -- 资源对应的积分数
                res4point = {
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {12,20},
                    {6,10},
                    {3,5},
                    {48,80},
                },
                -- 奖池
                pool={
                    {100},
                    {
                    200,
                    200,
                    200,
                    200,
                    200,
                    200,
                    200,
                    200,
                    50,
                    50,
                    50,
                    50,
                    3,
                    3,
                    1,
                    1,
                    50,
                    50,
                    50,
                    50,
                    3,
                    3,
                    1,
                    1,
                    50,
                    50,
                    50,
                    50,
                    3,
                    3,
                    1,
                    1,
                    50,
                    50,
                    50,
                    50,
                    3,
                    3,
                    1,
                    1,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    1,
                    300,
                    300,
                    300,
                    2,
                  },
                    {
                        {"props_p533",1},
                        {"props_p537",1},
                        {"props_p541",1},
                        {"props_p545",1},
                        {"props_p549",1},
                        {"props_p553",1},
                        {"props_p557",1},
                        {"props_p561",1},
                        {"props_p182",1},
                        {"props_p185",1},
                        {"props_p188",1},
                        {"props_p191",1},
                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p194",1},
                        {"props_p197",1},
                        {"props_p200",1},
                        {"props_p203",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p206",1},
                        {"props_p209",1},
                        {"props_p212",1},
                        {"props_p215",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p218",1},
                        {"props_p221",1},
                        {"props_p224",1},
                        {"props_p227",1},
                        {"props_p377",1},
                        {"props_p381",1},
                        {"props_p558",1},
                        {"props_p562",1},
                        {"props_p183",1},
                        {"props_p186",1},
                        {"props_p195",1},
                        {"props_p198",1},
                        {"props_p207",1},
                        {"props_p210",1},
                        {"props_p219",1},
                        {"props_p222",1},
                        {"props_p230",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                        {"accessory_p11",1},
                    },
                },
               -- 客户端用奖池
               clientpool={
                  {index=1,aid="f102",content={ p={ {p537=1,index=1,wz={12,20} },{p533=1,index=2,wz={12,20} },    },},}, 
                  {index=2,aid="f110",content={ p={ {p545=1,index=1,wz={12,20} },{p541=1,index=2,wz={12,20} },    },},}, 
                  {index=3,aid="f118",content={ p={ {p553=1,index=1,wz={12,20} },{p549=1,index=2,wz={12,20} },    },},}, 
                  {index=4,aid="f126",content={ p={ {p561=1,index=1,wz={12,20} },{p557=1,index=2,wz={12,20} },    },},}, 
                  {index=5,aid="p2",content={ e={ {p2=1,index=1,wz={6,10} },{p3=1,index=2,wz={3,5} },    },},}, 
                  {index=6,aid="f15",content={ p={ {p191=1,index=1,wz={18,30} },{p188=1,index=2,wz={18,30} },{p185=1,index=3,wz={18,30} },{p182=1,index=4,wz={18,30} },    },},}, 
                  {index=7,aid="f31",content={ p={ {p203=1,index=1,wz={18,30} },{p200=1,index=2,wz={18,30} },{p197=1,index=3,wz={18,30} },{p194=1,index=4,wz={18,30} },    },},}, 
                  {index=8,aid="f47",content={ p={ {p215=1,index=1,wz={18,30} },{p212=1,index=2,wz={18,30} },{p209=1,index=3,wz={18,30} },{p206=1,index=4,wz={18,30} },    },},}, 
                  {index=9,aid="f63",content={ p={ {p227=1,index=1,wz={18,30} },{p224=1,index=2,wz={18,30} },{p221=1,index=3,wz={18,30} },{p218=1,index=4,wz={18,30} },    },},}, 
                  {index=10,aid="p1",content={ e={ {p1=1,index=1,wz={12,20} },    },},}, 
                  {index=11,aid="f103",content={ p={ {p538=1,index=1,wz={18,30} },{p534=1,index=2,wz={18,30} },{p357=1,index=3,wz={18,30} },{p353=1,index=4,wz={18,30} },    },},}, 
                  {index=12,aid="f111",content={ p={ {p546=1,index=1,wz={18,30} },{p542=1,index=2,wz={18,30} },{p365=1,index=3,wz={18,30} },{p361=1,index=4,wz={18,30} },    },},}, 
                  {index=13,aid="f119",content={ p={ {p554=1,index=1,wz={18,30} },{p550=1,index=2,wz={18,30} },{p373=1,index=3,wz={18,30} },{p369=1,index=4,wz={18,30} },    },},}, 
                  {index=14,aid="f127",content={ p={ {p562=1,index=1,wz={18,30} },{p558=1,index=2,wz={18,30} },{p381=1,index=3,wz={18,30} },{p377=1,index=4,wz={18,30} },    },},}, 
                  {index=15,aid="f0",content={ p={ {p230=1,index=1,wz={48,80} },    },},}, 
                  {index=16,aid="f8",content={ p={ {p186=1,index=1,wz={24,40} },{p183=1,index=2,wz={24,40} },    },},}, 
                  {index=17,aid="f24",content={ p={ {p198=1,index=1,wz={24,40} },{p195=1,index=2,wz={24,40} },    },},}, 
                  {index=18,aid="f40",content={ p={ {p210=1,index=1,wz={24,40} },{p207=1,index=2,wz={24,40} },    },},}, 
                  {index=19,aid="f56",content={ p={ {p222=1,index=1,wz={24,40} },{p219=1,index=2,wz={24,40} },    },},}, 
                  {index=20,aid="p11",content={ e={ {p11=1,index=1,wz={48,80} },    },},}, 
               },        
            },
            -- 前端配置
            reward={ 
                -- 排行奖励（前10名）
                r = {
                        {e={{p11=3},{f0=1}}},--1 熔炼核心碎片 * 3 万能碎片 * 1
                        {e={{p11=2},{f0=1}}},--2 熔炼核心碎片 * 2 万能碎片 * 1
                        {e={{p11=1},{f0=1}}},--3 熔炼核心碎片 * 1 万能碎片 * 1
                        {e={{p11=1},{p6=10}}},--4~5 熔炼核心碎片 * 1 工具箱 * 10
                        {e={{p11=1},{p6=5}}},--6~10 熔炼核心碎片 * 1 工具箱 * 5
                },
                -- 进行排行需要的最低积分
                rankPoint = 300,
                --探索1次花费
                oneCost={1,98},
                --探索10次花费（原价，现价）
                tenCost={10,{980,928},},
            },

        },

        -- 后端配置 3，4号部位橙色
        [3] = {
            type = 1,
            sortId = 90,
            version = 3,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {accessory_p11=3,accessory_f0=3}, -- 熔炼核心碎片 * 3 万能碎片 * 3
                     {accessory_p11=2,accessory_f0=2}, -- 熔炼核心碎片 * 2 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=2}, -- 熔炼核心碎片 * 1 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的钻石
                searchConsume_1x = 98,
                searchConsume_10x = 928,

                -- 资源对应的积分数
                res4point = {
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {12,20},
                    {6,10},
                    {3,5},
                    {48,80},
                },
                -- 奖池
                pool={
                    {100},
                    {
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    100,
                    100,
                    100,
                    100,
                    10,
                    10,
                    10,
                    10,
                    100,
                    100,
                    100,
                    100,
                    10,
                    10,
                    10,
                    10,
                    100,
                    100,
                    100,
                    100,
                    10,
                    10,
                    10,
                    10,
                    100,
                    100,
                    100,
                    100,
                    10,
                    10,
                    10,
                    10,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    2,
                    300,
                    400,
                    500,
                    1,
                  },
                    {
                        {"props_p533",1},
                        {"props_p537",1},
                        {"props_p541",1},
                        {"props_p545",1},
                        {"props_p549",1},
                        {"props_p553",1},
                        {"props_p557",1},
                        {"props_p561",1},
                        {"props_p182",1},
                        {"props_p185",1},
                        {"props_p188",1},
                        {"props_p191",1},
                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p194",1},
                        {"props_p197",1},
                        {"props_p200",1},
                        {"props_p203",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p206",1},
                        {"props_p209",1},
                        {"props_p212",1},
                        {"props_p215",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p218",1},
                        {"props_p221",1},
                        {"props_p224",1},
                        {"props_p227",1},
                        {"props_p377",1},
                        {"props_p381",1},
                        {"props_p558",1},
                        {"props_p562",1},
                        {"props_p183",1},
                        {"props_p186",1},
                        {"props_p195",1},
                        {"props_p198",1},
                        {"props_p207",1},
                        {"props_p210",1},
                        {"props_p219",1},
                        {"props_p222",1},
                        {"props_p189",1},
                        {"props_p192",1},
                        {"props_p201",1},
                        {"props_p204",1},
                        {"props_p213",1},
                        {"props_p216",1},
                        {"props_p225",1},
                        {"props_p228",1},
                        {"props_p230",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                        {"accessory_p11",1},
                    },
                },
               -- 客户端用奖池
               clientpool={
                  {index=1,aid="f102",content={ p={ {p537=1,index=1,wz={12,20} },{p533=1,index=2,wz={12,20} },    },},}, 
                  {index=2,aid="f110",content={ p={ {p545=1,index=1,wz={12,20} },{p541=1,index=2,wz={12,20} },    },},}, 
                  {index=3,aid="f118",content={ p={ {p553=1,index=1,wz={12,20} },{p549=1,index=2,wz={12,20} },    },},}, 
                  {index=4,aid="f126",content={ p={ {p561=1,index=1,wz={12,20} },{p557=1,index=2,wz={12,20} },    },},}, 
                  {index=5,aid="p2",content={ e={ {p2=1,index=1,wz={6,10} },{p3=1,index=2,wz={3,5} },    },},}, 
                  {index=6,aid="f15",content={ p={ {p191=1,index=1,wz={18,30} },{p188=1,index=2,wz={18,30} },{p185=1,index=3,wz={18,30} },{p182=1,index=4,wz={18,30} },    },},}, 
                  {index=7,aid="f31",content={ p={ {p203=1,index=1,wz={18,30} },{p200=1,index=2,wz={18,30} },{p197=1,index=3,wz={18,30} },{p194=1,index=4,wz={18,30} },    },},}, 
                  {index=8,aid="f47",content={ p={ {p215=1,index=1,wz={18,30} },{p212=1,index=2,wz={18,30} },{p209=1,index=3,wz={18,30} },{p206=1,index=4,wz={18,30} },    },},}, 
                  {index=9,aid="f63",content={ p={ {p227=1,index=1,wz={18,30} },{p224=1,index=2,wz={18,30} },{p221=1,index=3,wz={18,30} },{p218=1,index=4,wz={18,30} },    },},}, 
                  {index=10,aid="p1",content={ e={ {p1=1,index=1,wz={12,20} },    },},}, 
                  {index=11,aid="f103",content={ p={ {p538=1,index=1,wz={18,30} },{p534=1,index=2,wz={18,30} },{p357=1,index=3,wz={18,30} },{p353=1,index=4,wz={18,30} },    },},}, 
                  {index=12,aid="f111",content={ p={ {p546=1,index=1,wz={18,30} },{p542=1,index=2,wz={18,30} },{p365=1,index=3,wz={18,30} },{p361=1,index=4,wz={18,30} },    },},}, 
                  {index=13,aid="f119",content={ p={ {p554=1,index=1,wz={18,30} },{p550=1,index=2,wz={18,30} },{p373=1,index=3,wz={18,30} },{p369=1,index=4,wz={18,30} },    },},}, 
                  {index=14,aid="f127",content={ p={ {p562=1,index=1,wz={18,30} },{p558=1,index=2,wz={18,30} },{p381=1,index=3,wz={18,30} },{p377=1,index=4,wz={18,30} },    },},}, 
                  {index=15,aid="f0",content={ p={ {p230=1,index=1,wz={48,80} },    },},}, 
                  {index=16,aid="f16",content={ p={ {p192=1,index=1,wz={24,40} },{p189=1,index=2,wz={24,40} },{p186=1,index=3,wz={24,40} },{p183=1,index=4,wz={24,40} },    },},}, 
                  {index=17,aid="f32",content={ p={ {p204=1,index=1,wz={24,40} },{p201=1,index=2,wz={24,40} },{p198=1,index=3,wz={24,40} },{p195=1,index=4,wz={24,40} },    },},}, 
                  {index=18,aid="f48",content={ p={ {p216=1,index=1,wz={24,40} },{p213=1,index=2,wz={24,40} },{p210=1,index=3,wz={24,40} },{p207=1,index=4,wz={24,40} },    },},}, 
                  {index=19,aid="f64",content={ p={ {p228=1,index=1,wz={24,40} },{p225=1,index=2,wz={24,40} },{p222=1,index=3,wz={24,40} },{p219=1,index=4,wz={24,40} },    },},}, 
                  {index=20,aid="p11",content={ e={ {p11=1,index=1,wz={48,80} },    },},}, 
               },        
            },
           -- 前端配置
           reward={
               -- 排行奖励（前10名）
               r = {
                        {e={{p11=3},{f0=3}}},--1 熔炼核心碎片 * 3 万能碎片 * 3
                        {e={{p11=2},{f0=2}}},--2 熔炼核心碎片 * 2 万能碎片 * 2
                        {e={{p11=1},{f0=2}}},--3 熔炼核心碎片 * 1 万能碎片 * 2
                        {e={{p11=1},{f0=1}}},--4~5 熔炼核心碎片 * 1 万能碎片 * 1
                        {e={{p11=1},{p6=5}}},--6~10 熔炼核心碎片 * 1 工具箱 * 5
               },
               -- 进行排行需要的最低积分
               rankPoint = 300,
               --探索1次花费
               oneCost={1,98},
               --探索10次花费（原价，现价）
               tenCost={10,{980,928},},
           },
        },
        -- 后端配置 5，6号部位橙色
        [4] = {
            type = 1,
            sortId = 90,
            version = 4,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {accessory_p11=3,accessory_f0=3}, -- 熔炼核心碎片 * 3 万能碎片 * 3
                     {accessory_p11=2,accessory_f0=2}, -- 熔炼核心碎片 * 2 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=2}, -- 熔炼核心碎片 * 1 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的钻石
                searchConsume_1x = 88,
                searchConsume_10x = 828,

                -- 资源对应的积分数
                res4point = {
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {12,20},
                    {6,10},
                    {3,5},
                    {48,80},
                },
                -- 奖池
                pool={
                    {100},
                    {
                    10,
                    10,
                    10,
                    10,
                    2,
                    2,
                    2,
                    2,
                    10,
                    10,
                    10,
                    10,
                    2,
                    2,
                    2,
                    2,
                    10,
                    10,
                    10,
                    10,
                    2,
                    2,
                    2,
                    2,
                    10,
                    10,
                    10,
                    10,
                    2,
                    2,
                    2,
                    2,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    600,
                    600,
                    600,
                    1,
                    300,
                    300,
                    300,
                    1,
                  },
                    {
                        {"props_p182",1},
                        {"props_p185",1},
                        {"props_p188",1},
                        {"props_p191",1},
                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p194",1},
                        {"props_p197",1},
                        {"props_p200",1},
                        {"props_p203",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p206",1},
                        {"props_p209",1},
                        {"props_p212",1},
                        {"props_p215",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p218",1},
                        {"props_p221",1},
                        {"props_p224",1},
                        {"props_p227",1},
                        {"props_p377",1},
                        {"props_p381",1},
                        {"props_p558",1},
                        {"props_p562",1},
                        {"props_p183",1},
                        {"props_p186",1},
                        {"props_p195",1},
                        {"props_p198",1},
                        {"props_p207",1},
                        {"props_p210",1},
                        {"props_p219",1},
                        {"props_p222",1},
                        {"props_p189",1},
                        {"props_p192",1},
                        {"props_p201",1},
                        {"props_p204",1},
                        {"props_p213",1},
                        {"props_p216",1},
                        {"props_p225",1},
                        {"props_p228",1},
                        {"props_p4820",1},
                        {"props_p4821",1},
                        {"props_p4822",1},
                        {"props_p230",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                        {"accessory_p11",1},
                    },
                },
               -- 客户端用奖池
               clientpool={
                  {index=1,type="e",aid="f15",content={ p={ {p191=1,index=1,wz={18,30} },{p188=1,index=2,wz={18,30} },{p185=1,index=3,wz={18,30} },{p182=1,index=4,wz={18,30} },    },},}, 
                  {index=2,type="e",aid="f31",content={ p={ {p203=1,index=1,wz={18,30} },{p200=1,index=2,wz={18,30} },{p197=1,index=3,wz={18,30} },{p194=1,index=4,wz={18,30} },    },},}, 
                  {index=3,type="e",aid="f47",content={ p={ {p215=1,index=1,wz={18,30} },{p212=1,index=2,wz={18,30} },{p209=1,index=3,wz={18,30} },{p206=1,index=4,wz={18,30} },    },},}, 
                  {index=4,type="e",aid="f63",content={ p={ {p227=1,index=1,wz={18,30} },{p224=1,index=2,wz={18,30} },{p221=1,index=3,wz={18,30} },{p218=1,index=4,wz={18,30} },    },},}, 
                  {index=5,type="e",aid="p2",content={ e={ {p2=1,index=1,wz={6,10} },    },},}, 
                  {index=6,type="e",aid="f103",content={ p={ {p538=1,index=1,wz={18,30} },{p534=1,index=2,wz={18,30} },{p357=1,index=3,wz={18,30} },{p353=1,index=4,wz={18,30} },    },},}, 
                  {index=7,type="e",aid="f111",content={ p={ {p546=1,index=1,wz={18,30} },{p542=1,index=2,wz={18,30} },{p365=1,index=3,wz={18,30} },{p361=1,index=4,wz={18,30} },    },},}, 
                  {index=8,type="e",aid="f119",content={ p={ {p554=1,index=1,wz={18,30} },{p550=1,index=2,wz={18,30} },{p373=1,index=3,wz={18,30} },{p369=1,index=4,wz={18,30} },    },},}, 
                  {index=9,type="e",aid="f127",content={ p={ {p562=1,index=1,wz={18,30} },{p558=1,index=2,wz={18,30} },{p381=1,index=3,wz={18,30} },{p377=1,index=4,wz={18,30} },    },},}, 
                  {index=10,type="e",aid="p1",content={ e={ {p1=1,index=1,wz={12,20} },    },},}, 
                  {index=11,type="e",aid="f16",content={ p={ {p192=1,index=1,wz={24,40} },{p189=1,index=2,wz={24,40} },{p186=1,index=3,wz={24,40} },{p183=1,index=4,wz={24,40} },    },},}, 
                  {index=12,type="e",aid="f32",content={ p={ {p204=1,index=1,wz={24,40} },{p201=1,index=2,wz={24,40} },{p198=1,index=3,wz={24,40} },{p195=1,index=4,wz={24,40} },    },},}, 
                  {index=13,type="e",aid="f48",content={ p={ {p216=1,index=1,wz={24,40} },{p213=1,index=2,wz={24,40} },{p210=1,index=3,wz={24,40} },{p207=1,index=4,wz={24,40} },    },},}, 
                  {index=14,type="e",aid="f64",content={ p={ {p228=1,index=1,wz={24,40} },{p225=1,index=2,wz={24,40} },{p222=1,index=3,wz={24,40} },{p219=1,index=4,wz={24,40} },    },},}, 
                  {index=15,type="e",aid="p3",content={ e={ {p3=1,index=1,wz={3,5} },    },},}, 
                  {index=16,type="p",aid="p4820",content={ p={ {p4820=1,index=1,wz={24,40} },    },},}, 
                  {index=17,type="p",aid="p4821",content={ p={ {p4821=1,index=1,wz={24,40} },    },},}, 
                  {index=18,type="p",aid="p4822",content={ p={ {p4822=1,index=1,wz={24,40} },    },},}, 
                  {index=19,type="e",aid="f0",content={ p={ {p230=1,index=1,wz={48,80} },    },},}, 
                  {index=20,type="e",aid="p11",content={ e={ {p11=1,index=1,wz={48,80} },    },},}, 
               },        
            },
           -- 前端配置
           reward={
               -- 排行奖励（前10名）
               r = {
                        {e={{p11=3},{f0=3}}},--1 熔炼核心碎片 * 3 万能碎片 * 3
                        {e={{p11=2},{f0=2}}},--2 熔炼核心碎片 * 2 万能碎片 * 2
                        {e={{p11=1},{f0=2}}},--3 熔炼核心碎片 * 1 万能碎片 * 2
                        {e={{p11=1},{f0=1}}},--4~5 熔炼核心碎片 * 1 万能碎片 * 1
                        {e={{p11=1},{p6=5}}},--6~10 熔炼核心碎片 * 1 工具箱 * 5
               },
               -- 进行排行需要的最低积分
               rankPoint = 300,
               --探索1次花费
               oneCost={1,88},
               --探索10次花费（原价，现价）
               tenCost={10,{880,828},},
           },
        },

        -- 后端配置 7，8号部位橙色
        [5] = {
            type = 1,
            sortId = 90,
            version = 5,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {accessory_p11=3,accessory_f0=3}, -- 熔炼核心碎片 * 3 万能碎片 * 3
                     {accessory_p11=2,accessory_f0=2}, -- 熔炼核心碎片 * 2 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=2}, -- 熔炼核心碎片 * 1 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的钻石
                searchConsume_1x = 98,
                searchConsume_10x = 928,

                -- 资源对应的积分数
                res4point = {
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {12,20},
                    {6,10},
                    {3,5},
                    {48,80},
                },
                -- 奖池
                pool={
                    {100},
                    {
                    50,
                    50,
                    20,
                    20,
                    1,
                    1,
                    1,
                    1,
                    50,
                    50,
                    20,
                    20,
                    1,
                    1,
                    1,
                    1,
                    50,
                    50,
                    20,
                    20,
                    1,
                    1,
                    1,
                    1,
                    50,
                    50,
                    20,
                    20,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    600,
                    600,
                    600,
                    1,
                  },
                    {
                        {"props_p182",1},
                        {"props_p185",1},
                        {"props_p188",1},
                        {"props_p191",1},
                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p194",1},
                        {"props_p197",1},
                        {"props_p200",1},
                        {"props_p203",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p206",1},
                        {"props_p209",1},
                        {"props_p212",1},
                        {"props_p215",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p218",1},
                        {"props_p221",1},
                        {"props_p224",1},
                        {"props_p227",1},
                        {"props_p377",1},
                        {"props_p381",1},
                        {"props_p558",1},
                        {"props_p562",1},
                        {"props_p183",1},
                        {"props_p186",1},
                        {"props_p195",1},
                        {"props_p198",1},
                        {"props_p207",1},
                        {"props_p210",1},
                        {"props_p219",1},
                        {"props_p222",1},
                        {"props_p189",1},
                        {"props_p192",1},
                        {"props_p201",1},
                        {"props_p204",1},
                        {"props_p213",1},
                        {"props_p216",1},
                        {"props_p225",1},
                        {"props_p228",1},
                        {"props_p354",1},
                        {"props_p358",1},
                        {"props_p362",1},
                        {"props_p366",1},
                        {"props_p370",1},
                        {"props_p374",1},
                        {"props_p378",1},
                        {"props_p382",1},
                        {"props_p535",1},
                        {"props_p539",1},
                        {"props_p543",1},
                        {"props_p547",1},
                        {"props_p551",1},
                        {"props_p555",1},
                        {"props_p559",1},
                        {"props_p563",1},
                        {"props_p230",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                        {"accessory_p11",1},
                    },
                },
               -- 客户端用奖池
               clientpool={
                  {index=1,aid="f15",content={ p={ {p191=1,index=1,wz={18,30} },{p188=1,index=2,wz={18,30} },{p185=1,index=3,wz={18,30} },{p182=1,index=4,wz={18,30} },    },},}, 
                  {index=2,aid="f31",content={ p={ {p203=1,index=1,wz={18,30} },{p200=1,index=2,wz={18,30} },{p197=1,index=3,wz={18,30} },{p194=1,index=4,wz={18,30} },    },},}, 
                  {index=3,aid="f47",content={ p={ {p215=1,index=1,wz={18,30} },{p212=1,index=2,wz={18,30} },{p209=1,index=3,wz={18,30} },{p206=1,index=4,wz={18,30} },    },},}, 
                  {index=4,aid="f63",content={ p={ {p227=1,index=1,wz={18,30} },{p224=1,index=2,wz={18,30} },{p221=1,index=3,wz={18,30} },{p218=1,index=4,wz={18,30} },    },},}, 
                  {index=5,aid="p2",content={ e={ {p2=1,index=1,wz={6,10} },{p3=1,index=2,wz={3,5} },    },},}, 
                  {index=6,aid="f103",content={ p={ {p538=1,index=1,wz={18,30} },{p534=1,index=2,wz={18,30} },{p357=1,index=3,wz={18,30} },{p353=1,index=4,wz={18,30} },    },},}, 
                  {index=7,aid="f111",content={ p={ {p546=1,index=1,wz={18,30} },{p542=1,index=2,wz={18,30} },{p365=1,index=3,wz={18,30} },{p361=1,index=4,wz={18,30} },    },},}, 
                  {index=8,aid="f119",content={ p={ {p554=1,index=1,wz={18,30} },{p550=1,index=2,wz={18,30} },{p373=1,index=3,wz={18,30} },{p369=1,index=4,wz={18,30} },    },},}, 
                  {index=9,aid="f127",content={ p={ {p562=1,index=1,wz={18,30} },{p558=1,index=2,wz={18,30} },{p381=1,index=3,wz={18,30} },{p377=1,index=4,wz={18,30} },    },},}, 
                  {index=10,aid="p1",content={ e={ {p1=1,index=1,wz={12,20} },    },},}, 
                  {index=11,aid="f16",content={ p={ {p192=1,index=1,wz={24,40} },{p189=1,index=2,wz={24,40} },{p186=1,index=3,wz={24,40} },{p183=1,index=4,wz={24,40} },    },},}, 
                  {index=12,aid="f32",content={ p={ {p204=1,index=1,wz={24,40} },{p201=1,index=2,wz={24,40} },{p198=1,index=3,wz={24,40} },{p195=1,index=4,wz={24,40} },    },},}, 
                  {index=13,aid="f48",content={ p={ {p216=1,index=1,wz={24,40} },{p213=1,index=2,wz={24,40} },{p210=1,index=3,wz={24,40} },{p207=1,index=4,wz={24,40} },    },},}, 
                  {index=14,aid="f64",content={ p={ {p228=1,index=1,wz={24,40} },{p225=1,index=2,wz={24,40} },{p222=1,index=3,wz={24,40} },{p219=1,index=4,wz={24,40} },    },},}, 
                  {index=15,aid="f0",content={ p={ {p230=1,index=1,wz={48,80} },    },},}, 
                  {index=16,aid="f104",content={ p={ {p539=1,index=1,wz={24,40} },{p535=1,index=2,wz={24,40} },{p358=1,index=3,wz={24,40} },{p354=1,index=4,wz={24,40} },    },},}, 
                  {index=17,aid="f112",content={ p={ {p547=1,index=1,wz={24,40} },{p543=1,index=2,wz={24,40} },{p366=1,index=3,wz={24,40} },{p362=1,index=4,wz={24,40} },    },},}, 
                  {index=18,aid="f120",content={ p={ {p555=1,index=1,wz={24,40} },{p551=1,index=2,wz={24,40} },{p374=1,index=3,wz={24,40} },{p370=1,index=4,wz={24,40} },    },},}, 
                  {index=19,aid="f128",content={ p={ {p563=1,index=1,wz={24,40} },{p559=1,index=2,wz={24,40} },{p382=1,index=3,wz={24,40} },{p378=1,index=4,wz={24,40} },    },},}, 
                  {index=20,aid="p11",content={ e={ {p11=1,index=1,wz={48,80} },    },},}, 
               },        
            },
           -- 前端配置
           reward={
               -- 排行奖励（前10名）
               r = {
                        {e={{p11=3},{f0=3}}},--1 熔炼核心碎片 * 3 万能碎片 * 3
                        {e={{p11=2},{f0=2}}},--2 熔炼核心碎片 * 2 万能碎片 * 2
                        {e={{p11=1},{f0=2}}},--3 熔炼核心碎片 * 1 万能碎片 * 2
                        {e={{p11=1},{f0=1}}},--4~5 熔炼核心碎片 * 1 万能碎片 * 1
                        {e={{p11=1},{p6=5}}},--6~10 熔炼核心碎片 * 1 工具箱 * 5
               },
               -- 进行排行需要的最低积分
               rankPoint = 300,
               --探索1次花费
               oneCost={1,98},
               --探索10次花费（原价，现价）
               tenCost={10,{980,928},},
           },
        },
        -- 后端配置 1-4红配碎片
        [6] = {
            type = 1,
            sortId = 90,
            version = 5,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {accessory_p11=3,accessory_f0=3}, -- 熔炼核心碎片 * 3 万能碎片 * 3
                     {accessory_p11=2,accessory_f0=2}, -- 熔炼核心碎片 * 2 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=2}, -- 熔炼核心碎片 * 1 万能碎片 * 2
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_f0=1}, -- 熔炼核心碎片 * 1 万能碎片 * 1
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                     {accessory_p11=1,accessory_p6=5}, -- 熔炼核心碎片 * 1 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的钻石
                searchConsume_1x = 158,
                searchConsume_10x = 1498,

                -- 资源对应的积分数
                res4point = {
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {12,20},
                    {6,10},
                    {3,5},
                    {48,80},
                },
                -- 奖池
                pool={
                    {100},
                    {
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    500,
                    60,
                    60,
                    60,
                    60,
                    80,
                    80,
                    80,
                    80,
                    80,
                    80,
                    80,
                    80,
                    50,
                    50,
                    50,
                    50,
                    5,
                    5,
                    3,
                    3,
                    8,
                    8,
                    5,
                    5,
                    8,
                    8,
                    5,
                    5,
                    5,
                    5,
                    3,
                    3,
                    10,
                    5000,
                    5000,
                    5000,
                    10,
                  },
                    {
                        {"props_p182",1},
                        {"props_p185",1},
                        {"props_p188",1},
                        {"props_p191",1},
                        {"props_p194",1},
                        {"props_p197",1},
                        {"props_p200",1},
                        {"props_p203",1},
                        {"props_p206",1},
                        {"props_p209",1},
                        {"props_p212",1},
                        {"props_p215",1},
                        {"props_p218",1},
                        {"props_p221",1},
                        {"props_p224",1},
                        {"props_p227",1},
                        {"props_p183",1},
                        {"props_p186",1},
                        {"props_p189",1},
                        {"props_p192",1},
                        {"props_p195",1},
                        {"props_p198",1},
                        {"props_p201",1},
                        {"props_p204",1},
                        {"props_p207",1},
                        {"props_p210",1},
                        {"props_p213",1},
                        {"props_p216",1},
                        {"props_p219",1},
                        {"props_p222",1},
                        {"props_p225",1},
                        {"props_p228",1},
                        {"props_p5062",1},
                        {"props_p5063",1},
                        {"props_p5064",1},
                        {"props_p5065",1},
                        {"props_p5070",1},
                        {"props_p5071",1},
                        {"props_p5072",1},
                        {"props_p5073",1},
                        {"props_p5078",1},
                        {"props_p5079",1},
                        {"props_p5080",1},
                        {"props_p5081",1},
                        {"props_p5086",1},
                        {"props_p5087",1},
                        {"props_p5088",1},
                        {"props_p5089",1},
                        {"props_p230",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                        {"accessory_p11",1},
                    },
                },
               -- 客户端用奖池
               clientpool={
                  {index=1,aid="f15",content={ p={ {p191=1,index=1,wz={18,30} },{p188=1,index=2,wz={18,30} },{p185=1,index=3,wz={18,30} },{p182=1,index=4,wz={18,30} },    },},}, 
                  {index=2,aid="f31",content={ p={ {p203=1,index=1,wz={18,30} },{p200=1,index=2,wz={18,30} },{p197=1,index=3,wz={18,30} },{p194=1,index=4,wz={18,30} },    },},}, 
                  {index=3,aid="f47",content={ p={ {p215=1,index=1,wz={18,30} },{p212=1,index=2,wz={18,30} },{p209=1,index=3,wz={18,30} },{p206=1,index=4,wz={18,30} },    },},}, 
                  {index=4,aid="f63",content={ p={ {p227=1,index=1,wz={18,30} },{p224=1,index=2,wz={18,30} },{p221=1,index=3,wz={18,30} },{p218=1,index=4,wz={18,30} },    },},}, 
                  {index=5,aid="p2",content={ e={ {p2=1,index=1,wz={24,40} },{p3=1,index=2,wz={24,40} },    },},}, 
                  {index=6,aid="f16",content={ p={ {p192=1,index=1,wz={18,30} },{p189=1,index=2,wz={18,30} },{p186=1,index=3,wz={18,30} },{p183=1,index=4,wz={18,30} },    },},}, 
                  {index=7,aid="f32",content={ p={ {p204=1,index=1,wz={18,30} },{p201=1,index=2,wz={18,30} },{p198=1,index=3,wz={18,30} },{p195=1,index=4,wz={18,30} },    },},}, 
                  {index=8,aid="f48",content={ p={ {p216=1,index=1,wz={18,30} },{p213=1,index=2,wz={18,30} },{p210=1,index=3,wz={18,30} },{p207=1,index=4,wz={18,30} },    },},}, 
                  {index=9,aid="f64",content={ p={ {p228=1,index=1,wz={18,30} },{p225=1,index=2,wz={18,30} },{p222=1,index=3,wz={18,30} },{p219=1,index=4,wz={18,30} },    },},}, 
                  {index=10,aid="p1",content={ e={ {p1=1,index=1,wz={24,40} },    },},}, 
                  {index=11,aid="f130",content={ p={ {p5063=1,index=1,wz={24,40} },{p5062=1,index=2,wz={24,40} },    },},}, 
                  {index=12,aid="f138",content={ p={ {p5071=1,index=1,wz={24,40} },{p5070=1,index=2,wz={24,40} },    },},}, 
                  {index=13,aid="f146",content={ p={ {p5079=1,index=1,wz={24,40} },{p5078=1,index=2,wz={24,40} },    },},}, 
                  {index=14,aid="f154",content={ p={ {p5087=1,index=1,wz={24,40} },{p5086=1,index=2,wz={24,40} },    },},}, 
                  {index=15,aid="f0",content={ p={ {p230=1,index=1,wz={24,40} },    },},}, 
                  {index=16,aid="f132",content={ p={ {p5065=1,index=1,wz={24,40} },{p5064=1,index=2,wz={24,40} },    },},}, 
                  {index=17,aid="f140",content={ p={ {p5073=1,index=1,wz={24,40} },{p5072=1,index=2,wz={24,40} },    },},}, 
                  {index=18,aid="f148",content={ p={ {p5081=1,index=1,wz={24,40} },{p5080=1,index=2,wz={24,40} },    },},}, 
                  {index=19,aid="f156",content={ p={ {p5089=1,index=1,wz={24,40} },{p5088=1,index=2,wz={24,40} },    },},}, 
                  {index=20,aid="p11",content={ e={ {p11=1,index=1,wz={24,40} },    },},}, 
               },        
            },
           -- 前端配置
           reward={
               -- 排行奖励（前10名）
               r = {
                        {e={{p11=3},{f0=3}}},--1 熔炼核心碎片 * 3 万能碎片 * 3
                        {e={{p11=2},{f0=2}}},--2 熔炼核心碎片 * 2 万能碎片 * 2
                        {e={{p11=1},{f0=2}}},--3 熔炼核心碎片 * 1 万能碎片 * 2
                        {e={{p11=1},{f0=1}}},--4~5 熔炼核心碎片 * 1 万能碎片 * 1
                        {e={{p11=1},{p6=5}}},--6~10 熔炼核心碎片 * 1 工具箱 * 5
               },
               -- 进行排行需要的最低积分
               rankPoint = 300,
               --探索1次花费
               oneCost={1,158},
               --探索10次花费（原价，现价）
               tenCost={10,{1580,1498},},
           },
        },



    },

    -- 装备探索
    equipSearchII ={
        multiSelectType = true,
        [1] = {
            type = 1,
            sortId = 91,
            version = 1,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {props_p90=2,accessory_f0=3}, -- 先进配件箱 * 2 万能碎片 * 3
                     {props_p90=1,accessory_f0=3}, -- 先进配件箱 * 1 万能碎片 * 3
                     {props_p90=1,accessory_f0=1}, -- 先进配件箱 * 1 万能碎片 * 1
                     {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                     {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的金币
                searchConsume_1x = 58,
                searchConsume_10x = 528,

                -- 资源对应的积分数
                res4point = {
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
            {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
            {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
            {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {6,10},
                    {6,10},
                    {3,5},
                },

                -- 奖池
                pool={
                    {100},
                    {
                7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,
                7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,
                7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,
                4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,
                8,24,64,144
                  },
                    {
                        {"props_p181",1},
                        {"props_p193",1},
                        {"props_p205",1},
                        {"props_p217",1},
                        {"props_p184",1},
                        {"props_p196",1},
                        {"props_p208",1},
                        {"props_p220",1},
                        {"props_p187",1},
                        {"props_p199",1},
                        {"props_p211",1},
                        {"props_p223",1},
                        {"props_p190",1},
                        {"props_p202",1},
                        {"props_p214",1},
                        {"props_p226",1},

                        {"props_p352",1},
                        {"props_p356",1},
                        {"props_p360",1},
                        {"props_p364",1},
                        {"props_p368",1},
                        {"props_p372",1},
                        {"props_p376",1},
                        {"props_p380",1},

                        {"props_p181",2},
                        {"props_p193",2},
                        {"props_p205",2},
                        {"props_p217",2},
                        {"props_p184",2},
                        {"props_p196",2},
                        {"props_p208",2},
                        {"props_p220",2},
                        {"props_p187",2},
                        {"props_p199",2},
                        {"props_p211",2},
                        {"props_p223",2},
                        {"props_p190",2},
                        {"props_p202",2},
                        {"props_p214",2},
                        {"props_p226",2},

                        {"props_p352",2},
                        {"props_p356",2},
                        {"props_p360",2},
                        {"props_p364",2},
                        {"props_p368",2},
                        {"props_p372",2},
                        {"props_p376",2},
                        {"props_p380",2},

                        {"props_p181",3},
                        {"props_p193",3},
                        {"props_p205",3},
                        {"props_p217",3},
                        {"props_p184",3},
                        {"props_p196",3},
                        {"props_p208",3},
                        {"props_p220",3},
                        {"props_p187",3},
                        {"props_p199",3},
                        {"props_p211",3},
                        {"props_p223",3},
                        {"props_p190",3},
                        {"props_p202",3},
                        {"props_p214",3},
                        {"props_p226",3},

                        {"props_p352",3},
                        {"props_p356",3},
                        {"props_p360",3},
                        {"props_p364",3},
                        {"props_p368",3},
                        {"props_p372",3},
                        {"props_p376",3},
                        {"props_p380",3},

                        {"props_p182",1},
                        {"props_p194",1},
                        {"props_p206",1},
                        {"props_p218",1},
                        {"props_p185",1},
                        {"props_p197",1},
                        {"props_p209",1},
                        {"props_p221",1},
                        {"props_p188",1},
                        {"props_p200",1},
                        {"props_p212",1},
                        {"props_p224",1},
                        {"props_p191",1},
                        {"props_p203",1},
                        {"props_p215",1},
                        {"props_p227",1},

                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p377",1},
                        {"props_p381",1},

                        {"accessory_f0",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                    },
                },
            },
        },
        [2] = {
                type = 1,
                sortId = 91,
                version=2,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                    {props_p90=2,accessory_f0=3}, -- 先进配件箱 * 2 万能碎片 * 3
                    {props_p90=1,accessory_f0=3}, -- 先进配件箱 * 1 万能碎片 * 3
                    {props_p90=1,accessory_f0=1}, -- 先进配件箱 * 1 万能碎片 * 1
                    {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                    {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的金币
                searchConsume_1x = 58,
                searchConsume_10x = 528,

                -- 资源对应的积分数
                res4point = {
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {6,10},
                    {6,10},
                    {3,5},
                },

                -- 奖池
                pool={
                    {100},
                    {
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        6,6,6,6,6,6,6,6,        6,6,6,6,6,6,6,6,        3,3,3,3,3,3,3,3,    3,3,3,3,3,3,3,3,
                        16,48,128,256
                    },
                    {
                        {"props_p181",1},
                        {"props_p193",1},
                        {"props_p205",1},
                        {"props_p217",1},
                        {"props_p184",1},
                        {"props_p196",1},
                        {"props_p208",1},
                        {"props_p220",1},
                        {"props_p187",1},
                        {"props_p199",1},
                        {"props_p211",1},
                        {"props_p223",1},
                        {"props_p190",1},
                        {"props_p202",1},
                        {"props_p214",1},
                        {"props_p226",1},

                        {"props_p352",1},
                        {"props_p356",1},
                        {"props_p360",1},
                        {"props_p364",1},
                        {"props_p368",1},
                        {"props_p372",1},
                        {"props_p376",1},
                        {"props_p380",1},

                        {"props_p533",1},
                        {"props_p537",1},
                        {"props_p541",1},
                        {"props_p545",1},
                        {"props_p549",1},
                        {"props_p553",1},
                        {"props_p557",1},
                        {"props_p561",1},

                        {"props_p181",2},
                        {"props_p193",2},
                        {"props_p205",2},
                        {"props_p217",2},
                        {"props_p184",2},
                        {"props_p196",2},
                        {"props_p208",2},
                        {"props_p220",2},
                        {"props_p187",2},
                        {"props_p199",2},
                        {"props_p211",2},
                        {"props_p223",2},
                        {"props_p190",2},
                        {"props_p202",2},
                        {"props_p214",2},
                        {"props_p226",2},

                        {"props_p352",2},
                        {"props_p356",2},
                        {"props_p360",2},
                        {"props_p364",2},
                        {"props_p368",2},
                        {"props_p372",2},
                        {"props_p376",2},
                        {"props_p380",2},

                        {"props_p533",2},
                        {"props_p537",2},
                        {"props_p541",2},
                        {"props_p545",2},
                        {"props_p549",2},
                        {"props_p553",2},
                        {"props_p557",2},
                        {"props_p561",2},

                        {"props_p181",3},
                        {"props_p193",3},
                        {"props_p205",3},
                        {"props_p217",3},
                        {"props_p184",3},
                        {"props_p196",3},
                        {"props_p208",3},
                        {"props_p220",3},
                        {"props_p187",3},
                        {"props_p199",3},
                        {"props_p211",3},
                        {"props_p223",3},
                        {"props_p190",3},
                        {"props_p202",3},
                        {"props_p214",3},
                        {"props_p226",3},

                        {"props_p352",3},
                        {"props_p356",3},
                        {"props_p360",3},
                        {"props_p364",3},
                        {"props_p368",3},
                        {"props_p372",3},
                        {"props_p376",3},
                        {"props_p380",3},

                        {"props_p533",3},
                        {"props_p537",3},
                        {"props_p541",3},
                        {"props_p545",3},
                        {"props_p549",3},
                        {"props_p553",3},
                        {"props_p557",3},
                        {"props_p561",3},

                        {"props_p182",1},
                        {"props_p194",1},
                        {"props_p206",1},
                        {"props_p218",1},
                        {"props_p185",1},
                        {"props_p197",1},
                        {"props_p209",1},
                        {"props_p221",1},
                        {"props_p188",1},
                        {"props_p200",1},
                        {"props_p212",1},
                        {"props_p224",1},
                        {"props_p191",1},
                        {"props_p203",1},
                        {"props_p215",1},
                        {"props_p227",1},

                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p377",1},
                        {"props_p381",1},

                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p558",1},
                        {"props_p562",1},


                        {"accessory_f0",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                    },
                },
            },
        },
            [3] = {
            type = 1,
            sortId = 91,
            version = 3,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                     {props_p90=2,accessory_f0=3}, -- 先进配件箱 * 2 万能碎片 * 3
                     {props_p90=1,accessory_f0=3}, -- 先进配件箱 * 1 万能碎片 * 3
                     {props_p90=1,accessory_f0=1}, -- 先进配件箱 * 1 万能碎片 * 1
                     {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                     {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                     {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的金币
                searchConsume_1x = 58,
                searchConsume_10x = 528,

                -- 资源对应的积分数
                res4point = {
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
            {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
            {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
            {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {6,10},
                    {6,10},
                    {3,5},
                },

                -- 奖池
                pool={
                    {100},
                    {
                7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,
                7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,
                7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,6,6,6,6,6,6,6,6,
                4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2,2,2,
                8,24,64,144
                  },
                    {
                        {"props_p181",1},
                        {"props_p193",1},
                        {"props_p205",1},
                        {"props_p217",1},
                        {"props_p184",1},
                        {"props_p196",1},
                        {"props_p208",1},
                        {"props_p220",1},
                        {"props_p187",1},
                        {"props_p199",1},
                        {"props_p211",1},
                        {"props_p223",1},
                        {"props_p190",1},
                        {"props_p202",1},
                        {"props_p214",1},
                        {"props_p226",1},

                        {"props_p352",1},
                        {"props_p356",1},
                        {"props_p360",1},
                        {"props_p364",1},
                        {"props_p368",1},
                        {"props_p372",1},
                        {"props_p376",1},
                        {"props_p380",1},

                        {"props_p181",2},
                        {"props_p193",2},
                        {"props_p205",2},
                        {"props_p217",2},
                        {"props_p184",2},
                        {"props_p196",2},
                        {"props_p208",2},
                        {"props_p220",2},
                        {"props_p187",2},
                        {"props_p199",2},
                        {"props_p211",2},
                        {"props_p223",2},
                        {"props_p190",2},
                        {"props_p202",2},
                        {"props_p214",2},
                        {"props_p226",2},

                        {"props_p352",2},
                        {"props_p356",2},
                        {"props_p360",2},
                        {"props_p364",2},
                        {"props_p368",2},
                        {"props_p372",2},
                        {"props_p376",2},
                        {"props_p380",2},

                        {"props_p181",3},
                        {"props_p193",3},
                        {"props_p205",3},
                        {"props_p217",3},
                        {"props_p184",3},
                        {"props_p196",3},
                        {"props_p208",3},
                        {"props_p220",3},
                        {"props_p187",3},
                        {"props_p199",3},
                        {"props_p211",3},
                        {"props_p223",3},
                        {"props_p190",3},
                        {"props_p202",3},
                        {"props_p214",3},
                        {"props_p226",3},

                        {"props_p352",3},
                        {"props_p356",3},
                        {"props_p360",3},
                        {"props_p364",3},
                        {"props_p368",3},
                        {"props_p372",3},
                        {"props_p376",3},
                        {"props_p380",3},

                        {"props_p182",1},
                        {"props_p194",1},
                        {"props_p206",1},
                        {"props_p218",1},
                        {"props_p185",1},
                        {"props_p197",1},
                        {"props_p209",1},
                        {"props_p221",1},
                        {"props_p188",1},
                        {"props_p200",1},
                        {"props_p212",1},
                        {"props_p224",1},
                        {"props_p191",1},
                        {"props_p203",1},
                        {"props_p215",1},
                        {"props_p227",1},

                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p377",1},
                        {"props_p381",1},

                        {"accessory_f0",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                    },
                },
            },
        },
        [4] = {
                type = 1,
                sortId = 91,
                version=4,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                    {props_p90=2,accessory_f0=3}, -- 先进配件箱 * 2 万能碎片 * 3
                    {props_p90=1,accessory_f0=3}, -- 先进配件箱 * 1 万能碎片 * 3
                    {props_p90=1,accessory_f0=1}, -- 先进配件箱 * 1 万能碎片 * 1
                    {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                    {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的金币
                searchConsume_1x = 58,
                searchConsume_10x = 528,

                -- 资源对应的积分数
                res4point = {
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {6,10},
                    {6,10},
                    {3,5},
                },

                -- 奖池
                pool={
                    {100},
                    {
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        6,6,6,6,6,6,6,6,        6,6,6,6,6,6,6,6,        3,3,3,3,3,3,3,3,    3,3,3,3,3,3,3,3,
                        16,48,128,256
                    },
                    {
                        {"props_p181",1},
                        {"props_p193",1},
                        {"props_p205",1},
                        {"props_p217",1},
                        {"props_p184",1},
                        {"props_p196",1},
                        {"props_p208",1},
                        {"props_p220",1},
                        {"props_p187",1},
                        {"props_p199",1},
                        {"props_p211",1},
                        {"props_p223",1},
                        {"props_p190",1},
                        {"props_p202",1},
                        {"props_p214",1},
                        {"props_p226",1},

                        {"props_p352",1},
                        {"props_p356",1},
                        {"props_p360",1},
                        {"props_p364",1},
                        {"props_p368",1},
                        {"props_p372",1},
                        {"props_p376",1},
                        {"props_p380",1},

                        {"props_p533",1},
                        {"props_p537",1},
                        {"props_p541",1},
                        {"props_p545",1},
                        {"props_p549",1},
                        {"props_p553",1},
                        {"props_p557",1},
                        {"props_p561",1},

                        {"props_p181",2},
                        {"props_p193",2},
                        {"props_p205",2},
                        {"props_p217",2},
                        {"props_p184",2},
                        {"props_p196",2},
                        {"props_p208",2},
                        {"props_p220",2},
                        {"props_p187",2},
                        {"props_p199",2},
                        {"props_p211",2},
                        {"props_p223",2},
                        {"props_p190",2},
                        {"props_p202",2},
                        {"props_p214",2},
                        {"props_p226",2},

                        {"props_p352",2},
                        {"props_p356",2},
                        {"props_p360",2},
                        {"props_p364",2},
                        {"props_p368",2},
                        {"props_p372",2},
                        {"props_p376",2},
                        {"props_p380",2},

                        {"props_p533",2},
                        {"props_p537",2},
                        {"props_p541",2},
                        {"props_p545",2},
                        {"props_p549",2},
                        {"props_p553",2},
                        {"props_p557",2},
                        {"props_p561",2},

                        {"props_p181",3},
                        {"props_p193",3},
                        {"props_p205",3},
                        {"props_p217",3},
                        {"props_p184",3},
                        {"props_p196",3},
                        {"props_p208",3},
                        {"props_p220",3},
                        {"props_p187",3},
                        {"props_p199",3},
                        {"props_p211",3},
                        {"props_p223",3},
                        {"props_p190",3},
                        {"props_p202",3},
                        {"props_p214",3},
                        {"props_p226",3},

                        {"props_p352",3},
                        {"props_p356",3},
                        {"props_p360",3},
                        {"props_p364",3},
                        {"props_p368",3},
                        {"props_p372",3},
                        {"props_p376",3},
                        {"props_p380",3},

                        {"props_p533",3},
                        {"props_p537",3},
                        {"props_p541",3},
                        {"props_p545",3},
                        {"props_p549",3},
                        {"props_p553",3},
                        {"props_p557",3},
                        {"props_p561",3},

                        {"props_p182",1},
                        {"props_p194",1},
                        {"props_p206",1},
                        {"props_p218",1},
                        {"props_p185",1},
                        {"props_p197",1},
                        {"props_p209",1},
                        {"props_p221",1},
                        {"props_p188",1},
                        {"props_p200",1},
                        {"props_p212",1},
                        {"props_p224",1},
                        {"props_p191",1},
                        {"props_p203",1},
                        {"props_p215",1},
                        {"props_p227",1},

                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p377",1},
                        {"props_p381",1},

                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p558",1},
                        {"props_p562",1},


                        {"accessory_f0",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                    },
                },
            },
        },
        --春节版本
        [5] = {
            type = 1,
            sortId = 91,
            version=5,
            serverreward = {
                -- 排行奖励（前10名）
                r = {
                    {props_p90=2,accessory_f0=3}, -- 先进配件箱 * 2 万能碎片 * 3
                    {props_p90=1,accessory_f0=3}, -- 先进配件箱 * 1 万能碎片 * 3
                    {props_p90=1,accessory_f0=1}, -- 先进配件箱 * 1 万能碎片 * 1
                    {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                    {props_p89=2,accessory_f0=1}, -- 精良配件箱 * 2 万能碎片 * 1
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                    {props_p89=2,accessory_p6=5}, -- 精良配件箱 * 2 工具箱 * 5
                },

                -- 进行排行需要的最低积分
                rankPoint = 300,

                -- 探索需要的金币
                searchConsume_1x = 58,
                searchConsume_10x = 468,

                -- 资源对应的积分数
                res4point = {
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {6,10},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {12,20},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {18,30},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {24,40},
                    {48,80},
                    {6,10},
                    {6,10},
                    {3,5},
                },

                -- 奖池
                pool={
                    {100},
                    {
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        10,10,10,10,10,10,10,10,    10,10,10,10,10,10,10,10,    5,5,5,5,5,5,5,5,    5,5,5,5,5,5,5,5,
                        6,6,6,6,6,6,6,6,        6,6,6,6,6,6,6,6,        3,3,3,3,3,3,3,3,    3,3,3,3,3,3,3,3,
                        16,48,128,256
                    },
                    {
                        {"props_p181",1},
                        {"props_p193",1},
                        {"props_p205",1},
                        {"props_p217",1},
                        {"props_p184",1},
                        {"props_p196",1},
                        {"props_p208",1},
                        {"props_p220",1},
                        {"props_p187",1},
                        {"props_p199",1},
                        {"props_p211",1},
                        {"props_p223",1},
                        {"props_p190",1},
                        {"props_p202",1},
                        {"props_p214",1},
                        {"props_p226",1},

                        {"props_p352",1},
                        {"props_p356",1},
                        {"props_p360",1},
                        {"props_p364",1},
                        {"props_p368",1},
                        {"props_p372",1},
                        {"props_p376",1},
                        {"props_p380",1},

                        {"props_p533",1},
                        {"props_p537",1},
                        {"props_p541",1},
                        {"props_p545",1},
                        {"props_p549",1},
                        {"props_p553",1},
                        {"props_p557",1},
                        {"props_p561",1},

                        {"props_p181",2},
                        {"props_p193",2},
                        {"props_p205",2},
                        {"props_p217",2},
                        {"props_p184",2},
                        {"props_p196",2},
                        {"props_p208",2},
                        {"props_p220",2},
                        {"props_p187",2},
                        {"props_p199",2},
                        {"props_p211",2},
                        {"props_p223",2},
                        {"props_p190",2},
                        {"props_p202",2},
                        {"props_p214",2},
                        {"props_p226",2},

                        {"props_p352",2},
                        {"props_p356",2},
                        {"props_p360",2},
                        {"props_p364",2},
                        {"props_p368",2},
                        {"props_p372",2},
                        {"props_p376",2},
                        {"props_p380",2},

                        {"props_p533",2},
                        {"props_p537",2},
                        {"props_p541",2},
                        {"props_p545",2},
                        {"props_p549",2},
                        {"props_p553",2},
                        {"props_p557",2},
                        {"props_p561",2},

                        {"props_p181",3},
                        {"props_p193",3},
                        {"props_p205",3},
                        {"props_p217",3},
                        {"props_p184",3},
                        {"props_p196",3},
                        {"props_p208",3},
                        {"props_p220",3},
                        {"props_p187",3},
                        {"props_p199",3},
                        {"props_p211",3},
                        {"props_p223",3},
                        {"props_p190",3},
                        {"props_p202",3},
                        {"props_p214",3},
                        {"props_p226",3},

                        {"props_p352",3},
                        {"props_p356",3},
                        {"props_p360",3},
                        {"props_p364",3},
                        {"props_p368",3},
                        {"props_p372",3},
                        {"props_p376",3},
                        {"props_p380",3},

                        {"props_p533",3},
                        {"props_p537",3},
                        {"props_p541",3},
                        {"props_p545",3},
                        {"props_p549",3},
                        {"props_p553",3},
                        {"props_p557",3},
                        {"props_p561",3},

                        {"props_p182",1},
                        {"props_p194",1},
                        {"props_p206",1},
                        {"props_p218",1},
                        {"props_p185",1},
                        {"props_p197",1},
                        {"props_p209",1},
                        {"props_p221",1},
                        {"props_p188",1},
                        {"props_p200",1},
                        {"props_p212",1},
                        {"props_p224",1},
                        {"props_p191",1},
                        {"props_p203",1},
                        {"props_p215",1},
                        {"props_p227",1},

                        {"props_p353",1},
                        {"props_p357",1},
                        {"props_p361",1},
                        {"props_p365",1},
                        {"props_p369",1},
                        {"props_p373",1},
                        {"props_p377",1},
                        {"props_p381",1},

                        {"props_p534",1},
                        {"props_p538",1},
                        {"props_p542",1},
                        {"props_p546",1},
                        {"props_p550",1},
                        {"props_p554",1},
                        {"props_p558",1},
                        {"props_p562",1},


                        {"accessory_f0",1},
                        {"accessory_p1",1},
                        {"accessory_p2",2},
                        {"accessory_p3",5},
                    },
                },
            },
        },
    },

    -- 水晶丰收 ----------------------------------------------
    crystalHarvest = {
        type = 1,
        sortId = 100,

        -- 每天可以领取一次【角色等级】* 3000 的【水晶】
        baseGoldNum = 3000,

        -- 水晶产量翻倍
        baseGoldGrow = {gold=2},

        -- 活动期间内，可以购买 10 次折扣礼包
        props={
            p96=0.299,
        },
        maxCount={
            p96=10,
        },

    },
    -- end

    --活动其间首充返利
    rechargeRebate={
	    multiSelectType=true,
    [1]={ --老配置
        type   = 1 ,
        sortId = 12,
		special =0,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =0.2,
        },
        reward = {
            u={gems=0.2},
        },
	  },
	[2]={ 
        type   = 1 ,
        sortId = 12,
		special =0,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =0.3,
        },
        reward = {
            u={gems=0.3},
        },
	  },  
	  
    [3]={ 
        type   = 1 ,
        sortId = 12,
		special =0,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =0.4,
        },
        reward = {
            u={gems=0.4},
        },
	  },	  

	[4]={ --老配置
        type   = 1 ,
        sortId = 12,
		--special 1 为春节 0 为日常
		special =1,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =0.5,
        },
        reward = {
            u={gems=0.5},
        },
	  },	  
	[5]={ --老配置
        type   = 1 ,
        sortId = 12,
		special =1,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =0.7,
        },
        reward = {
            u={gems=0.7},
        },
	  },		  
	[6]={ --老配置
        type   = 1 ,
        sortId = 12,
		special =0,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =1,
        },
        reward = {
            u={gems=1},
        },
	  },		  
	[7]={ --老配置
        type   = 1 ,
        sortId = 12,
		special =0,
        -- value={exp=1,honors=2},
       serverreward = {
            userinfo_gems =0.8,
        },
        reward = {
            u={gems=0.8},
        },
	  },		  
    },

    --日本充值返利活动
    customRechargeRebate = {

        type   = 1 ,
        sortId = 377,
        -- value={exp=1,honors=2},
        serverreward = {
            userinfo_gems =0.2,
        },
        reward = {
            u={gems=0.2},
        },
    },
    --成长计划
    growingPlan={

        type   = 1 ,
        sortId = 11,
        -- value={exp=1,honors=2},
    },

    -- 巨兽再现
    monsterComeback = {
        type = 1,
        sortId = 130,
        serverreward={
            pool={{100},{16,16,21,21,8,8,8,8,},{{"part1",2},{"part1",4},{"part2",2},{"part2",4},{"props_p12",1},{"props_p42",1},{"props_p11",1},{"props_p43",1},}},
            upgradePartConsume=20,
            tank4point = {a10001=5,a10002=190,a10003=5200,a10004=61000,a10005=1000000,a10011=11,a10012=420,a10013=9000,a10014=93000,a10015=1000000,a10021=26,a10022=880,a10023=15000,a10024=100000,a10025=2000000,a10031=50,a10032=1000,a10033=20000,a10034=170000,a10035=2000000,a10043=4400000,a10053=5900000,a10073=5900000,a10063=4400000,a10082=9000000,a10006=4000000,a10016=6000000,a10026=9000000,a10036=9000000,a10093=1000000,a10044=10000000,a10054=11000000,a10064=12000000,a10074=13000000,a10083=15000000,a10103=1000000,a10113=6000000,a10123=6000000,},
            gemCost=38,
            pointCost=30000000,
        },
    },


    --配件进化
    accessoryEvolution={

        type   = 1 ,
        sortId = 11,
        serverreward = {
            value =0.15,
            maxBuyTime=3,
            gems=3588,
            reward={props_p96=1},
        },
        reward = {
            value =0.15,
            maxBuyTime=3,
            u={gems=3588},
        },
    },

    --征战补给线
    accessoryFight={
        type   = 1 ,
        sortId = 11,
        serverreward={
            reducePrice=0.5,
            powerAdd=0.3
        }
    },

    --火力全开
    allianceDonate={
        type   = 1 ,
        sortId = 11,
        serverreward={
                 value =0.5,
                 reward={
                     {props_p20=20,props_p19=60,props_p89=1},
                     {props_p20=15,props_p19=30,props_p89=1},
                     {props_p20=10,props_p19=20},
                     {props_p20=5,props_p19=10},
                     {props_p20=5,props_p19=10},
                     {props_p20=5},
                     {props_p20=5},
                     {props_p20=5},
                     {props_p20=5},
                     {props_p20=5},

                 },
        }
    },

    -- vip特权宝箱活动
    vipRight={
        type=1,
        sortId=140,
        serverreward={
            p263={num4Vip={0,5,10,15,20,25,30,35,40,45,50,55,60,65},cost=20,},
            p264={num4Vip={0,5,10,15,20,25,30,35,40,45,50,55,60,65},cost=50,},
            p265={num4Vip={0,1,2,4,6,8,10,12,14,16,18,20,22,24},cost=100,},
        },
        reward={
            boxCfg={
                {pid="p263",num4Vip={0,5,10,15,20,25,30,35,40,45,50,55,60,65},cost=20,reward={p={{p88=1,index=1},{p41=1,index=2},},e={{p1=1,index=3},{p5=1,index=4},},}},
                {pid="p264",num4Vip={0,5,10,15,20,25,30,35,40,45,50,55,60,65},cost=50,reward={p={{p89=1,index=1},{p16=1,index=2},{p36=1,index=3},},e={{p5=1,index=4},},}},
                {pid="p265",num4Vip={0,1,2,4,6,8,10,12,14,16,18,20,22,24},cost=100,reward={p={{p89=1,index=1},{p90=1,index=2},{p230=1,index=3},{p5=1,index=4},},}},
            },
        }
    },

    -- 前线军需活动
    rechargeDouble = {
        type = 1,
        sortId = 140,
    },
	
	-- 战备军需活动
	warRecharge = {
	
		rechargeRewardRadio=1.0, --充值反利比例
	
		serverRewardLimit={userinfo_gems=25000,}, --返利上限
		
		rewardLimit={u={gems=25000}},
	},

    --军团战收获日
    harvestDay={
        type   = 1 ,
        sortId = 11,
        serverreward={
            rankCount=3,
            joinCount=3,
            winCount=1,
              --排行前十，参战，胜利奖励
            rank = {point=1000},
            joinbattle ={troops_a10004=5,troops_a10034=5,troops_a10043=2},
            winbattle={accessory_p3=50,accessory_p6=10,accessory_p4=10000,props_p36=1},

        },
        numconfig={{3,3,1},10},

    },



    --基金计划
    userFund={
    multiSelectType=true,
    [1]={ --老配置
        type=1,
        sortId=142,
        serverreward={
        r={
            {props_p89=1,props_p30=1,},--精良配件箱*1大量水晶*1
            {accessory_p6=1,accessory_p3=5,},--工具箱*1电钻*5
            {accessory_p5=5,accessory_p1=2,},--复原图纸*5设计蓝图*2
            {accessory_f0=1,accessory_p2=5,},--万能碎片*1神秘矿物*5
            {props_p90=1,props_p20=5,},--先进配件箱*1统率书*5
        },
        cost = {860,2600,6050,12100,17300},
        extra ={20,62,146,300,430},
        },
        reward={
            {p={{p89=1,index=1},{p30=1,index=2}}},
            {e={{p6=1,index=1},{p3=5,index=2}}},
            {e={{p5=5,index=1},{p1=2,index=2}}},
            {e={{f0=1,index=1},{p2=5,index=2}}},
            {p={{p90=1,index=1},{p20=5,index=2}}},
        },
        cost = {860,2600,6050,12100,17300},
        extra ={20,62,146,300,430,},        
        chargeday=7,        
    },        



    [2]={ --将领相关，56配件
        type=1,
        sortId=142,
        serverreward={
        r={
        {props_p20=5,props_p393=20,},--统率书*5火控核芯*20
        {props_p447=10,props_p394=20,},--中级将领经验书*10聚变核芯*20
        {props_p601=50,props_p395=20,},--精锐勋章*50导航核芯*20
        {accessory_f0=1,props_p396=20,},--万能碎片*1爆燃核芯*20
        {props_p270=1,props_p606=10,},--卡夫卡的先进配件箱*1铜质装甲勋章*10
        },
        cost = {860,2600,6050,12100,17300},
        extra ={20,62,146,300,430},
        },
        reward={
        {p={{p20=5,index=1},{p393=20,index=2}}},
        {p={{p447=10,index=1},{p394=20,index=2}}},
        {p={{p601=50,index=1},{p395=20,index=2}}},
        {e={{f0=1,index=1}},p={{p396=20,index=2}}},
        {p={{p270=1,index=1},{p606=10,index=2}}},
        },
        cost = {860,2600,6050,12100,17300},
        extra ={20,62,146,300,430,},        
        chargeday=7,        
        },        
            
    }, 


    --勤劳致富
  hardGetRich={--最高5级坦克
     multiSelectType=true, 
  [1]={
	type=1,
	sortId=143,
	serverreward={
	rankreward={
	{troops_a10035=30},--1
	{troops_a10025=25},--2
	{troops_a10005=20},--3
	{troops_a10034=20},--4~5
	{troops_a10024=20},--6~10
	{troops_a10004=20},--11~30
	},
	personreward={
	{troops_a10003=20},
	{troops_a10033=20},
	{troops_a10004=20},
	{troops_a10034=20},
	},
	},
	condition=0.2,
	personalGoal={4000000,20000000,60000000,120000000},
	rankreward={
	{o={{a10035=30,index=1}}},--1
	{o={{a10025=25,index=1}}},--2
	{o={{a10005=20,index=1}}},--3
	{o={{a10034=20,index=1}}},--4~5
	{o={{a10024=20,index=1}}},--6~10
	{o={{a10004=20,index=1}}},--11~30
	},
	personreward={
	{o={{a10003=20,index=1}}},
	{o={{a10033=20,index=1}}},
	{o={{a10004=20,index=1}}},
	{o={{a10034=20,index=1}}},
	},
	},
	--勤劳致富升级版					
	[2]={	  --最高6级坦克				
	type=1,					
	sortId=143,					
	serverreward={					
	rankreward={					
	{	troops_a10036=30	},	--1		
	{	troops_a10026=25	},	--2		
	{	troops_a10006=20	},	--3		
	{	troops_a10035=20	},	--4~5		
	{	troops_a10025=20	},	--6~10		
	{	troops_a10005=20	},	--11~30		
	},					
	personreward={					
	{	troops_a10004=20	},			
	{	troops_a10034=20	},			
	{	troops_a10005=20	},			
	{	troops_a10035=20	},			
	},					
	},
	condition=0.2,	
	personalGoal={	8000000,	40000000,	120000000,	240000000	},
	rankreward={					
	{o={{	a10036=30,index=1	}}},	--1		
	{o={{	a10026=25,index=1	}}},	--2		
	{o={{	a10006=20,index=1	}}},	--3		
	{o={{	a10035=20,index=1	}}},	--4~5		
	{o={{	a10025=20,index=1	}}},	--6~10		
	{o={{	a10005=20,index=1	}}},	--11~30		
	},					
	personreward={					
	{o={{	a10004=20,index=1	}}},			
	{o={{	a10034=20,index=1	}}},			
	{o={{	a10005=20,index=1	}}},			
	{o={{	a10035=20,index=1	}}},			
	},					
	},					


	--勤劳致富老服版					
	[3]={	  --最高7级坦克				
	type=1,					
	sortId=143,					
	serverreward={					
	rankreward={					
	{	troops_a10037=30	},	--1		
	{	troops_a10027=25	},	--2		
	{	troops_a10007=20	},	--3		
	{	troops_a10036=20	},	--4~5		
	{	troops_a10026=20	},	--6~10		
	{	troops_a10006=20	},	--11~30		
	},					
	personreward={					
	{	troops_a10005=20	},			
	{	troops_a10035=20	},			
	{	troops_a10006=20	},			
	{	troops_a10036=20	},			
	},					
	},	
	condition=0.2,	
	personalGoal={	40000000,	200000000,	600000000,	1200000000	},
	rankreward={					
	{o={{	a10037=30,index=1	}}},	--1		
	{o={{	a10027=25,index=1	}}},	--2		
	{o={{	a10007=20,index=1	}}},	--3		
	{o={{	a10036=20,index=1	}}},	--4~5		
	{o={{	a10026=20,index=1	}}},	--6~10		
	{o={{	a10006=20,index=1	}}},	--11~30		
	},					
	personreward={					
	{o={{	a10005=20,index=1	}}},			
	{o={{	a10035=20,index=1	}}},			
	{o={{	a10006=20,index=1	}}},			
	{o={{	a10036=20,index=1	}}},			
	},					
	},					

    },

  
    --投资计划 
    investPlan={ 
        type=1, 
        sortID=143, 
        serverreward={ 
            extra={40,106,190,390,}, 
        }, 
        cost={1250,3300,5780,11600,}, 
        extra={40,106,190,390,}, 
        chargeday=3, 
    },

    --VIP总动员活动 
    vipAction={ 
        type=1, 
        sortID=143, 
        serverreward={ 
            reward={ 
                {props_p273=1,props_p267=5,}, 
            }, 
            r={ 
                {props_p272=1,}, 
                {props_p272=2,}, 
            }, 
        }, 
        cost={12000}, 
        dayrecharge={1,1000}, 
        reward={ 
            {p={{p273=1,index=1},{p267=5,index=2}}}, 
        }, 
        rd={ 
            {p={{p272=1,index=1}}}, 
            {p={{p272=2,index=1}}}, 
        }, 
    },


   --钢铁之心
    heartOfIron={
        type=1,
        sortId=143,
        serverreward={
            {userinfo_gems=10,props_p20=3,},
            {userinfo_gems=20,props_p19=20,troops_a10022=10,},
            {userinfo_gems=20,props_p30=5,troops_a10032=10,},
            {userinfo_gems=20,accessory_p3=30,troops_a10003=20,},
            {userinfo_gems=30,accessory_p2=10,troops_a10013=20,},
            {userinfo_gems=30,accessory_p1=5,troops_a10023=20,},
            {userinfo_gems=30,accessory_p6=5,troops_a10033=20,props_p89=1,},
        },
        condition={
            blevel={10,1},--基地
            ulevel={10,2},--用户
            alevel={5,3},--配件
            acrd={5,4},--副本
            star={100,5},--星星
            tech={10,6},--科技
            troops={100,7},--重型
        },
        reward={
            {u={{gems=10,index=1},},p={{p20=3,index=2},},},
            {u={{gems=20,index=1},},p={{p19=20,index=2},},o={{a10022=10,index=2},},},
            {u={{gems=20,index=1},},p={{p30=5,index=2},},o={{a10032=10,index=2},},},
            {u={{gems=20,index=1},},e={{p3=30,index=2},},o={{a10003=20,index=2},},},
            {u={{gems=30,index=1},},e={{p2=10,index=2},},o={{a10013=20,index=2},},},
            {u={{gems=30,index=1},},e={{p1=5,index=2},},o={{a10023=20,index=2},},},
            {u={{gems=30,index=1},},e={{p6=5,index=2},},o={{a10033=20,index=2},},p={{p89=1,index=2},},},
        },
        changeday=7,
    },

    -- 10日登陆奖励(昆仑封测)
    tendayslogin={
        type=1,
        sortId=150,
        serverreward={
            {userinfo_gems=1000,props_p2=1,props_p272=1,troops_a10002=5,},
            {userinfo_gems=1000,props_p20=5,props_p272=5,troops_a10003=10,},
            {userinfo_gems=500,props_p15=1,props_p47=5,props_p102=1,},
            {userinfo_gems=500,props_p14=3,props_p272=6,troops_a10013=20,},
            {userinfo_gems=500,props_p3=1,props_p47=5,props_p118=1,},
            {userinfo_gems=600,props_p19=100,props_p273=2,troops_a10023=30,},
            {userinfo_gems=700,props_p20=10,props_p47=10,props_p106=1,},
            {userinfo_gems=800,props_p16=1,props_p273=3,troops_a10033=50,},
            {userinfo_gems=900,props_p45=1,props_p47=10,props_p154=1,},
            {userinfo_gems=1000,props_p5=1,props_p274=1,troops_a10004=50,},
        },
    },

    -- 开服献礼
    openGift={ 
        type=1, 
        sortId=160, 
        baseGoldNum = 2000, 
        buy={ 
            {id=1,gift="p287",num=3,discount=0.72,}, 
            {id=2,gift="p288",num=3,discount=0.6,}, 
            {id=3,gift="p289",num=3,discount=0.6,}, 
            {id=4,gift="p99",num=3,discount=0.299,}, 
            {id=5,gift="p51",num=3,discount=0.299,}, 
            {id=6,gift="p96",num=3,discount=0.299,}, 
            {id=7,gift="p97",num=3,discount=0.299,}, 
            {id=8,gift="p98",num=3,discount=0.299,}, 
            {id=9,gift="p3",num=3,discount=0.6,}, 
            {id=10,gift="p4",num=3,discount=0.5,}, 
            {id=11,gift="p1",num=3,discount=0.8,}, 
            {id=12,gift="p48",num=3,discount=0.399,}, 
            {id=13,gift="p290",num=3,discount=0.571,}, 
            {id=14,gift="p49",num=3,discount=0.71,}, 
        }, 
    },

    -- 飓风来袭
    stormrocket = {
	    multiSelectType=true,
         [1] = {
        type = 1,
        sortId = 170,
        reward={
            pool={
                {100},
                {1,1,1,1,1,1,1,1,1,},
                {{"part1",5},{"part2",5},{"part3",5},{"part4",5},{"part5",5},{"part6",5},{"part7",5},{"part8",5},{"part9",5}}
            },
            gemCost=38, -- 一次投资花费
            gemCost_10=328, -- 10次抽奖花费
            buyGemCost = 114,   -- 一次购买花费(只能购买自己没有的碎片)
            buyPartNum = 5, -- 一次购买量
            dailyFree = 1,  -- 每日免费抽奖的次数
            vipMulti = {2,2,2,2,2,2,3,3,3,3,3}, -- vip对应的暴击倍数(抽出的碎片数量*此对应值)
            criclyChance = 15,  -- 暴击概率
            partToTank = 1, -- 兑换一组坦克消耗的碎片数量（9个位置）
            tankId = "a10082",
        },
    },
			--产出黄蜂级航空母舰
		[2]={
		        type = 1,
        sortId = 170,
        reward={
            pool={
                {100},
                {1,1,1,1,1,1,1,1,1,},
                {{"part1",5},{"part2",5},{"part3",5},{"part4",5},{"part5",5},{"part6",5},{"part7",5},{"part8",5},{"part9",5}}
            },
            gemCost=38, -- 一次投资花费
            gemCost_10=328, -- 10次抽奖花费
            buyGemCost = 114,   -- 一次购买花费(只能购买自己没有的碎片)
            buyPartNum = 5, -- 一次购买量
            dailyFree = 1,  -- 每日免费抽奖的次数
            vipMulti = {2,2,2,2,2,2,3,3,3,3,3}, -- vip对应的暴击倍数(抽出的碎片数量*此对应值)
            criclyChance = 15,  -- 暴击概率
            partToTank = 1, -- 兑换一组坦克消耗的碎片数量（9个位置）
            tankId = "a20153",
        },
		}
	
	},

        -- 飓风来袭gai(vip减价钱)
        stormrocketGai = {
            multiSelectType=true,
            [1] = {
                type = 1,
                sortId = 170,
                reward={
                    pool={
                        {100},
                        {1,1,1,1,1,1,1,1,1,},
                        {{"part1",5},{"part2",5},{"part3",5},{"part4",5},{"part5",5},{"part6",5},{"part7",5},{"part8",5},{"part9",5}}
                    },
                    gemCost=38, -- 一次投资花费
                    gemCost_10=328, -- 10次抽奖花费
                    buyGemCost = 114,   -- 一次购买花费(只能购买自己没有的碎片)
                    buyPartNum = 5, -- 一次购买量
                    dailyFree = 1,  -- 每日免费抽奖的次数
                    vipMulti = {2,2,2,2,2,2,3,3,3,3,3}, -- vip对应的暴击倍数(抽出的碎片数量*此对应值)
                    criclyChance = 15,  -- 暴击概率
                    partToTank = 1, -- 兑换一组坦克消耗的碎片数量（9个位置）
                    tankId = "a10082",
                },
            },
        },
 --军备竞赛
    armsRace={
    multiSelectType=true,
    [1]={ --5级坦克给5.5级
        type=1,
        sortId=143,
        reward={
            a10005={id=1,n=100,r="a10073",num=2}, -- 集齐n个龙珠就可以召唤num个神龙
            a10015={id=2,n=100,r="a10053",num=3},
            a10025={id=3,n=100,r="a10063",num=5},
            a10035={id=4,n=100,r="a10043",num=6},
            a10004={id=5,n=100,r="a10005",num=10},
            a10014={id=6,n=100,r="a10015",num=10},
            a10024={id=7,n=100,r="a10025",num=10},
            a10034={id=8,n=100,r="a10035",num=10},
            a10003={id=9,n=100,r="a10004",num=10},
            a10013={id=10,n=100,r="a10014",num=10},
            a10023={id=11,n=100,r="a10024",num=10},
            a10033={id=12,n=100,r="a10034",num=10},
            a10002={id=13,n=100,r="a10003",num=5},
            a10012={id=14,n=100,r="a10013",num=5},
            a10022={id=15,n=100,r="a10023",num=5},
            a10032={id=16,n=100,r="a10033",num=5},
            a10001={id=17,n=100,r="a10002",num=5},
            a10011={id=18,n=100,r="a10012",num=5},
            a10021={id=19,n=100,r="a10022",num=5},
            a10031={id=20,n=100,r="a10032",num=5},
        },
    },



    [2]={ --6级坦克给6.5级
    type=1,
    sortId=143,
    reward={
        a10006={id=1,n=100,r="a10074",num=4}, -- 集齐n个龙珠就可以召唤num个神龙
        a10016={id=2,n=100,r="a10054",num=4},
        a10026={id=3,n=100,r="a10064",num=5},
        a10036={id=4,n=100,r="a10083",num=5},
        a10005={id=5,n=100,r="a10073",num=2},
        a10015={id=6,n=100,r="a10053",num=3},
        a10025={id=7,n=100,r="a10063",num=5},
        a10035={id=8,n=100,r="a10082",num=6},
        a10004={id=9,n=100,r="a10005",num=10},
        a10014={id=10,n=100,r="a10015",num=10},
        a10024={id=11,n=100,r="a10025",num=10},
        a10034={id=12,n=100,r="a10035",num=10},
        a10003={id=13,n=100,r="a10004",num=10},
        a10013={id=14,n=100,r="a10014",num=10},
        a10023={id=15,n=100,r="a10024",num=10},
        a10033={id=16,n=100,r="a10034",num=10},
        a10002={id=17,n=100,r="a10003",num=5},
        a10012={id=18,n=100,r="a10013",num=5},
        a10022={id=19,n=100,r="a10023",num=5},
        a10032={id=20,n=100,r="a10033",num=5},
        a10001={id=21,n=100,r="a10002",num=5},
        a10011={id=22,n=100,r="a10012",num=5},
        a10021={id=23,n=100,r="a10022",num=5},
        a10031={id=24,n=100,r="a10032",num=5},
    },
    },

    },

    --抢红包
    grabRed={
        multiSelectType=true,
        [1]={
            type=1,
            sortId=145,
            version=1,
            serverreward={
            {props_p885=1},
            },
            reward={p={{p885=1,index=1}}},
             --活动开始给的代币
            conditiongems=1500,
             --代币替代金币最大的比例
            value=0.9,
             --购买红包需要的金币
            cost=3000,
             --抢红包给的代币范围
            range={100,200},
             --每个红包被抢的最大人数
            maxcount=5,
        },           
        [2]={
            type=1,
            sortId=145,
            version=1,
            serverreward={
            {props_p1075=1},
            },
            reward={p={{p1075=1,index=1}}},
             --活动开始给的代币
            conditiongems=1500,
             --代币替代金币最大的比例
            value=0.9,
             --购买红包需要的金币
            cost=3000,
             --抢红包给的代币范围
            range={100,200},
             --每个红包被抢的最大人数
            maxcount=5,
        },
        [3]={  --虎王咆哮
            type=1,
            sortId=145,
            version=2,
            serverreward={
            {props_p882=1},
            },
            reward={p={{p882=1,index=1}}},
             --活动开始给的代币
            conditiongems=1500,
             --代币替代金币最大的比例
            value=0.9,
             --购买红包需要的金币
            cost=3000,
             --抢红包给的代币范围
            range={100,200},
             --每个红包被抢的最大人数
            maxcount=5,
        },
        [4]={ --怒狮来袭
            type=1,
            sortId=145,
            version=3,
            serverreward={
            {props_p883=1},
            },
            reward={p={{p883=1,index=1}}},
             --活动开始给的代币
            conditiongems=1500,
             --代币替代金币最大的比例
            value=0.9,
             --购买红包需要的金币
            cost=3000,
             --抢红包给的代币范围
            range={100,200},
             --每个红包被抢的最大人数
            maxcount=5,
        },
        [5]={
        type=1,
        sortId=145,
        version=2,
        serverreward={
        {props_p1544=1},
        },
        reward={p={{p1544=1,index=1}}},
         --活动开始给的代币
        conditiongems=1500,
         --代币替代金币最大的比例
        value=0.9,
         --购买红包需要的金币
        cost=3000,
         --抢红包给的代币范围
        range={100,200},
         --每个红包被抢的最大人数
        maxcount=5,
        },

        [6]={
        type=1,
        sortId=145,
        version=3,
        serverreward={
        {props_p1545=1},
        },
        reward={p={{p1545=1,index=1}}},
         --活动开始给的代币
        conditiongems=1500,
         --代币替代金币最大的比例
        value=0.9,
         --购买红包需要的金币
        cost=3000,
         --抢红包给的代币范围
        range={100,200},
         --每个红包被抢的最大人数
        maxcount=5,
        },

    },

        --有福同享
    shareHappiness={
        type=1,
        sortId=146,
        serverreward={--后台
            {{props_p887=1},8400},
            {{props_p888=1},3420},
            {{props_p889=1},960},
            {{props_p890=1},460},
            {{props_p891=1},160},
            {{props_p892=1},50},
        },
        reward={--前台
            {p={{p887=1,index=1}}},
            {p={{p888=1,index=1}}},
            {p={{p889=1,index=1}}},
            {p={{p890=1,index=1}}},
            {p={{p891=1,index=1}}},
            {p={{p892=1,index=1}}},
        },
    },
         
    --坦克拉霸
    slotMachine={
        free=1,--每天1次免费的机会
        cost=28,--不免费时抽一次的金币花费
        mul=10,--10倍模式
        mulc=9,--10倍模式花费的金币是mulC*cost
        --只前端使用的配置（显示相关）
--        my={
--            {id=1,pic="ShadowTank"},--对应的显示图片
--            {id=2,pic="ShadowWeapon"},
--            {id=3,pic="ShadowArtillery"},
--            {id=4,pic="ShadowRocket"},
--        },
        --兑换配置表
        r={
            --同种图标抽到3次奖励
            {id=1,num=3,reward={o={{a10073=5,index=1}}}},--id为1的道具抽到了3次
            {id=2,num=3,reward={o={{a10053=5,index=1}}}},
            {id=3,num=3,reward={o={{a10043=5,index=1}}}},
            {id=4,num=3,reward={o={{a10082=5,index=1}}}},
            --同种图标抽到2次奖励
            {id=1,num=2,reward={o={{a10005=3,index=1}}}},
            {id=2,num=2,reward={o={{a10015=3,index=1}}}},
            {id=3,num=2,reward={o={{a10025=3,index=1}}}},
            {id=4,num=2,reward={o={{a10035=3,index=1}}}},
            --同种图标抽到1次奖励
            {id=1,num=1,reward={o={{a10004=2,index=1}}}},
            {id=2,num=1,reward={o={{a10014=2,index=1}}}},
            {id=3,num=1,reward={o={{a10024=2,index=1}}}},
            {id=4,num=1,reward={o={{a10034=2,index=1}}}},
        },

        serverreward={
            --同种图标抽到1次奖励
            { --num
                {troops_a10004=2}, --id
                {troops_a10014=2},
                {troops_a10024=2},
                {troops_a10034=2},
            },
            --同种图标抽到2次奖励
            {
                {troops_a10005=3},
                {troops_a10015=3},
                {troops_a10025=3},
                {troops_a10035=3},
            },
            --同种图标抽到3次奖励
            {
                {troops_a10073=5},--id为1的道具抽到了3次
                {troops_a10053=5},
                {troops_a10043=5},
                {troops_a10082=5},
            },
        },
    },

    --坦克拉霸（小）
	
    slotMachine2={
        type=1,
        sortId = 297,
        free=1, --每天1次免费的机会
        cost=18, --不免费时抽一次的金币花费
        mul=10, --10倍模式
        mulc=9, --10倍模式花费的金币是mulC*cost
        --只前端使用的配置（显示相关）
        my={
            {id=1,pic="ShadowTank"}, --对应的显示图片
            {id=2,pic="ShadowWeapon"},
            {id=3,pic="ShadowArtillery"},
            {id=4,pic="ShadowRocket"},
        },
        --兑换配置表
        r={
            --同种图标抽到3次奖励
            {id=1,num=3,reward={o={{a10005=5,index=1}}}}, --id为1的道具抽到了3次
            {id=2,num=3,reward={o={{a10015=5,index=1}}}},
            {id=3,num=3,reward={o={{a10025=5,index=1}}}},
            {id=4,num=3,reward={o={{a10035=5,index=1}}}},
            --同种图标抽到2次奖励
            {id=1,num=2,reward={o={{a10004=3,index=1}}}},
            {id=2,num=2,reward={o={{a10014=3,index=1}}}},
            {id=3,num=2,reward={o={{a10024=3,index=1}}}},
            {id=4,num=2,reward={o={{a10034=3,index=1}}}},
            --同种图标抽到1次奖励
            {id=1,num=1,reward={o={{a10003=2,index=1}}}},
            {id=2,num=1,reward={o={{a10013=2,index=1}}}},
            {id=3,num=1,reward={o={{a10023=2,index=1}}}},
            {id=4,num=1,reward={o={{a10033=2,index=1}}}},
        },
        serverreward={
            --同种图标抽到1次奖励
            {
                {troops_a10003=2},
                {troops_a10013=2},
                {troops_a10023=2},
                {troops_a10033=2},
            --同种图标抽到2次奖励
            },
            {
                {troops_a10004=3},
                {troops_a10014=3},
                {troops_a10024=3},
                {troops_a10034=3},
            },
            --同种图标抽到3次奖励
            {
                {troops_a10005=5}, --id为1的道具抽到了3次
                {troops_a10015=5},
                {troops_a10025=5},
                {troops_a10035=5},
            },
        },
    },

    --日本坦克拉霸
    slotMachineCommon = {
        multiSelectType = true,
		
		
	--配置12开始
        [12] = {
            --坦克拉霸（567，折扣版）
            type=1,
            sortId = 307,
            free=1,          --每天1次免费的机会
            cost=58,       --不免费时抽一次的金币花费
            mul=10,    --10倍模式
            mulc=9,    --10倍模式花费的金币是mulC*cost
             --只前端使用的配置（显示相关）
            my={
            {id=1,  pic="ShadowTank"    },   --对应的显示图片
            {id=2,  pic="ShadowWeapon"  },
            {id=3,  pic="ShadowArtillery"   },
            {id=4,  pic="ShadowRocket"  },
            },
             --兑换配置表
            r={
             --同种图标抽到3次奖励
            {id=1,  num=3,  reward={    o={{a10007=4,index=1}}}},    --id为1的道具抽到了3次
            {id=2,  num=3,  reward={    o={{a10017=4,index=1}}}},
            {id=3,  num=3,  reward={    o={{a10027=4,index=1}}}},
            {id=4,  num=3,  reward={    o={{a10037=4,index=1}}}},
             --同种图标抽到2次奖励
            {id=1,  num=2,  reward={    o={{a10006=3,index=1}}}},
            {id=2,  num=2,  reward={    o={{a10016=3,index=1}}}},
            {id=3,  num=2,  reward={    o={{a10026=3,index=1}}}},
            {id=4,  num=2,  reward={    o={{a10036=3,index=1}}}},
             --同种图标抽到1次奖励
            {id=1,  num=1,  reward={    o={{a10005=2,index=1}}}},
            {id=2,  num=1,  reward={    o={{a10015=2,index=1}}}},
            {id=3,  num=1,  reward={    o={{a10025=2,index=1}}}},
            {id=4,  num=1,  reward={    o={{a10035=2,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10005=2},
                    {troops_a10015=2},
                    {troops_a10025=2},
                    {troops_a10035=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10006=3},
                    {troops_a10016=3},
                    {troops_a10026=3},
                    {troops_a10036=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10007=4}, --id为1的道具抽到了3次
                    {troops_a10017=4},
                    {troops_a10027=4},
                    {troops_a10037=4},
                },
            },
        },
        --配置12结束

    --配置11开始
        [11] = {
            --坦克拉霸（567，普通版）
            type=1,
            sortId = 307,
            free=1,          --每天1次免费的机会
            cost=78,       --不免费时抽一次的金币花费
            mul=10,    --10倍模式
            mulc=9,    --10倍模式花费的金币是mulC*cost
             --只前端使用的配置（显示相关）
            my={
            {id=1,  pic="ShadowTank"    },   --对应的显示图片
            {id=2,  pic="ShadowWeapon"  },
            {id=3,  pic="ShadowArtillery"   },
            {id=4,  pic="ShadowRocket"  },
            },
             --兑换配置表
            r={
             --同种图标抽到3次奖励
            {id=1,  num=3,  reward={    o={{a10007=4,index=1}}}},    --id为1的道具抽到了3次
            {id=2,  num=3,  reward={    o={{a10017=4,index=1}}}},
            {id=3,  num=3,  reward={    o={{a10027=4,index=1}}}},
            {id=4,  num=3,  reward={    o={{a10037=4,index=1}}}},
             --同种图标抽到2次奖励
            {id=1,  num=2,  reward={    o={{a10006=3,index=1}}}},
            {id=2,  num=2,  reward={    o={{a10016=3,index=1}}}},
            {id=3,  num=2,  reward={    o={{a10026=3,index=1}}}},
            {id=4,  num=2,  reward={    o={{a10036=3,index=1}}}},
             --同种图标抽到1次奖励
            {id=1,  num=1,  reward={    o={{a10005=2,index=1}}}},
            {id=2,  num=1,  reward={    o={{a10015=2,index=1}}}},
            {id=3,  num=1,  reward={    o={{a10025=2,index=1}}}},
            {id=4,  num=1,  reward={    o={{a10035=2,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10005=2},
                    {troops_a10015=2},
                    {troops_a10025=2},
                    {troops_a10035=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10006=3},
                    {troops_a10016=3},
                    {troops_a10026=3},
                    {troops_a10036=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10007=4}, --id为1的道具抽到了3次
                    {troops_a10017=4},
                    {troops_a10027=4},
                    {troops_a10037=4},
                },
            },
        },
        --配置11结束

		
		 --坦克拉霸（5,6,6.5，普通版）					
		[10]={		
			type=1,			
			sortId = 307,			
			free=1,			 --每天1次免费的机会
			cost=	58	,	 --不免费时抽一次的金币花费
			mul=	10	,	 --10倍模式
			mulc=	9	,	 --10倍模式花费的金币是mulC*cost
			 --只前端使用的配置（显示相关）			
			my={			
			{id=1,	pic="ShadowTank"	},	 --对应的显示图片
			{id=2,	pic="ShadowWeapon"	},	
			{id=3,	pic="ShadowArtillery"	},	
			{id=4,	pic="ShadowRocket"	},	
			},			
			 --兑换配置表			
			r={			
			 --同种图标抽到3次奖励			
			{id=1,	num=3,	reward={	o={{a10074=3,index=1}}}},
			{id=2,	num=3,	reward={	o={{a10054=3,index=1}}}},
			{id=3,	num=3,	reward={	o={{a10044=3,index=1}}}},
			{id=4,	num=3,	reward={	o={{a10083=3,index=1}}}},
			 --同种图标抽到2次奖励			
			{id=1,	num=2,	reward={	o={{a10006=2,index=1}}}},
			{id=2,	num=2,	reward={	o={{a10016=2,index=1}}}},
			{id=3,	num=2,	reward={	o={{a10026=2,index=1}}}},
			{id=4,	num=2,	reward={	o={{a10036=2,index=1}}}},
			 --同种图标抽到1次奖励			
			{id=1,	num=1,	reward={	o={{a10073=1,index=1}}}},
			{id=2,	num=1,	reward={	o={{a10053=1,index=1}}}},
			{id=3,	num=1,	reward={	o={{a10043=1,index=1}}}},
			{id=4,	num=1,	reward={	o={{a10082=1,index=1}}}},
			},			
			serverreward={			
			 --同种图标抽到1次奖励			
			{			
			{troops_a10073=1},			
			{troops_a10053=1},			
			{troops_a10043=1},			
			{troops_a10082=1},			
			},			
			 --同种图标抽到2次奖励			
			{			
			{troops_a10006=2},			
			{troops_a10016=2},			
			{troops_a10026=2},			
			{troops_a10036=2},			
			},			
			 --同种图标抽到3次奖励			
			{			
			{troops_a10074=3},	 --id为1的道具抽到了3次		
			{troops_a10054=3},			
			{troops_a10044=3},			
			{troops_a10083=3},			
			},			
		},			
	},			
					

 --坦克拉霸（456级活动，普通版）
		[9]={
			type=1,
			sortId = 307,
			free=1, --每天1次免费的机会
			cost=38, --不免费时抽一次的金币花费
			mul=10, --10倍模式
			mulc=9, --10倍模式花费的金币是mulC*cost
			 --只前端使用的配置（显示相关）
			my={
			{id=1,pic="ShadowTank"}, --对应的显示图片
			{id=2,pic="ShadowWeapon"},
			{id=3,pic="ShadowArtillery"},
			{id=4,pic="ShadowRocket"},
			},
			 --兑换配置表
			r={
			 --同种图标抽到3次奖励
			{id=1,num=3,reward={o={{a10006=4,index=1}}}}, --id为1的道具抽到了3次
			{id=2,num=3,reward={o={{a10016=4,index=1}}}},
			{id=3,num=3,reward={o={{a10026=4,index=1}}}},
			{id=4,num=3,reward={o={{a10036=4,index=1}}}},
			 --同种图标抽到2次奖励
			{id=1,num=2,reward={o={{a10006=1,index=1},{a10005=1,index=1},}}},
			{id=2,num=2,reward={o={{a10016=1,index=1},{a10015=1,index=1},}}},
			{id=3,num=2,reward={o={{a10026=1,index=1},{a10025=1,index=1},}}},
			{id=4,num=2,reward={o={{a10036=1,index=1},{a10035=1,index=1},}}},
			 --同种图标抽到1次奖励
			{id=1,num=1,reward={o={{a10004=5,index=1}}}},
			{id=2,num=1,reward={o={{a10014=5,index=1}}}},
			{id=3,num=1,reward={o={{a10024=5,index=1}}}},
			{id=4,num=1,reward={o={{a10034=5,index=1}}}},
			},
			serverreward={
			 --同种图标抽到1次奖励
			{
				{troops_a10004=5},
				{troops_a10014=5},
				{troops_a10024=5},
				{troops_a10034=5},
			},
			 --同种图标抽到2次奖励
			{
				{troops_a10006=1,troops_a10005=1},
				{troops_a10016=1,troops_a10015=1},
				{troops_a10026=1,troops_a10025=1},
				{troops_a10036=1,troops_a10035=1},
			},
			 --同种图标抽到3次奖励
			{
				{troops_a10006=4}, --id为1的道具抽到了3次
				{troops_a10016=4},
				{troops_a10026=4},
				{troops_a10036=4},
			},
		},
	},

        --配置7开始
        [7] = {
            --坦克拉霸（456，普通版）
            type=1,
            sortId = 307,
            free=1,          --每天1次免费的机会    
            cost=38,       --不免费时抽一次的金币花费 
            mul=10,    --10倍模式    
            mulc=9,    --10倍模式花费的金币是mulC*cost 
             --只前端使用的配置（显示相关）               
            my={                
            {id=1,  pic="ShadowTank"    },   --对应的显示图片  
            {id=2,  pic="ShadowWeapon"  },      
            {id=3,  pic="ShadowArtillery"   },      
            {id=4,  pic="ShadowRocket"  },      
            },              
             --兑换配置表                
            r={             
             --同种图标抽到3次奖励               
            {id=1,  num=3,  reward={    o={{a10006=5,index=1}}}},    --id为1的道具抽到了3次
            {id=2,  num=3,  reward={    o={{a10016=5,index=1}}}},   
            {id=3,  num=3,  reward={    o={{a10026=5,index=1}}}},   
            {id=4,  num=3,  reward={    o={{a10036=5,index=1}}}},   
             --同种图标抽到2次奖励               
            {id=1,  num=2,  reward={    o={{a10005=3,index=1}}}},   
            {id=2,  num=2,  reward={    o={{a10015=3,index=1}}}},   
            {id=3,  num=2,  reward={    o={{a10025=3,index=1}}}},   
            {id=4,  num=2,  reward={    o={{a10035=3,index=1}}}},   
             --同种图标抽到1次奖励               
            {id=1,  num=1,  reward={    o={{a10004=2,index=1}}}},   
            {id=2,  num=1,  reward={    o={{a10014=2,index=1}}}},   
            {id=3,  num=1,  reward={    o={{a10024=2,index=1}}}},   
            {id=4,  num=1,  reward={    o={{a10034=2,index=1}}}},   
            },              
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10004=2},
                    {troops_a10014=2},
                    {troops_a10024=2},
                    {troops_a10034=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10005=3},
                    {troops_a10015=3},
                    {troops_a10025=3},
                    {troops_a10035=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10006=5}, --id为1的道具抽到了3次
                    {troops_a10016=5},
                    {troops_a10026=5},
                    {troops_a10036=5},
                },
            },    
        },              
        --配置7结束


        --配置8开始
        [8] = {
            --坦克拉霸（456，折扣版）
            type=1,
            sortId = 307,
            free=1,          --每天1次免费的机会    
            cost=28,      --不免费时抽一次的金币花费 
            mul=10,    --10倍模式    
            mulc=9,    --10倍模式花费的金币是mulC*cost 
             --只前端使用的配置（显示相关）               
            my={                
            {id=1,  pic="ShadowTank"    },   --对应的显示图片  
            {id=2,  pic="ShadowWeapon"  },      
            {id=3,  pic="ShadowArtillery"   },      
            {id=4,  pic="ShadowRocket"  },      
            },              
             --兑换配置表                
            r={             
             --同种图标抽到3次奖励               
            {id=1,  num=3,  reward={    o={{a10006=5,index=1}}}},    --id为1的道具抽到了3次
            {id=2,  num=3,  reward={    o={{a10016=5,index=1}}}},   
            {id=3,  num=3,  reward={    o={{a10026=5,index=1}}}},   
            {id=4,  num=3,  reward={    o={{a10036=5,index=1}}}},   
             --同种图标抽到2次奖励               
            {id=1,  num=2,  reward={    o={{a10005=3,index=1}}}},   
            {id=2,  num=2,  reward={    o={{a10015=3,index=1}}}},   
            {id=3,  num=2,  reward={    o={{a10025=3,index=1}}}},   
            {id=4,  num=2,  reward={    o={{a10035=3,index=1}}}},   
             --同种图标抽到1次奖励               
            {id=1,  num=1,  reward={    o={{a10004=2,index=1}}}},   
            {id=2,  num=1,  reward={    o={{a10014=2,index=1}}}},   
            {id=3,  num=1,  reward={    o={{a10024=2,index=1}}}},   
            {id=4,  num=1,  reward={    o={{a10034=2,index=1}}}},   
            },              
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10004=2},
                    {troops_a10014=2},
                    {troops_a10024=2},
                    {troops_a10034=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10005=3},
                    {troops_a10015=3},
                    {troops_a10025=3},
                    {troops_a10035=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10006=5}, --id为1的道具抽到了3次
                    {troops_a10016=5},
                    {troops_a10026=5},
                    {troops_a10036=5},
                },
            },       
        },              
        --配置8结束
        --配置1开始
        [6] = {
            type=1,
            sortId = 307,
            --坦克拉霸（45级活动，普通版）
            free=1, --每天1次免费的机会
            cost=38, --不免费时抽一次的金币花费
            version=8,
            mul=10, --10倍模式
            mulc=9, --10倍模式花费的金币是mulC*cost
            --只前端使用的配置（显示相关）
            my={
                {id=1,pic="ShadowTank"}, --对应的显示图片
                {id=2,pic="ShadowWeapon"},
                {id=3,pic="ShadowArtillery"},
                {id=4,pic="ShadowRocket"},
            },
            --兑换配置表
            r={
                --同种图标抽到3次奖励
                {id=1,num=3,reward={o={{a10073=5,index=1}}}}, --id为1的道具抽到了3次
                {id=2,num=3,reward={o={{a10053=5,index=1}}}},
                {id=3,num=3,reward={o={{a10043=5,index=1}}}},
                {id=4,num=3,reward={o={{a10082=5,index=1}}}},
                --同种图标抽到2次奖励
                {id=1,num=2,reward={o={{a10005=3,index=1}}}},
                {id=2,num=2,reward={o={{a10015=3,index=1}}}},
                {id=3,num=2,reward={o={{a10025=3,index=1}}}},
                {id=4,num=2,reward={o={{a10035=3,index=1}}}},
                --同种图标抽到1次奖励
                {id=1,num=1,reward={o={{a10004=2,index=1}}}},
                {id=2,num=1,reward={o={{a10014=2,index=1}}}},
                {id=3,num=1,reward={o={{a10024=2,index=1}}}},
                {id=4,num=1,reward={o={{a10034=2,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10004=2},
                    {troops_a10014=2},
                    {troops_a10024=2},
                    {troops_a10034=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10005=3},
                    {troops_a10015=3},
                    {troops_a10025=3},
                    {troops_a10035=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10073=5}, --id为1的道具抽到了3次
                    {troops_a10053=5},
                    {troops_a10043=5},
                    {troops_a10082=5},
                },
            },
        },
        --配置1结束
        --配置2开始
        [5] = {
            --坦克拉霸（123级，普通版）
            type=1,
            sortId = 307,
            free=1, --每天1次免费的机会
            cost=5, --不免费时抽一次的金币花费
            version=7,
            mul=10, --10倍模式
            mulc=9, --10倍模式花费的金币是mulC*cost
            --只前端使用的配置（显示相关）
            my={
                {id=1,pic="ShadowTank"}, --对应的显示图片
                {id=2,pic="ShadowWeapon"},
                {id=3,pic="ShadowArtillery"},
                {id=4,pic="ShadowRocket"},
            },
            --兑换配置表
            r={
                --同种图标抽到3次奖励
                {id=1,num=3,reward={o={{a10003=5,index=1}}}}, --id为1的道具抽到了3次
                {id=2,num=3,reward={o={{a10013=5,index=1}}}},
                {id=3,num=3,reward={o={{a10023=5,index=1}}}},
                {id=4,num=3,reward={o={{a10033=5,index=1}}}},
                --同种图标抽到2次奖励
                {id=1,num=2,reward={o={{a10002=3,index=1}}}},
                {id=2,num=2,reward={o={{a10012=3,index=1}}}},
                {id=3,num=2,reward={o={{a10022=3,index=1}}}},
                {id=4,num=2,reward={o={{a10032=3,index=1}}}},
                --同种图标抽到1次奖励
                {id=1,num=1,reward={o={{a10001=2,index=1}}}},
                {id=2,num=1,reward={o={{a10011=2,index=1}}}},
                {id=3,num=1,reward={o={{a10021=2,index=1}}}},
                {id=4,num=1,reward={o={{a10031=2,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10001=2},
                    {troops_a10011=2},
                    {troops_a10021=2},
                    {troops_a10031=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10002=3},
                    {troops_a10012=3},
                    {troops_a10022=3},
                    {troops_a10032=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10003=5}, --id为1的道具抽到了3次
                    {troops_a10013=5},
                    {troops_a10023=5},
                    {troops_a10033=5},
                },
            },
        },
        --配置2结束
        --配置3开始
        [4] = {
            --坦克拉霸（123级，折扣版）
            type=1,
            sortId = 307,
            free=1, --每天1次免费的机会
            cost=5, --不免费时抽一次的金币花费
            version=6,
            mul=10, --10倍模式
            mulc=9, --10倍模式花费的金币是mulC*cost
            --只前端使用的配置（显示相关）
            my={
                {id=1,pic="ShadowTank"}, --对应的显示图片
                {id=2,pic="ShadowWeapon"},
                {id=3,pic="ShadowArtillery"},
                {id=4,pic="ShadowRocket"},
            },
            --兑换配置表
            r={
                --同种图标抽到3次奖励
                {id=1,num=3,reward={o={{a10003=10,index=1}}}}, --id为1的道具抽到了3次
                {id=2,num=3,reward={o={{a10013=10,index=1}}}},
                {id=3,num=3,reward={o={{a10023=10,index=1}}}},
                {id=4,num=3,reward={o={{a10033=10,index=1}}}},
                --同种图标抽到2次奖励
                {id=1,num=2,reward={o={{a10002=6,index=1}}}},
                {id=2,num=2,reward={o={{a10012=6,index=1}}}},
                {id=3,num=2,reward={o={{a10022=6,index=1}}}},
                {id=4,num=2,reward={o={{a10032=6,index=1}}}},
                --同种图标抽到1次奖励
                {id=1,num=1,reward={o={{a10001=4,index=1}}}},
                {id=2,num=1,reward={o={{a10011=4,index=1}}}},
                {id=3,num=1,reward={o={{a10021=4,index=1}}}},
                {id=4,num=1,reward={o={{a10031=4,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10001=4},
                    {troops_a10011=4},
                    {troops_a10021=4},
                    {troops_a10031=4},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10002=6},
                    {troops_a10012=6},
                    {troops_a10022=6},
                    {troops_a10032=6},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10003=10}, --id为1的道具抽到了3次
                    {troops_a10013=10},
                    {troops_a10023=10},
                    {troops_a10033=10},
                },
            },
        },
        --配置3结束
        --配置4开始
        [3] = {
            -- --坦克拉霸（234级，普通版）
            type=1,
            sortId = 307,
            free=1, --每天1次免费的机会
            cost=12, --不免费时抽一次的金币花费
            version=5,
            mul=10, --10倍模式
            mulc=9, --10倍模式花费的金币是mulC*cost
            --只前端使用的配置（显示相关）
            my={
                {id=1,pic="ShadowTank"}, --对应的显示图片
                {id=2,pic="ShadowWeapon"},
                {id=3,pic="ShadowArtillery"},
                {id=4,pic="ShadowRocket"},
            },
            --兑换配置表
            r={
                --同种图标抽到3次奖励
                {id=1,num=3,reward={o={{a10004=5,index=1}}}}, --id为1的道具抽到了3次
                {id=2,num=3,reward={o={{a10014=5,index=1}}}},
                {id=3,num=3,reward={o={{a10024=5,index=1}}}},
                {id=4,num=3,reward={o={{a10034=5,index=1}}}},
                --同种图标抽到2次奖励
                {id=1,num=2,reward={o={{a10003=3,index=1}}}},
                {id=2,num=2,reward={o={{a10013=3,index=1}}}},
                {id=3,num=2,reward={o={{a10023=3,index=1}}}},
                {id=4,num=2,reward={o={{a10033=3,index=1}}}},
                --同种图标抽到1次奖励
                {id=1,num=1,reward={o={{a10002=2,index=1}}}},
                {id=2,num=1,reward={o={{a10012=2,index=1}}}},
                {id=3,num=1,reward={o={{a10022=2,index=1}}}},
                {id=4,num=1,reward={o={{a10032=2,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10002=2},
                    {troops_a10012=2},
                    {troops_a10022=2},
                    {troops_a10032=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10003=3},
                    {troops_a10013=3},
                    {troops_a10023=3},
                    {troops_a10033=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10004=5}, --id为1的道具抽到了3次
                    {troops_a10014=5},
                    {troops_a10024=5},
                    {troops_a10034=5},
                },
            },
        },
        --配置4结束
        --配置5开始
        [2] = {
            --坦克拉霸（234级，折扣版）
            type=1,
            sortId = 307,
            free=1, --每天1次免费的机会
            cost=12, --不免费时抽一次的金币花费
            version=4,
            mul=10, --10倍模式
            mulc=9, --10倍模式花费的金币是mulC*cost
            --只前端使用的配置（显示相关）
            my={
                {id=1,pic="ShadowTank"}, --对应的显示图片
                {id=2,pic="ShadowWeapon"},
                {id=3,pic="ShadowArtillery"},
                {id=4,pic="ShadowRocket"},
            },
            --兑换配置表
            r={
                --同种图标抽到3次奖励
                {id=1,num=3,reward={o={{a10004=10,index=1}}}}, --id为1的道具抽到了3次
                {id=2,num=3,reward={o={{a10014=10,index=1}}}},
                {id=3,num=3,reward={o={{a10024=10,index=1}}}},
                {id=4,num=3,reward={o={{a10034=10,index=1}}}},
                --同种图标抽到2次奖励
                {id=1,num=2,reward={o={{a10003=6,index=1}}}},
                {id=2,num=2,reward={o={{a10013=6,index=1}}}},
                {id=3,num=2,reward={o={{a10023=6,index=1}}}},
                {id=4,num=2,reward={o={{a10033=6,index=1}}}},
                --同种图标抽到1次奖励
                {id=1,num=1,reward={o={{a10002=4,index=1}}}},
                {id=2,num=1,reward={o={{a10012=4,index=1}}}},
                {id=3,num=1,reward={o={{a10022=4,index=1}}}},
                {id=4,num=1,reward={o={{a10032=4,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10002=4},
                    {troops_a10012=4},
                    {troops_a10022=4},
                    {troops_a10032=4},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10003=6},
                    {troops_a10013=6},
                    {troops_a10023=6},
                    {troops_a10033=6},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10004=10}, --id为1的道具抽到了3次
                    {troops_a10014=10},
                    {troops_a10024=10},
                    {troops_a10034=10},
                },
            },
        },
        --配置5结束
        --配置6开始
        [1] = {
            --坦克拉霸（345级，普通版）
            type=1,
            sortId = 307,
            free=1, --每天1次免费的机会
            cost=28, --不免费时抽一次的金币花费
            mul=10, --10倍模式
            version=3,
            mulc=9, --10倍模式花费的金币是mulC*cost
            --只前端使用的配置（显示相关）
            my={
                {id=1,pic="ShadowTank"}, --对应的显示图片
                {id=2,pic="ShadowWeapon"},
                {id=3,pic="ShadowArtillery"},
                {id=4,pic="ShadowRocket"},
            },
            --兑换配置表
            r={
                --同种图标抽到3次奖励
                {id=1,num=3,reward={o={{a10005=5,index=1}}}}, --id为1的道具抽到了3次
                {id=2,num=3,reward={o={{a10015=5,index=1}}}},
                {id=3,num=3,reward={o={{a10025=5,index=1}}}},
                {id=4,num=3,reward={o={{a10035=5,index=1}}}},
                --同种图标抽到2次奖励
                {id=1,num=2,reward={o={{a10004=3,index=1}}}},
                {id=2,num=2,reward={o={{a10014=3,index=1}}}},
                {id=3,num=2,reward={o={{a10024=3,index=1}}}},
                {id=4,num=2,reward={o={{a10034=3,index=1}}}},
                --同种图标抽到1次奖励
                {id=1,num=1,reward={o={{a10003=2,index=1}}}},
                {id=2,num=1,reward={o={{a10013=2,index=1}}}},
                {id=3,num=1,reward={o={{a10023=2,index=1}}}},
                {id=4,num=1,reward={o={{a10033=2,index=1}}}},
            },
            serverreward={
                --同种图标抽到1次奖励
                {
                    {troops_a10003=2},
                    {troops_a10013=2},
                    {troops_a10023=2},
                    {troops_a10033=2},
                },
                --同种图标抽到2次奖励
                {
                    {troops_a10004=3},
                    {troops_a10014=3},
                    {troops_a10024=3},
                    {troops_a10034=3},
                },
                --同种图标抽到3次奖励
                {
                    {troops_a10005=5}, --id为1的道具抽到了3次
                    {troops_a10015=5},
                    {troops_a10025=5},
                    {troops_a10035=5},
                },
            },
        },
        --配置6结束
    },
		

    --资金招募
    fundsRecruit={
        type=1,
        sortId=157,
        reward={
            {{point=10},3600}, -- 在线 60 分钟
            {{point=20},10}, -- 军团捐献 10次
            {{point=50},5},  -- 金币捐献  5次
        },
    },

	 --坚守阵地
	holdGround={
		multiSelectType = true,
		[1] = {
		type=1,
		sortId=147,
		serverreward={
		{props_p47=1,props_p37=1,},
		{props_p47=2,props_p38=1,},
		{props_p47=3,props_p39=1,},
		{props_p2=1,props_p40=1,},
		{props_p20=5,props_p41=1,},
		{props_p5=1,props_p19=10,},
		{props_p3=1,userinfo_gems=100,},
		},
		reward={      
		awardCfg={      
		{p={{p47=1,index=1},{p37=1,index=2}}},
		{p={{p47=2,index=1},{p38=1,index=2}}},
		{p={{p47=3,index=1},{p39=1,index=2}}},
		{p={{p2=1,index=1},{p40=1,index=2}}},
		{p={{p20=5,index=1},{p41=1,index=2}}},
		{p={{p5=1,index=1},{p19=10,index=2}}},
		{p={{p3=1,index=1}},u={{gems=100,index=2}}},
		},
		flick={
		p={p2=1,p20=5,p5=1,p3=1,},u={gems=100,},
		},
		},      
		},      
	},
    --秘宝探寻
        miBao = {
            type=1,
            sortId=167,
            pid="p406", --拼合后得到的道具
            pc={s1=2,s2=2,s3=1,s4=1}, --拼合道具需要的各种碎片的数量
        br={"p269","p267"}, --公告
            serverreward = {
                pool={   --物品掉落概率
                    {100},
                    {8,8,10,10,25,25,14,},
                    {{"s1",2},{"s1",3},{"s2",1},{"s2",2},{"s3",1},{"s4",1},{"props_p405",1},}
                },
                level={  --是否掉落物品
                    {50,80},
                    {48,77},
                    {46,74},
                    {44,71},
                    {42,68},
                    {40,65},
                    {38,62},
                    {36,59},
                    {34,56},
                    {32,53},
                    {30,50},
                    {28,47},
                    {26,44},
                    {24,41},
                    {22,38},
                    {20,35},
                    {18,32},
                    {16,29},
                    {14,26},
                    {12,23},
                    {10,20},
                    {8,17},
                    {6,14},
                    {4,11},
                    {2,8}, --资源点等级,掉落概率
                },
			}
        },


        --连续充值配置
        continueRecharge={
            multiSelectType=true,
            [1] ={
				type=1,
				sortId=177,	
				version=1,		
				dC=150, --每日充值的满足条件的最小值
				rR=500, --黑客修改记录需要的金币数
				bR={p408=1}, --奖励
				bRV=5000 --奖品价值
			},
			
			[2]={	 --7,8配件		
				type=1,			
				sortId=177,			
				version=2,			
				dC=	160,		 --每日充值的满足条件的最小值
				rR=	1000,		 --黑客修改记录需要的金币数
				bR={	p925=1	},	 --奖励
				bRV=	5000		 --奖品价值
			},				

        },
         --满载而归活动配置
        rewardingBack={
            type=1,
            sortId=187,
            reward={u={{gems=0.1,index=1},{gold=2000,index=2}}}, --gems,gold=倍率
            serverreward={userinfo_gems=0.1,userinfo_gold=2000}
        },

        --冲级三重奏
        leveling={
            multiSelectType=true,
            [1] ={
                type=1,
                sortId=197,
                desVate=0.5, --消耗的资源减少一半
                con = {60,70},
                reward={ --前台奖励
                    l60={type = {"r1", "r2","r3","r4","gold"},num = 100000000},
                    l70={type = {"gems"}, num =1000},
                },
                serverreward={ --后台奖励
                    l60={userinfo_r1=100000000,userinfo_r2=100000000,userinfo_r3=100000000,userinfo_r4=100000000,userinfo_gold=100000000,},
                    l70={userinfo_gems=1000,},
                },
            },

        },
        --军备换代
        armamentsUpdate1 = {
            type=1,
            sortId=207,
            serverreward={
                ascVate={   --增加奖励的倍率
                    props_p393=2,
                    props_p394=2,
                },
                upgrade={
                    troops_a10006=2, --增加的倍率
                    troops_a10016=2,
                },
            }
        },
        armamentsUpdate2 = {
            type=1,
            sortId=217,
            serverreward={
                ascVate={   --增加奖励的倍率
                    props_p395=2,
                    props_p396=2,
                },
                upgrade={
                    troops_a10026=2, --增加的倍率
                    troops_a10036=2,
                },
            }
        },

        --冲级三重奏2
        leveling2={
            multiSelectType=true,
            [1] = {
                type=1,
                sortId=247,
                desVate=0.5, --消耗的资源减少一半
                lvLim={1,60},
                con = {60,70},
                reward={ --前台奖励
                    l60={type = {"r1", "r2","r3","r4","gold"},num = 100000000},
                    l70={type = {"gems"}, num =1000},
                },
                serverreward={ --后台奖励
                    l60={userinfo_r1=100000000,userinfo_r2=100000000,userinfo_r3=100000000,userinfo_r4=100000000,userinfo_gold=100000000,},
                    l70={userinfo_gems=1000,},
                }
            },
            [2] = {
                type=1,
                sortId=247,
                desVate=0.5,     --消耗的资源减少一半
                lvLim={1,70},
                con={70,80},
                reward={ --前台奖励
                    l70={type = {"r1", "r2","r3","r4","gold"},num = 200000000},
                    l80={type = {"gems"}, num =2000},
                },
                serverreward={--后台奖励
                    l70={   userinfo_r1=200000000,  userinfo_r2=200000000,  userinfo_r3=200000000,  userinfo_r4=200000000,  userinfo_gold=200000000,    },
                    l80={   userinfo_gems=2000,                 },
                }
            },
        },
        --坚守阵地
        holdGround1={
            type=1,
            sortId=227,
            serverreward={
                {userinfo_r1=80000,userinfo_r2=80000,userinfo_r3=80000,userinfo_gold=40000,},
                {userinfo_r1=90000,userinfo_r2=90000,userinfo_r3=90000,userinfo_gold=45000,},
                {userinfo_r1=100000,userinfo_r2=100000,userinfo_r3=100000,userinfo_gold=50000,},
                {userinfo_r1=110000,userinfo_r2=110000,userinfo_r3=110000,userinfo_gold=55000,},
                {userinfo_r1=120000,userinfo_r2=120000,userinfo_r3=120000,userinfo_gold=60000,},
                {userinfo_r1=130000,userinfo_r2=130000,userinfo_r3=130000,userinfo_gold=65000,},
                {userinfo_r1=150000,userinfo_r2=150000,userinfo_r3=150000,userinfo_gold=75000,},
            },
            reward={
                awardCfg={
                    {u={{r1=80000,index=1},{r2=80000,index=2},{r3=80000,index=3},{gold=40000,index=4}}},
                    {u={{r1=90000,index=1},{r2=90000,index=2},{r3=90000,index=3},{gold=45000,index=4}}},
                    {u={{r1=100000,index=1},{r2=100000,index=2},{r3=100000,index=3},{gold=50000,index=4}}},
                    {u={{r1=110000,index=1},{r2=110000,index=2},{r3=110000,index=3},{gold=55000,index=4}}},
                    {u={{r1=120000,index=1},{r2=120000,index=2},{r3=120000,index=3},{gold=60000,index=4}}},
                    {u={{r1=130000,index=1},{r2=130000,index=2},{r3=130000,index=3},{gold=65000,index=4}}},
                    {u={{r1=150000,index=1},{r2=150000,index=2},{r3=150000,index=3},{gold=75000,index=4}}},
                },
                flick={
                },
            },
        },
        --改造计划

refitPlanT99 = {	--国王级战列舰																									
            multiSelectType=true,																										
[1]={																										
version=1,																										
free=1,	 --每天1次免费的机会																									
cost=45,	 --不免费时抽一次的金币花费																									
mul=10,	 --10连抽																									
mulc=9,	--10倍模式花费的金币是mulC*cost																									
reward={	o={	{a10124=3,index=1},	{a10124=2,index=2},	{a10124=1,index=3},	{a10123=3,index=4},	{a10123=2,index=5},	{a10123=1,index=6},	},p={	{p837=2,index=7},	{p837=1,index=8},	{p19=2,index=9},	{p19=1,index=10},	{p902=2,index=11},	{p902=1,index=12},	},},											
vate=1,	 --初始倍率为1																									
maxVate=6,	 --最高倍率为6																									
consume = {																										
a10124={	 --目标坦克,以下为改装需要的道具，参考tank的conf																									
upgradeMetalConsume=	1880000,																									
upgradeOilConsume=	1880000,						            																			
upgradeSiliconConsume=	1880000,						            																			
upgradeUraniumConsume=	1180000,																									
upgradeMoneyConsume=	0,						            																			
upgradeShipConsume=	{'a10123',1},						            																			
upgradePropConsume = {	{"p19",1},	{"p837",1},	},				            																			
},																										
},																										
serverreward={																										
bigRate=2,	 --抽到大奖的概率值																									
addVate=3,	 --未抽到大奖每次累加的概率																									
maxVate=15,	 --提升到的最大倍率																									
 --大奖抽奖池																										
bigPool={{100},{	1,	3,	9,	2,	4,	11,	7,	19,	7,	18,	6,	13,	},{	{"troops_a10124",30},	{"troops_a10124",20},	{"troops_a10124",10},	{"troops_a10123",30},	{"troops_a10123",20},	{"troops_a10123",10},	{"props_p837",20},	{"props_p837",10},	{"props_p19",20},	{"props_p19",10},	{"props_p902",20},	{"props_p902",10},	}},
 --小奖抽奖池																										
smallPool={{100},{	1,	3,	9,	2,	4,	11,	7,	19,	7,	18,	6,	13,	},{	{"troops_a10124",3},	{"troops_a10124",2},	{"troops_a10124",1},	{"troops_a10123",3},	{"troops_a10123",2},	{"troops_a10123",1},	{"props_p837",2},	{"props_p837",1},	{"props_p19",2},	{"props_p19",1},	{"props_p902",2},	{"props_p902",1},	}},
},																										
},																										
																										
																										
[2]={	--甘古特级战列舰																									
version=2,																										
free=1,	 --每天1次免费的机会																									
cost=45,	 --不免费时抽一次的金币花费																									
mul=10,	 --10连抽																									
mulc=9,	--10倍模式花费的金币是mulC*cost																									
reward={	o={	{a10094=3,index=1},	{a10094=2,index=2},	{a10094=1,index=3},	{a10093=3,index=4},	{a10093=2,index=5},	{a10093=1,index=6},	},p={	{p835=2,index=7},	{p835=1,index=8},	{p19=2,index=9},	{p19=1,index=10},	{p902=2,index=11},	{p902=1,index=12},	},},											
vate=1,	 --初始倍率为1																									
maxVate=6,	 --最高倍率为6																									
consume = {																										
a10094={	 --目标坦克,以下为改装需要的道具，参考tank的conf																									
upgradeMetalConsume=	1880000,																									
upgradeOilConsume=	1880000,						            																			
upgradeSiliconConsume=	1880000,						            																			
upgradeUraniumConsume=	1180000,																									
upgradeMoneyConsume=	0,						            																			
upgradeShipConsume=	{'a10093',1},						            																			
upgradePropConsume = {	{"p19",1},	{"p835",1},	},				            																			
},																										
},																										
serverreward={																										
bigRate=2,	 --抽到大奖的概率值																									
addVate=3,	 --未抽到大奖每次累加的概率																									
maxVate=15,	 --提升到的最大倍率																									
 --大奖抽奖池																										
bigPool={{100},{	1,	3,	9,	2,	4,	11,	7,	19,	7,	18,	6,	13,	},{	{"troops_a10094",30},	{"troops_a10094",20},	{"troops_a10094",10},	{"troops_a10093",30},	{"troops_a10093",20},	{"troops_a10093",10},	{"props_p835",20},	{"props_p835",10},	{"props_p19",20},	{"props_p19",10},	{"props_p902",20},	{"props_p902",10},	}},
 --小奖抽奖池																										
smallPool={{100},{	1,	3,	9,	2,	4,	11,	7,	19,	7,	18,	6,	13,	},{	{"troops_a10094",3},	{"troops_a10094",2},	{"troops_a10094",1},	{"troops_a10093",3},	{"troops_a10093",2},	{"troops_a10093",1},	{"props_p835",2},	{"props_p835",1},	{"props_p19",2},	{"props_p19",1},	{"props_p902",2},	{"props_p902",1},	}},
},																										
},																										
																										
																										
[3]={	--提尔皮茨级战列舰																									
version=3,																										
free=1,	 --每天1次免费的机会																									
cost=45,	 --不免费时抽一次的金币花费																									
mul=10,	 --10连抽																									
mulc=9,	--10倍模式花费的金币是mulC*cost																									
reward={	o={	{a10074=3,index=1},	{a10074=2,index=2},	{a10074=1,index=3},	{a10073=3,index=4},	{a10073=2,index=5},	{a10073=1,index=6},	},p={	{p413=2,index=7},	{p413=1,index=8},	{p19=2,index=9},	{p19=1,index=10},	{p902=2,index=11},	{p902=1,index=12},	},},											
vate=1,	 --初始倍率为1																									
maxVate=6,	 --最高倍率为6																									
consume = {																										
a10074={	 --目标坦克,以下为改装需要的道具，参考tank的conf																									
upgradeMetalConsume=	1880000,																									
upgradeOilConsume=	1880000,						            																			
upgradeSiliconConsume=	1880000,						            																			
upgradeUraniumConsume=	1180000,																									
upgradeMoneyConsume=	0,						            																			
upgradeShipConsume=	{'a10073',1},						            																			
upgradePropConsume = {	{"p19",1},	{"p413",1},	},				            																			
},																										
},																										
serverreward={																										
bigRate=2,	 --抽到大奖的概率值																									
addVate=3,	 --未抽到大奖每次累加的概率																									
maxVate=15,	 --提升到的最大倍率																									
 --大奖抽奖池																										
bigPool={{100},{	1,	3,	9,	2,	4,	11,	7,	19,	7,	18,	6,	13,	},{	{"troops_a10074",30},	{"troops_a10074",20},	{"troops_a10074",10},	{"troops_a10073",30},	{"troops_a10073",20},	{"troops_a10073",10},	{"props_p413",20},	{"props_p413",10},	{"props_p19",20},	{"props_p19",10},	{"props_p902",20},	{"props_p902",10},	}},
 --小奖抽奖池																										
smallPool={{100},{	1,	3,	9,	2,	4,	11,	7,	19,	7,	18,	6,	13,	},{	{"troops_a10074",3},	{"troops_a10074",2},	{"troops_a10074",1},	{"troops_a10073",3},	{"troops_a10073",2},	{"troops_a10073",1},	{"props_p413",2},	{"props_p413",1},	{"props_p19",2},	{"props_p19",1},	{"props_p902",2},	{"props_p902",1},	}},
},																										
},																										
},																										

																										
																					

        --充值送话费活动
        calls = {
            type = 1,
            sortId = 257,
            money = {5,10,30},
            vip = {1,3,5},
            day = 7,
        },
--中秋狂欢
autumnCarnival={
    multiSelectType = true,
    [1] ={
            type=1,
            --公告道具
            br={},
            --主要6大箱子掉落
                serverreward={
                    pool={
                        {100},
                        {1,2,2,3,1,1},
                        {{"b1",1},{"b2",1},{"b3",1},{"b4",1},{"b5",1},{"b6",1}},
                    },
                    --6大箱子自己的掉落
                    b1={
                        {100},
                        {17,17,17,17,17,3,3,3,3,3},
                        {{"props_p6",1},{"props_p7",1},{"props_p8",1},{"props_p9",1},{"props_p10",1},{"props_p37",1},{"props_p38",1},{"props_p39",1},{"props_p40",1},{"props_p41",1}},
                    },
                    b2={
                        {100},
                        {16,16,16,16,16,4,4,4,4,4},
                        {{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",3},{"props_p25",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1}},
                    },
                    b3={
                        {100},
                        {30,20,10,20,20},
                        {{"props_p19",1},{"props_p272",1},{"props_p20",1},{"userinfo_honors",10},{"userinfo_honors",100}},
                    },
                    b4={
                        {100},
                        {14,14,14,14,11,11,11,11},
                        {{"troops_a10002",10},{"troops_a10012",10},{"troops_a10022",10},{"troops_a10032",10},{"troops_a10003",5},{"troops_a10013",5},{"troops_a10023",1},{"troops_a10033",1}},
                    },
                    b5={
                        {100},
                        {10,10,10,20,10,20,15,5},
                        {{"props_p88",1},{"props_p266",1},{"props_p267",1},{"props_p281",1},{"accessory_p1",1},{"accessory_p3",1},{"accessory_p2",1},{"props_p89",1}},
                    },
                    b6={
                        {100},
                        {30,15,15,10,30},
                        {{"props_p15",1},{"props_p12",1},{"props_p11",1},{"props_p14",1},{"props_p13",1}},
                    },
                    --等级掉落物品概率 {资源点等级,掉落概率}
                    level={
                        {240,50},{239,49},{238,49},{237,49},{236,49},{235,49},{234,49},{233,49},{232,49},{231,48},{230,48},{229,48},{228,48},{227,48},{226,48},{225,48},{224,48},{223,47},{222,47},{221,47},{220,47},{219,47},{218,47},{217,47},{216,47},{215,46},{214,46},{213,46},{212,46},{211,46},{210,46},{209,46},{208,46},{207,45},{206,45},{205,45},{204,45},{203,45},{202,45},{201,45},{200,45},{199,44},{198,44},{197,44},{196,44},{195,44},{194,44},{193,44},{192,44},{191,43},{190,43},{189,43},{188,43},{187,43},{186,43},{185,43},{184,43},{183,42},{182,42},{181,42},{180,42},{179,42},{178,42},{177,42},{176,42},{175,41},{174,41},{173,41},{172,41},{171,41},{170,41},{169,41},{168,41},{167,40},{166,40},{165,40},{164,40},{163,40},{162,40},{161,40},{160,40},{159,39},{158,39},{157,39},{156,39},{155,39},{154,39},{153,39},{152,39},{151,38},{150,38},{149,38},{148,38},{147,38},{146,38},{145,38},{144,38},{143,37},{142,37},{141,37},{140,37},{139,37},{138,37},{137,37},{136,37},{135,36},{134,36},{133,36},{132,36},{131,36},{130,36},{129,36},{128,36},{127,35},{126,35},{125,35},{124,35},{123,35},{122,35},{121,35},{120,35},{119,34},{118,34},{117,34},{116,34},{115,34},{114,34},{113,34},{112,34},{111,33},{110,33},{109,33},{108,33},{107,33},{106,33},{105,33},{104,33},{103,32},{102,32},{101,32},{100,32},{99,32},{98,32},{97,32},{96,32},{95,31},{94,31},{93,31},{92,31},{91,31},{90,31},{89,31},{88,31},{87,30},{86,30},{85,30},{84,30},{83,30},{82,30},{81,30},{80,30},{79,29},{78,29},{77,29},{76,29},{75,29},{74,29},{73,29},{72,29},{71,28},{70,28},{69,28},{68,28},{67,28},{66,28},{65,28},{64,28},{63,27},{62,27},{61,27},{60,27},{59,27},{58,27},{57,27},{56,27},{55,26},{54,26},{53,26},{52,26},{51,26},{50,26},{49,26},{48,26},{47,25},{46,25},{45,25},{44,25},{43,25},{42,25},{41,25},{40,25},{39,24},{38,24},{37,24},{36,24},{35,24},{34,24},{33,24},{32,24},{31,23},{30,23},{29,23},{28,23},{27,23},{26,23},{25,23},{24,23},{23,22},{22,22},{21,22},{20,22},{19,22},{18,22},{17,22},{16,22},{15,21},{14,21},{13,21},{12,21},{11,21},{10,21},{9,21},{8,21},{7,20},{6,20},{5,20},{4,20},{3,20},{2,20},{1,20},
                    },
                },
            },
    [2] ={
            type=1,
            --公告道具
            br={},
            --主要6大箱子掉落
                serverreward={
                    pool={
                        {100},
                        {1,2,2,3,1,1},
                        {{"b1",1},{"b2",1},{"b3",1},{"b4",1},{"b5",1},{"b6",1}},
                    },
                    --6大箱子自己的掉落
                    b1={
                        {100},
                        {17,17,17,17,17,3,3,3,3,3},
                        {{"props_p6",1},{"props_p7",1},{"props_p8",1},{"props_p9",1},{"props_p10",1},{"props_p37",1},{"props_p38",1},{"props_p39",1},{"props_p39",1},{"props_p41",1}},
                    },
                    b2={
                        {100},
                        {16,16,16,16,16,4,4,4,4,4},
                        {{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",3},{"props_p30",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1}},
                    },
                    b3={
                        {100},
                        {30,20,10,20,20},
                        {{"props_p19",1},{"props_p272",1},{"props_p20",1},{"userinfo_honors",10},{"userinfo_honors",100}},
                    },
                    b4={
                        {100},
                        {8,8,12,12,12,12,9,9,9,9},
                        {{"troops_a10022",10},{"troops_a10032",10},{"troops_a10003",5},{"troops_a10013",5},{"troops_a10023",5},{"troops_a10033",5},{"troops_a10004",2},{"troops_a10014",2},{"troops_a10024",2},{"troops_a10034",2}},
                    },
                    b5={
                        {100},
                        {10,10,20,10,20,15,5},
                        {{"props_p266",1},{"props_p267",1},{"props_p282",1},{"props_p275",1},{"props_p277",10},{"props_p276",2},{"props_p89",1}},
                    },
                    b6={
                        {100},
                        {15,15,15,10,30,5,5,5},
                        {{"props_p15",1},{"props_p11",1},{"props_p12",1},{"props_p14",1},{"props_p13",1},{"props_p3402",1},{"props_p3407",1},{"props_p3412",1}},
                    },
                    --等级掉落物品概率 {资源点等级,掉落概率}
                    level={
                        {240,50},{239,49},{238,49},{237,49},{236,49},{235,49},{234,49},{233,49},{232,49},{231,48},{230,48},{229,48},{228,48},{227,48},{226,48},{225,48},{224,48},{223,47},{222,47},{221,47},{220,47},{219,47},{218,47},{217,47},{216,47},{215,46},{214,46},{213,46},{212,46},{211,46},{210,46},{209,46},{208,46},{207,45},{206,45},{205,45},{204,45},{203,45},{202,45},{201,45},{200,45},{199,44},{198,44},{197,44},{196,44},{195,44},{194,44},{193,44},{192,44},{191,43},{190,43},{189,43},{188,43},{187,43},{186,43},{185,43},{184,43},{183,42},{182,42},{181,42},{180,42},{179,42},{178,42},{177,42},{176,42},{175,41},{174,41},{173,41},{172,41},{171,41},{170,41},{169,41},{168,41},{167,40},{166,40},{165,40},{164,40},{163,40},{162,40},{161,40},{160,40},{159,39},{158,39},{157,39},{156,39},{155,39},{154,39},{153,39},{152,39},{151,38},{150,38},{149,38},{148,38},{147,38},{146,38},{145,38},{144,38},{143,37},{142,37},{141,37},{140,37},{139,37},{138,37},{137,37},{136,37},{135,36},{134,36},{133,36},{132,36},{131,36},{130,36},{129,36},{128,36},{127,35},{126,35},{125,35},{124,35},{123,35},{122,35},{121,35},{120,35},{119,34},{118,34},{117,34},{116,34},{115,34},{114,34},{113,34},{112,34},{111,33},{110,33},{109,33},{108,33},{107,33},{106,33},{105,33},{104,33},{103,32},{102,32},{101,32},{100,32},{99,32},{98,32},{97,32},{96,32},{95,31},{94,31},{93,31},{92,31},{91,31},{90,31},{89,31},{88,31},{87,30},{86,30},{85,30},{84,30},{83,30},{82,30},{81,30},{80,30},{79,29},{78,29},{77,29},{76,29},{75,29},{74,29},{73,29},{72,29},{71,28},{70,28},{69,28},{68,28},{67,28},{66,28},{65,28},{64,28},{63,27},{62,27},{61,27},{60,27},{59,27},{58,27},{57,27},{56,27},{55,26},{54,26},{53,26},{52,26},{51,26},{50,26},{49,26},{48,26},{47,25},{46,25},{45,25},{44,25},{43,25},{42,25},{41,25},{40,25},{39,24},{38,24},{37,24},{36,24},{35,24},{34,24},{33,24},{32,24},{31,23},{30,23},{29,23},{28,23},{27,23},{26,23},{25,23},{24,23},{23,22},{22,22},{21,22},{20,22},{19,22},{18,22},{17,22},{16,22},{15,21},{14,21},{13,21},{12,21},{11,21},{10,21},{9,21},{8,21},{7,20},{6,20},{5,20},{4,20},{3,20},{2,20},{1,20},
                    },
                },
            },
    [3] ={
            type=1,
            --公告道具
            br={},
            --主要6大箱子掉落
                serverreward={
                    pool={
                        {100},
                        {1,2,2,3,1,1},
                        {{"b1",1},{"b2",1},{"b3",1},{"b4",1},{"b5",1},{"b6",1}},
                    },
                    --6大箱子自己的掉落
                    b1={
                        {100},
                        {10,10,10,10,10,3},
                        {{"props_p37",1},{"props_p38",1},{"props_p39",1},{"props_p39",1},{"props_p41",1},{"props_p5",1}},
                    },
                    b2={
                        {100},
                        {20,20,20,20,20},
                        {{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",3},{"props_p36",1}},
                    },
                    b3={
                        {100},
                        {30,20,10,20,20},
                        {{"props_p19",1},{"props_p272",1},{"props_p20",1},{"userinfo_honors",10},{"userinfo_honors",100}},
                    },
                    b4={
                        {100},
                        {10,10,10,10,50,50,50,50},
                        {{"troops_a10006",1},{"troops_a10016",1},{"troops_a10026",1},{"troops_a10036",1},{"troops_a10004",3},{"troops_a10014",3},{"troops_a10024",3},{"troops_a10034",3}},
                    },
                    b5={
                        {100},
                        {1,10,20,10,20,15,2},
                        {{"props_p813",1},{"props_p267",1},{"props_p282",1},{"props_p275",1},{"props_p277",10},{"props_p276",2},{"props_p815",1}},
                    },
                    b6={
                        {100},
                        {16,15,15,10,30,5,3,3,3},
                        {{"props_p15",1},{"props_p11",1},{"props_p12",1},{"props_p14",1},{"props_p13",1},{"props_p16",1},{"props_p3403",1},{"props_p3408",1},{"props_p3413",1}},
                    },
                    --等级掉落物品概率 {资源点等级,掉落概率}
                    level={
                        {240,50},{239,49},{238,49},{237,49},{236,49},{235,49},{234,49},{233,49},{232,49},{231,48},{230,48},{229,48},{228,48},{227,48},{226,48},{225,48},{224,48},{223,47},{222,47},{221,47},{220,47},{219,47},{218,47},{217,47},{216,47},{215,46},{214,46},{213,46},{212,46},{211,46},{210,46},{209,46},{208,46},{207,45},{206,45},{205,45},{204,45},{203,45},{202,45},{201,45},{200,45},{199,44},{198,44},{197,44},{196,44},{195,44},{194,44},{193,44},{192,44},{191,43},{190,43},{189,43},{188,43},{187,43},{186,43},{185,43},{184,43},{183,42},{182,42},{181,42},{180,42},{179,42},{178,42},{177,42},{176,42},{175,41},{174,41},{173,41},{172,41},{171,41},{170,41},{169,41},{168,41},{167,40},{166,40},{165,40},{164,40},{163,40},{162,40},{161,40},{160,40},{159,39},{158,39},{157,39},{156,39},{155,39},{154,39},{153,39},{152,39},{151,38},{150,38},{149,38},{148,38},{147,38},{146,38},{145,38},{144,38},{143,37},{142,37},{141,37},{140,37},{139,37},{138,37},{137,37},{136,37},{135,36},{134,36},{133,36},{132,36},{131,36},{130,36},{129,36},{128,36},{127,35},{126,35},{125,35},{124,35},{123,35},{122,35},{121,35},{120,35},{119,34},{118,34},{117,34},{116,34},{115,34},{114,34},{113,34},{112,34},{111,33},{110,33},{109,33},{108,33},{107,33},{106,33},{105,33},{104,33},{103,32},{102,32},{101,32},{100,32},{99,32},{98,32},{97,32},{96,32},{95,31},{94,31},{93,31},{92,31},{91,31},{90,31},{89,31},{88,31},{87,30},{86,30},{85,30},{84,30},{83,30},{82,30},{81,30},{80,30},{79,29},{78,29},{77,29},{76,29},{75,29},{74,29},{73,29},{72,29},{71,28},{70,28},{69,28},{68,28},{67,28},{66,28},{65,28},{64,28},{63,27},{62,27},{61,27},{60,27},{59,27},{58,27},{57,27},{56,27},{55,26},{54,26},{53,26},{52,26},{51,26},{50,26},{49,26},{48,26},{47,25},{46,25},{45,25},{44,25},{43,25},{42,25},{41,25},{40,25},{39,24},{38,24},{37,24},{36,24},{35,24},{34,24},{33,24},{32,24},{31,23},{30,23},{29,23},{28,23},{27,23},{26,23},{25,23},{24,23},{23,22},{22,22},{21,22},{20,22},{19,22},{18,22},{17,22},{16,22},{15,21},{14,21},{13,21},{12,21},{11,21},{10,21},{9,21},{8,21},{7,20},{6,20},{5,20},{4,20},{3,20},{2,20},{1,20},
                    },
                },
            },
        },

        --大战前夕
        totalRecharge2={
            multiSelectType = true,
            ----------配置1开始-----------
            [1]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p502=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p502=1,props_p265=5,},--坦克紫7*1黄金宝箱*5
                    },
                },
            },
            ----------配置1结束-----------
            ----------配置2开始-----------
            [2]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p510=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p510=1,props_p265=5,},--歼击车紫7*1黄金宝箱*5
                    },
                },
            },
            ----------配置2结束-----------
            ----------配置3开始-----------
            [3]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p518=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p518=1,props_p265=5,},--自行火炮紫7*1黄金宝箱*5
                    },
                },
            },
            ----------配置3结束-----------
            ----------配置4开始-----------
            [4]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p526=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p526=1,props_p265=5,},--火箭车紫7*1黄金宝箱*5
                    },
                },
            },
            ----------配置4结束-----------
            ----------配置5开始-----------
            [5]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p506=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p506=1,props_p265=5,},--坦克紫8*1黄金宝箱*5
                    },
                },
            },
            ----------配置5结束-----------
            ----------配置6开始-----------
            [6]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p514=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p514=1,props_p265=5,},--歼击车紫8*1黄金宝箱*5
                    },
                },
            },
            ----------配置6结束-----------
            ----------配置7开始-----------
            [7]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p522=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p522=1,props_p265=5,},--自行火炮紫8*1黄金宝箱*5
                    },
                },
            },
            ----------配置7结束-----------
            ----------配置8开始-----------
            [8]={
                type=1,
                sortID=267,
                reward={
                    {p={{p12=1,index=1},{p20=5,index=2}}},
                    {p={{p11=3,index=1},{p292=10,index=2}}},
                    {p={{p5=2,index=1},{p2=1,index=2}}},
                    {p={{p230=2,index=1},{p264=5,index=2}}},
                    {p={{p530=1,index=1},{p265=5,index=2}}},
                },
                cost = {1000,3000,9000,18000,30000 },
                serverreward={
                    r={
                        {props_p12=1,props_p20=5,},--热核炸药*1统率书*5
                        {props_p11=3,props_p292=10,},--小型能量盾*3演习令*10
                        {props_p5=2,props_p2=1,},--加速生产*2小型资源箱*1
                        {props_p230=2,props_p264=5,},--万能碎片*2白银宝箱*5
                        {props_p530=1,props_p265=5,},--火箭车紫8*1黄金宝箱*5
                    },
                },
            },
            ----------配置8结束-----------
			
        },
        --技术革新
        newTech = {
            type = 1,
            sortId = 277,
            pool={"p427","p428","p429","p430"},
            -- {道具，道具需要的个数，得到道具}  道具合成
            pa = {
                {"p12",5,"p421"},
                {"p11",5,"p422"},
                {"p13",5,"p423"},
                {"p42",5,"p424"},
                {"p43",5,"p425"},
                {"p44",5,"p426"},
            },
            -- {道具，道具需要的个数}得到奖励池pool1或pool2中得某种道具  道具研究 需要消耗的道具，p11 3个或者 p12 三个
            pb = {
                {"p12",7},
                {"p11",7},
                {"p13",15},
                {"p42",3},
                {"p43",3},
                {"p44",3},
                {"p15",10},
            },
            serverreward={ --道具研究随机配置
                small={
                    {100},
                    {15,15,20,10,10,10,5,5,5,5},
                    {{"p421",1},{"p422",1},{"p423",1},{"p424",1},{"p425",1},{"p426",1},{"p427",1},{"p428",1},{"p429",1},{"p430",1}},
                },
                big={
                    {100},
                    {1,1,1,1},
                    {{"p427",1},{"p428",1},{"p429",1},{"p430",1}},
                },
            },
        },
        --共和国光辉活动
        republicHui={
            type=1,
            sortId=297,
            free=1,--每日免费次数
            cost=38, --普通的消耗金币
            multiCost=228,--特殊的消耗98金币
            --合成需要的碎片数量
            reward={
                needPartNum=20,-- 所需碎片个数
                gettank={a10093=10}, -- 产出坦克数
            },
            pool={mm={{m1=3,index=1},{m1=8,index=3},{m1=5,index=5},{m1=2,index=7},{m1=10,index=9},{m1=1,index=11},},p={{p20=1,index=2},{p19=1,index=4},{p13=1,index=6},{p47=1,index=8},{p263=1,index=10},{p15=1,index=12},}},
            serverreward={
                pool={
                    [1]={mm_m1=3},[3]={mm_m1=8},[5]={mm_m1=5},[7]={mm_m1=2},[9]={mm_m1=10},[11]={mm_m1=1},[2]={props_p20=1},[4]={props_p19=1},[6]={props_p13=1},[8]={props_p47=1},[10]={props_p263=1},[12]={props_p15=1},
                },
                --骰子的取值范围
                saizi = {{1,6},{1,6}},
            },
        },

        --共和国光辉活动(改)
        republicHuiGai={
            type=1,
            sortId=297,
            free=1,--每日免费次数
            cost=38, --普通的消耗金币
            multiCost=228,--特殊的消耗98金币
            --合成需要的碎片数量
            reward={
                needPartNum=20,-- 所需碎片个数
                gettank={a10093=10}, -- 产出坦克数
            },
            pool={mm={{m1=3,index=1},{m1=8,index=3},{m1=5,index=5},{m1=2,index=7},{m1=10,index=9},{m1=1,index=11},},p={{p20=1,index=2},{p19=1,index=4},{p13=1,index=6},{p47=1,index=8},{p263=1,index=10},{p15=1,index=12},}},
            serverreward={
                pool={
                    [1]={mm_m1=3},[3]={mm_m1=8},[5]={mm_m1=5},[7]={mm_m1=2},[9]={mm_m1=10},[11]={mm_m1=1},[2]={props_p20=1},[4]={props_p19=1},[6]={props_p13=1},[8]={props_p47=1},[10]={props_p263=1},[12]={props_p15=1},
                },
                --骰子的取值范围
                saizi = {{1,6},{1,6}},
            },
        },

        --国庆攻势
        nationalCampaign = {
            type=1,
            sortId=317,
            refreshTime={19, 11, 3},
            destoryRate=20,
            destoryRateDown=10,
            expAdd=50,
            buy={
                {id=1,gift="p287",num=2,discount=0.72,},
                {id=2,gift="p401",num=2,discount=0.9,},
                {id=3,gift="p402",num=2,discount=0.9,},
                {id=4,gift="p403",num=2,discount=0.9,},
                {id=5,gift="p404",num=2,discount=0.9,},
                {id=6,gift="p96",num=2,discount=0.299,},
                {id=7,gift="p97",num=2,discount=0.299,},
                {id=8,gift="p98",num=2,discount=0.299,},
                {id=9,gift="p99",num=2,discount=0.299,},
                {id=10,gift="p51",num=2,discount=0.299,},
                {id=11,gift="p1",num=2,discount=0.8,},
                {id=12,gift="p48",num=2,discount=0.399,},
                {id=13,gift="p290",num=2,discount=0.939,},
                {id=14,gift="p49",num=2,discount=0.71,},
            },
        },

        --坦克拉吧自定义版本
        customLottery = {
            type=1,
            sortId = 327,
            cost=20, --不免费时抽一次的金币花费
            time=8, --次数限制
            good={{p='p427'}, {p='p428'}}, --需要广播的
            list={{p='p427', num=1}, {p='p428', num=1}, {p='p429', num=1}, {p='p430', num=1}}, --道具列表
            pool={
                {100},
                {1,1,1,1},
                {{"props_p427",1},{"props_p428",1},{"props_p429",1},{"props_p430",1}},
            },
        },


        --驱鬼大战
        ghostWars={
            type=1,
            sortId=337,
            collectspeedup=0.2,--采集速度增加比例
            pointup=0.2,--战功获取增加比例
            minLv=40, --最小等级
            --掉落道具，道具抽取概率
            serverreward={
                pool={--物品额外掉落概率
                    {100},
                    {15,15,15,15,10,10,10,10,},
                    {{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},{"props_p416",1},{"accessory_p3",1},{"accessory_p2",1},{"accessory_p1",1},},
                },
                --等级掉落物品概率{资源点等级,掉落概率}
                level={
                    {50,30},
                    {48,28},
                    {46,26},
                    {44,24},
                    {42,22},
                    {40,20},
                },
            },
        },
        --门后有鬼活动
     --门后有鬼活动
    doorGhost = {
        multiSelectType = true,
        [1] = {
            type=1,
            sortId=347,
            --每次可以翻几张牌
            time=3,
            --重置需要消耗的金币(第一次100， 第二次200, 第四次以后都是400)
            refreshCost={20,25,30,35,40,45,50,55,60,65,70,75,80,},
            --每日几点重置数据
            refreshTime=0,
            --vip用户几级以上可以免费多重置一次
            vipLv=1,
            --最多可以加多少个鬼
            maxghost=9999,
            ghostReward={
                --nm鬼的数量对应奖励
                {nm=1,reward={p={{p30=1,index=1}},}},
                {nm=3,reward={p={{p20=2,index=1}},}},
                {nm=5,reward={p={{p272=3,index=1}},}},
                {nm=10,reward={p={{p564=1,index=1}},}},
                {nm=20,reward={p={{p292=3,index=1}},}},
                {nm=30,reward={p={{p89=1,index=1}},}},
                {nm=50,reward={p={{p393=30,index=1}},}},
                {nm=70,reward={p={{p44=2,index=1}},}},
                {nm=100,reward={p={{p565=1,index=1}},}},
                {nm=150,reward={p={{p394=30,index=1}},}},
                {nm=200,reward={u={{gems=500,index=1}},}},
                {nm=300,reward={p={{p395=50,index=1}},}},
                {nm=400,reward={p={{p396=50,index=1}},}},
                {nm=500,reward={p={{p566=1,index=1}},}},
            },
            serverreward={
                --抽牌
                pool={
                    {0,0,0,0,0,100},
                    {25,2,6,6,6,6,5,5,5,5,5,5,5,5,5,4,},
                    --鬼牌gt_g1
                    {{"gt_g1",1},{"gt_g1",10},{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},{"props_p15",1},{"props_p20",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p30",1},{"props_p47",1},{"props_p19",1},}
                },
                ghostReward={
                    --nm鬼的数量
                    {nm=1,reward={props_p30=1}},
                    {nm=3,reward={props_p20=2}},
                    {nm=5,reward={props_p272=3}},
                    {nm=10,reward={props_p564=1}},
                    {nm=20,reward={props_p292=3}},
                    {nm=30,reward={props_p89=1}},
                    {nm=50,reward={props_p393=30}},
                    {nm=70,reward={props_p44=2}},
                    {nm=100,reward={props_p565=1}},
                    {nm=150,reward={props_p394=30}},
                    {nm=200,reward={userinfo_gems=500}},
                    {nm=300,reward={props_p395=50}},
                    {nm=400,reward={props_p396=50}},
                    {nm=500,reward={props_p566=1}},
                }
            },
        },
        --1-4
        [2] = {
            type=1,
            sortId=347,
            --每次可以翻几张牌
            time=3,
            --重置需要消耗的金币(第一次100， 第二次200, 第四次以后都是400)
            refreshCost={20,25,30,35,40,45,50,55,60,65,70,75,80,},
            --每日几点重置数据
            refreshTime=0,
            --vip用户几级以上可以免费多重置一次
            vipLv=1,
            --最多可以加多少个鬼
            maxghost=9999,
            ghostReward={
                --nm鬼的数量对应奖励
                {nm=1,reward={p={{p30=1,index=1}},}},
                {nm=3,reward={p={{p20=5,index=1}},}},
                {nm=5,reward={p={{p272=5,index=1}},}},
                {nm=10,reward={p={{p88=1,index=1}},}},
                {nm=20,reward={p={{p292=3,index=1}},}},
                {nm=30,reward={p={{p89=1,index=1}},}},
                {nm=50,reward={e={{p3=50,index=1}},}},
                {nm=70,reward={p={{p44=3,index=1}},}},
                {nm=100,reward={p={{p230=1,index=1}},}},
                {nm=150,reward={e={{p2=50,index=1}},}},
                {nm=200,reward={u={{gems=500,index=1}},}},
                {nm=300,reward={e={{p1=50,index=1}},}},
                {nm=400,reward={p={{p36=10,index=1}},}},
                {nm=500,reward={p={{p90=1,index=1}},}},
            },
            serverreward={
                --抽牌
                pool={
                    {0,0,0,0,0,100},
                    {25,2,6,6,6,6,5,5,5,5,5,5,5,5,5,4,},
                    --鬼牌gt_g1
                    {{"gt_g1",1},{"gt_g1",10},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p15",1},{"props_p20",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p30",1},{"props_p47",1},{"props_p19",1},}
                },
                ghostReward={
                    --nm鬼的数量
                    {nm=1,reward={props_p30=1}},
                    {nm=3,reward={props_p20=5}},
                    {nm=5,reward={props_p272=5}},
                    {nm=10,reward={props_p88=1}},
                    {nm=20,reward={props_p292=3}},
                    {nm=30,reward={props_p89=1}},
                    {nm=50,reward={accessory_p3=50}},
                    {nm=70,reward={props_p44=3}},
                    {nm=100,reward={props_p230=1}},
                    {nm=150,reward={accessory_p2=50}},
                    {nm=200,reward={userinfo_gems=500}},
                    {nm=300,reward={accessory_p1=50}},
                    {nm=400,reward={props_p36=10}},
                    {nm=500,reward={props_p90=1}},
                }
            },
        },
        --1-6
        [3] = {
            type=1,
            sortId=347,
            --每次可以翻几张牌
            time=3,
            --重置需要消耗的金币(第一次100， 第二次200, 第四次以后都是400)
            refreshCost={20,25,30,35,40,45,50,55,60,65,70,75,80,},
            --每日几点重置数据
            refreshTime=0,
            --vip用户几级以上可以免费多重置一次
            vipLv=1,
            --最多可以加多少个鬼
            maxghost=9999,
            ghostReward={
                --nm鬼的数量对应奖励
                {nm=1,reward={p={{p30=1,index=1}},}},
                {nm=5,reward={p={{p20=3,index=1}},}},
                {nm=10,reward={p={{p272=5,index=1}},}},
                {nm=20,reward={p={{p268=1,index=1}},}},
                {nm=30,reward={p={{p292=5,index=1}},}},
                {nm=50,reward={p={{p89=1,index=1}},}},
                {nm=70,reward={p={{p393=50,index=1}},}},
                {nm=100,reward={p={{p44=5,index=1}},}},
                {nm=150,reward={p={{p269=1,index=1}},}},
                {nm=200,reward={p={{p394=50,index=1}},}},
                {nm=250,reward={u={{gems=500,index=1}},}},
                {nm=300,reward={p={{p90=1,index=1}},}},
                {nm=400,reward={p={{p48=2,index=1}},}},
                {nm=500,reward={p={{p270=1,index=1}},}},
            },
            serverreward={
                --抽牌
                pool={
                    {0,0,0,0,0,100},
                    {25,2,6,6,6,6,5,5,5,5,5,5,5,5,5,4,},
                    --鬼牌gt_g1
                    {{"gt_g1",1},{"gt_g1",10},{"props_p393",1},{"props_p394",1},{"accessory_p6",1},{"accessory_p1",1},{"props_p15",1},{"props_p20",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p30",1},{"props_p47",1},{"props_p19",1},}
                },
                ghostReward={
                    --nm鬼的数量
                    {nm=1,reward={props_p30=1}},
                    {nm=5,reward={props_p20=3}},
                    {nm=10,reward={props_p272=5}},
                    {nm=20,reward={props_p268=1}},
                    {nm=30,reward={props_p292=5}},
                    {nm=50,reward={props_p89=1}},
                    {nm=70,reward={props_p393=50}},
                    {nm=100,reward={props_p44=5}},
                    {nm=150,reward={props_p269=1}},
                    {nm=200,reward={props_p394=50}},
                    {nm=250,reward={userinfo_gems=500}},
                    {nm=300,reward={props_p90=1}},
                    {nm=400,reward={props_p48=2}},
                    {nm=500,reward={props_p270=1}},
                }
            },
        },
    },

        --备战巅峰活动
        preparingPeak={
            sortId = 357,
            type = 1,
            buy={
                {id=1,gift="p578",num=3,discount=0.8072},
                {id=2,gift="p579",num=3,discount=0.3315},
                {id=3,gift="p580",num=3,discount=0.5342},
            },
        },

        --脱光行动 光棍节
        singles={
            multiSelectType = true,
            --1-4配件，无改造材料
            [1] = {
                sortId=387,
                type=1,
                cost=28, --不免费时抽1次的金币花费
                mul=11, --11倍连抽
                mulc=9,--11连抽花费的金币是mulc*cost
                --兑换时需要发公告的物品
                goods={"i2","i3","i4","i5"},
                --抽奖能够抽到的所有物品
                circleList={
                    mm={{mm_m1=5,index=1},{mm_m1=10,index=3},{mm_m2=1,index=5},{mm_m2=2,index=7},{mm_m3=1,index=9},},
                    p={{p19=1,index=2},{p12=1,index=4},{p11=1,index=6},{p20=1,index=8},{p47=1,index=10},{p15=1,index=11},},
                },
                --vip每日获得代币(vip等级， 奖励内容)
                vipReward={
                    {9,{mm_m1=10,mm_m2=1,},},
                    {8,{mm_m1=10,mm_m2=1,},},
                    {7,{mm_m1=10,mm_m2=1,},},
                    {6,{mm_m1=10,mm_m2=1,},},
                    {5,{mm_m1=10,},},
                    {4,{mm_m1=10,},},
                    {3,{mm_m1=10,},},
                    {2,{mm_m1=10,},},
                    {1,{mm_m1=10,},},
                    {0,{mm_m1=5,},},
                },
                shopItem={
                    --mm_m1 光棍 mm_m2 基友 mm_m3 女神
                    {id="i1",buynum=100,price={mm_m1=1,},reward={p={{p19=1}}},serverReward={props_p19=1}},
                    {id="i2",buynum=1,price={mm_m1=50,mm_m2=5,mm_m3=3,},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i3",buynum=1,price={mm_m1=50,mm_m2=5,mm_m3=8,},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i4",buynum=1,price={mm_m1=50,mm_m2=5,mm_m3=15,},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i5",buynum=2,price={mm_m1=50,mm_m2=5,mm_m3=5,},reward={p={{p90=1}}},serverReward={props_p90=1}},
                    {id="i6",buynum=100,price={mm_m2=1,},reward={o={{a10005=1}}},serverReward={troops_a10005=1}},
                    {id="i7",buynum=100,price={mm_m2=1,},reward={o={{a10015=1}}},serverReward={troops_a10015=1}},
                    {id="i8",buynum=100,price={mm_m2=1,},reward={o={{a10025=1}}},serverReward={troops_a10025=1}},
                    {id="i9",buynum=100,price={mm_m2=1,},reward={o={{a10035=1}}},serverReward={troops_a10035=1}},
                    {id="i10",buynum=10,price={mm_m1=100,},reward={o={{a10043=10}}},serverReward={troops_a10043=10}},
                    {id="i11",buynum=10,price={mm_m1=100,},reward={o={{a10053=10}}},serverReward={troops_a10053=10}},
                    {id="i12",buynum=10,price={mm_m1=100,},reward={o={{a10063=10}}},serverReward={troops_a10063=10}},
                    {id="i13",buynum=10,price={mm_m1=100,},reward={o={{a10073=10}}},serverReward={troops_a10073=10}},
                    {id="i14",buynum=100,price={mm_m1=10,mm_m2=1,},reward={e={{p1=1}}},serverReward={accessory_p1=1}},
                    {id="i15",buynum=100,price={mm_m1=10,mm_m2=1,},reward={e={{p2=2}}},serverReward={accessory_p2=2}},
                    {id="i16",buynum=100,price={mm_m1=10,},reward={e={{p3=5}}},serverReward={accessory_p3=5}},
                },
                serverreward={
                    pool={
                        {100},
                        {20,10,15,16,4,5,5,5,5,10,5,},
                        {{"mm_m1",5},{"mm_m1",10},{"mm_m2",1},{"mm_m2",2},{"mm_m3",1},{"props_p19",1},{"props_p12",1},{"props_p11",1},{"props_p20",1},{"props_p47",1},{"props_p15",1},}
                    },
                },
            },
            --1-6
            [2] = {
                sortId=387,
                type=1,
                cost=28,--不免费时抽1次的金币花费
                mul=11,--11倍连抽
                mulc=9,--11连抽花费的金币是mulc*cost
                --兑换时需要发公告的物品
                goods={"i2","i3","i4","i5"},
                --抽奖能够抽到的所有物品
                circleList={
                    mm={{mm_m1=5,index=1},{mm_m1=10,index=3},{mm_m2=1,index=5},{mm_m2=2,index=7},{mm_m3=1,index=9},},
                    p={{p19=1,index=2},{p12=1,index=4},{p11=1,index=6},{p20=1,index=8},{p47=1,index=10},{p15=1,index=11},},
                },
                --vip每日获得代币(vip等级， 奖励内容)
                vipReward={
                    {9,{mm_m1=10,mm_m2=1,},},
                    {8,{mm_m1=10,mm_m2=1,},},
                    {7,{mm_m1=10,mm_m2=1,},},
                    {6,{mm_m1=10,mm_m2=1,},},
                    {5,{mm_m1=10,},},
                    {4,{mm_m1=10,},},
                    {3,{mm_m1=10,},},
                    {2,{mm_m1=10,},},
                    {1,{mm_m1=10,},},
                    {0,{mm_m1=5,},},
                },
                shopItem={
                    --mm_m1 光棍 mm_m2 基友 mm_m3 女神
                    {id="i1",buynum=100,price={mm_m1=1,},reward={p={{p19=1}}},serverReward={props_p19=1}},
                    {id="i2",buynum=1,price={mm_m1=50,mm_m2=5,mm_m3=3,},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i3",buynum=1,price={mm_m1=50,mm_m2=5,mm_m3=8,},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i4",buynum=1,price={mm_m1=50,mm_m2=5,mm_m3=15,},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i5",buynum=2,price={mm_m1=50,mm_m2=5,mm_m3=10,},reward={p={{p270=1}}},serverReward={props_p270=1}},
                    {id="i6",buynum=100,price={mm_m2=1,},reward={p={{p393=1}}},serverReward={props_p393=1}},
                    {id="i7",buynum=100,price={mm_m2=1,},reward={p={{p394=1}}},serverReward={props_p394=1}},
                    {id="i8",buynum=100,price={mm_m2=1,},reward={p={{p395=1}}},serverReward={props_p395=1}},
                    {id="i9",buynum=100,price={mm_m2=1,},reward={p={{p396=1}}},serverReward={props_p396=1}},
                    {id="i10",buynum=10,price={mm_m1=10,},reward={o={{a10006=1}}},serverReward={troops_a10006=1}},
                    {id="i11",buynum=10,price={mm_m1=10,},reward={o={{a10016=1}}},serverReward={troops_a10016=1}},
                    {id="i12",buynum=10,price={mm_m1=10,},reward={o={{a10026=1}}},serverReward={troops_a10026=1}},
                    {id="i13",buynum=10,price={mm_m1=10,},reward={o={{a10036=1}}},serverReward={troops_a10036=1}},
                    {id="i14",buynum=100,price={mm_m1=10,mm_m2=1,},reward={e={{p1=1}}},serverReward={accessory_p1=1}},
                    {id="i15",buynum=100,price={mm_m1=10,mm_m2=1,},reward={e={{p2=2}}},serverReward={accessory_p2=2}},
                    {id="i16",buynum=100,price={mm_m1=10,},reward={e={{p3=5}}},serverReward={accessory_p3=5}},
                },
                serverreward={
                    pool={
                        {100},
                        {20,10,15,16,4,5,5,5,5,10,5,},
                        {{"mm_m1",5},{"mm_m1",10},{"mm_m2",1},{"mm_m2",2},{"mm_m3",1},{"props_p19",1},{"props_p12",1},{"props_p11",1},{"props_p20",1},{"props_p47",1},{"props_p15",1},}
                    },
                },
            },
        },


        --天天爱助威
        dayCheer = {
            type = 1,
            sortId = 367,
            reward = {
                {p={{p19=3,index=1},{p30=1,index=2},}},  --第一次
                {p={{p292=1,index=1},{p41=1,index=2},}},  --第二次
                {p={{p393=5,index=1},},e={{p3=5,index=2},}},  --第三次
                {p={{p19=10,index=1},{p12=1,index=2},},e={{p2=5,index=3},}},  --第四次
                {p={{p267=2,index=1},{p20=1,index=2},},e={{p1=5,index=3},}},  --第五次
            },
            serverreward = {
                {props_p19=3,props_p30=1,},  --第一次
                {props_p292=1,props_p41=1,},  --第二次
                {props_p393=5,accessory_p3=5,},  --第三次
                {props_p19=10,props_p12=1,accessory_p2=5,},  --第四次
                {props_p267=2,props_p20=1,accessory_p1=5,},  --第五次
            },
        },

        --鸡动部队
        jidongbudui={
            multiSelectType = true,
            [1] = {
                type = 1,
                sortId = 407,
                --投放的坦克剩余多少时显示具体的数量
                showNums=9990,
                --个人获得坦克限制
                limitNums=1000,
                --抽奖显示的数量
                cost=48,
                --兑换坦克
                reward={
                    needPartNum=100, --所需碎片个数
                    gettank={a10103=10}, --产出坦克数
                },
                --坦克没有时可以兑换的道具
                otherReward={
                    p={{p19=1,num=3,index=1},{p20=1,num=25,index=2},{p5=1,num=80,index=3},},
                },
                --抽奖配置
                pool={mm={{m1=20,index=1},{m1=50,index=5},},p={{p32=1,index=2},{p33=1,index=3},{p34=1,index=4},{p35=1,index=6},{p36=1,index=7},{p2=1,index=8},}},
                serverreward = {
                    otherReward = {
                        [1]={props_p19=1,num=3},[2]={props_p20=1,num=25},[3]={props_p5=1,num=80},
                    },
                    --火鸡部队代号，关卡npc
                    trType=5,
                    --坦克的投放数量
                    trNums=90000,
                    --新坦克的id
                    trChicken = "a10103",
                    --抽奖配置
                    pool={
                        {100},
                        {25,25,9,9,9,9,13,1,},
                        {{"mm_m1",20},{"mm_m1",50},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1},{"props_p2",1},
                        }
                    },
                },
            },
            --配置2
            [2] = {
                type = 1,
                sortId = 407,
                --投放的坦克剩余多少时显示具体的数量
                showNums=9990,
                --个人获得坦克限制
                limitNums=1000,
                --抽奖显示的数量
                cost=48,
                --兑换坦克
                reward={
                    needPartNum=100, --所需碎片个数
                    gettank={a10103=10}, --产出坦克数
                },
                --坦克没有时可以兑换的道具
                otherReward={
                    p={{p19=1,num=3,index=1},{p20=1,num=25,index=2},{p5=1,num=80,index=3},},
                },
                --抽奖配置
                pool={mm={{m1=20,index=1},{m1=50,index=5},},p={{p26=2,index=2},{p27=2,index=3},{p28=2,index=4},{p29=2,index=6},{p30=2,index=7},{p2=1,index=8},}},
                serverreward = {
                    otherReward = {
                        [1]={props_p19=1,num=3},[2]={props_p20=1,num=25},[3]={props_p5=1,num=80},
                    },
                    --火鸡部队代号，关卡npc
                    trType=5,
                    --坦克的投放数量
                    trNums=90000,
                    --新坦克的id
                    trChicken = "a10103",
                    --抽奖配置
                    pool={
                        {100},
                        {25,25,9,9,9,9,9,5,},
                        {{"mm_m1",20},{"mm_m1",50},{"props_p26",2},{"props_p27",2},{"props_p28",2},{"props_p29",2},{"props_p30",2},{"props_p2",1},
                        }
                    },
                },
            },
        },

        -- 英雄十连抽
        heroTenLottery ={
            sortId=417,
            type=1,
            cost=28, --金币花费
            serverreward={
                --抽牌
                pool={
                    {0,0,0,0,0,0,0,0,100},
                    {25,20,6,6,6,6,5,5,5,5,5,5,5,5,5,4,14,4,24,4,9,4,4,8,4,7,4,4,4,6,5,8,4,10,16,18,32,9,35},
                    --鬼牌gt_g1
                    {{"props_p393",1},{"props_p394",1},{"props_p15",1},{"props_p20",1},{"props_p21",1},{"props_p22",1},{"props_p23",1},{"props_p24",1},{"props_p25",1},{"props_p30",1},{"props_p47",1},{"props_p19",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                heropool={
                    {100},
                    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
                    {{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1}}
                },
            },
        },

        -- 月度将领
        yuedujiangling = {
            multiSelectType=true,
            [1]={
                sortId=903,
                cost={20000,50},-- 消耗军功,充值金币
                reward={
                    {h={{s27=2,index=1}},p={{p20=1,index=2},{p601=5,index=3}}},-- 军功奖励
                    {h={{s27=6,index=1}},p={{p20=3,index=2},{p601=15,index=3}}},-- 金币奖励
                },
                serverreward={
                    {hero_s27=2,props_p20=1,props_p601=5},-- 军功奖励
                    {hero_s27=6,props_p20=3,props_p601=15},-- 金币奖励
                },
            },
            
        },

        --摧枯拉朽活动
        cuikulaxiu={
            multiSelectType=true,
            [1]={
                type=1,
                sortId=397,
                minPoint=100000,
                pointReward={
                    {100000,{o={{a10034=100,index=1},},}},
                    {20000,{p={{p265=2,index=1},},}},
                    {10000,{p={{p20=2,index=1},},}},
                    {2000,{p={{p264=2,index=1},},}},
                    {500,{p={{p19=10,index=1},},}},
                },
                rankReward={
                    {{1,1},{e={{p3=30,index=1},{p2=30,index=2},{p1=30,index=3},},}},
                    {{2,2},{e={{p3=25,index=1},{p2=25,index=2},{p1=25,index=3},},}},
                    {{3,3},{e={{p3=20,index=1},{p2=20,index=2},{p1=20,index=3},},}},
                    {{4,4},{e={{p3=15,index=1},{p2=15,index=2},{p1=15,index=3},},}},
                    {{5,5},{e={{p3=12,index=1},{p2=12,index=2},{p1=12,index=3},},}},
                    {{6,6},{e={{p3=10,index=1},{p2=10,index=2},{p1=10,index=3},},}},
                    {{7,7},{e={{p3=8,index=1},{p2=8,index=2},{p1=8,index=3},},}},
                    {{8,8},{e={{p3=7,index=1},{p2=7,index=2},{p1=7,index=3},},}},
                    {{9,9},{e={{p3=6,index=1},{p2=6,index=2},{p1=6,index=3},},}},
                    {{10,10},{e={{p3=5,index=1},{p2=5,index=2},{p1=5,index=3},},}},
                },
                serverreward={
                    pointReward={
                        {100000,{troops_a10034=100,}},
                        {20000,{props_p265=2,}},
                        {10000,{props_p20=2,}},
                        {2000,{props_p264=2,}},
                        {500,{props_p19=10,}},
                    },
                    rankReward={
                        {{1,1},{accessory_p3=30,accessory_p2=30,accessory_p1=30,}},
                        {{2,2},{accessory_p3=25,accessory_p2=25,accessory_p1=25,}},
                        {{3,3},{accessory_p3=20,accessory_p2=20,accessory_p1=20,}},
                        {{4,4},{accessory_p3=15,accessory_p2=15,accessory_p1=15,}},
                        {{5,5},{accessory_p3=12,accessory_p2=12,accessory_p1=12,}},
                        {{6,6},{accessory_p3=10,accessory_p2=10,accessory_p1=10,}},
                        {{7,7},{accessory_p3=8,accessory_p2=8,accessory_p1=8,}},
                        {{8,8},{accessory_p3=7,accessory_p2=7,accessory_p1=7,}},
                        {{9,9},{accessory_p3=6,accessory_p2=6,accessory_p1=6,}},
                        {{10,10},{accessory_p3=5,accessory_p2=5,accessory_p1=5,}},
                    },
                },
            },
            --有配置2
            [2]={
                type=1,
                sortId=397,
                minPoint=1000000,
                pointReward={
                    {1000000,{o={{a10034=100,index=1},},}},
                    {200000,{p={{p265=2,index=1},},}},
                    {100000,{p={{p20=2,index=1},},}},
                    {20000,{p={{p264=2,index=1},},}},
                    {5000,{p={{p19=10,index=1},},}},
                },
                rankReward={
                    {{1,1},{e={{p3=30,index=1},{p2=30,index=2},{p1=30,index=3},},}},
                    {{2,2},{e={{p3=25,index=1},{p2=25,index=2},{p1=25,index=3},},}},
                    {{3,3},{e={{p3=20,index=1},{p2=20,index=2},{p1=20,index=3},},}},
                    {{4,4},{e={{p3=15,index=1},{p2=15,index=2},{p1=15,index=3},},}},
                    {{5,5},{e={{p3=12,index=1},{p2=12,index=2},{p1=12,index=3},},}},
                    {{6,6},{e={{p3=10,index=1},{p2=10,index=2},{p1=10,index=3},},}},
                    {{7,7},{e={{p3=8,index=1},{p2=8,index=2},{p1=8,index=3},},}},
                    {{8,8},{e={{p3=7,index=1},{p2=7,index=2},{p1=7,index=3},},}},
                    {{9,9},{e={{p3=6,index=1},{p2=6,index=2},{p1=6,index=3},},}},
                    {{10,10},{e={{p3=5,index=1},{p2=5,index=2},{p1=5,index=3},},}},
                },
                serverreward={
                    pointReward={
                        {1000000,{troops_a10034=100,}},
                        {200000,{props_p265=2,}},
                        {100000,{props_p20=2,}},
                        {20000,{props_p264=2,}},
                        {5000,{props_p19=10,}},
                    },
                    rankReward={
                        {{1,1},{accessory_p3=30,accessory_p2=30,accessory_p1=30,}},
                        {{2,2},{accessory_p3=25,accessory_p2=25,accessory_p1=25,}},
                        {{3,3},{accessory_p3=20,accessory_p2=20,accessory_p1=20,}},
                        {{4,4},{accessory_p3=15,accessory_p2=15,accessory_p1=15,}},
                        {{5,5},{accessory_p3=12,accessory_p2=12,accessory_p1=12,}},
                        {{6,6},{accessory_p3=10,accessory_p2=10,accessory_p1=10,}},
                        {{7,7},{accessory_p3=8,accessory_p2=8,accessory_p1=8,}},
                        {{8,8},{accessory_p3=7,accessory_p2=7,accessory_p1=7,}},
                        {{9,9},{accessory_p3=6,accessory_p2=6,accessory_p1=6,}},
                        {{10,10},{accessory_p3=5,accessory_p2=5,accessory_p1=5,}},
                    },
                },
            },
			--有配置3
			[3]={
				type=1,
				sortId=397,
				minPoint=10000000,--最低计入排行榜2的军功量
				pointReward={--军功量，奖励
					{10000000,{o={{a10044=30,index=1},},}},
					{5000000,{p={{p265=5,index=1},},}},
					{2000000,{p={{p3302=5,index=1},},}},
					{1000000,{p={{p264=5,index=1},},}},
					{500000,{p={{p19=20,index=1},},}},
				},
				rankReward={--排名，奖励
					{{1,1},{p={{p4820=10,index=1},{p265=10,index=2},{p282=10,index=3},},}},
					{{2,2},{p={{p4820=8,index=1},{p265=8,index=2},{p282=8,index=3},},}},
					{{3,3},{p={{p4820=6,index=1},{p265=6,index=2},{p282=6,index=3},},}},
					{{4,4},{p={{p4820=4,index=1},{p265=4,index=2},{p282=4,index=3},},}},
					{{5,5},{p={{p4820=2,index=1},{p265=2,index=2},{p282=2,index=3},},}},
					{{6,6},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{7,7},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{8,8},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{9,9},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{10,10},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
				},
                serverreward={
                    pointReward={--军功量，奖励
						{10000000,{troops_a10044=30,}},
						{5000000,{props_p265=5,}},
						{2000000,{props_p3302=5,}},
						{1000000,{props_p264=5,}},
						{500000,{props_p19=20,}},
					},
                    rankReward={--排名min, max，奖励
						{{1,1},{props_p4820=10,props_p265=10,props_p282=10,}},
						{{2,2},{props_p4820=8,props_p265=8,props_p282=8,}},
						{{3,3},{props_p4820=6,props_p265=6,props_p282=6,}},
						{{4,4},{props_p4820=4,props_p265=4,props_p282=4,}},
						{{5,5},{props_p4820=2,props_p265=2,props_p282=2,}},
						{{6,6},{props_p265=2,props_p279=5,props_p282=2,}},
						{{7,7},{props_p265=2,props_p279=5,props_p282=2,}},
						{{8,8},{props_p265=2,props_p279=5,props_p282=2,}},
						{{9,9},{props_p265=2,props_p279=5,props_p282=2,}},
						{{10,10},{props_p265=2,props_p279=5,props_p282=2,}},
					},
				},
			},
			--有配置4
			[4]={
				type=1,
				sortId=397,
				minPoint=10000000,--最低计入排行榜2的军功量
				pointReward={--军功量，奖励
					{10000000,{o={{a10045=30,index=1},},}},
					{5000000,{p={{p265=5,index=1},},}},
					{2000000,{p={{p3302=5,index=1},},}},
					{1000000,{p={{p264=5,index=1},},}},
					{500000,{p={{p19=20,index=1},},}},
				},
				rankReward={--排名，奖励
					{{1,1},{p={{p4820=10,index=1},{p265=10,index=2},{p282=10,index=3},},}},
					{{2,2},{p={{p4820=8,index=1},{p265=8,index=2},{p282=8,index=3},},}},
					{{3,3},{p={{p4820=6,index=1},{p265=6,index=2},{p282=6,index=3},},}},
					{{4,4},{p={{p4820=4,index=1},{p265=4,index=2},{p282=4,index=3},},}},
					{{5,5},{p={{p4820=2,index=1},{p265=2,index=2},{p282=2,index=3},},}},
					{{6,6},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{7,7},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{8,8},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{9,9},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
					{{10,10},{p={{p265=2,index=1},{p279=5,index=2},{p282=2,index=3},},}},
				},
				serverreward={
					pointReward={--军功量，奖励
						{10000000,{troops_a10045=30,}},
						{5000000,{props_p265=5,}},
						{2000000,{props_p3302=5,}},
						{1000000,{props_p264=5,}},
						{500000,{props_p19=20,}},
					},
					rankReward={--排名min, max，奖励
						{{1,1},{props_p4820=10,props_p265=10,props_p282=10,}},
						{{2,2},{props_p4820=8,props_p265=8,props_p282=8,}},
						{{3,3},{props_p4820=6,props_p265=6,props_p282=6,}},
						{{4,4},{props_p4820=4,props_p265=4,props_p282=4,}},
						{{5,5},{props_p4820=2,props_p265=2,props_p282=2,}},
						{{6,6},{props_p265=2,props_p279=5,props_p282=2,}},
						{{7,7},{props_p265=2,props_p279=5,props_p282=2,}},
						{{8,8},{props_p265=2,props_p279=5,props_p282=2,}},
						{{9,9},{props_p265=2,props_p279=5,props_p282=2,}},
						{{10,10},{props_p265=2,props_p279=5,props_p282=2,}},
					},
				},
			},


        },


        --百福大礼
        baifudali = {
            multiSelectType=true,
            --360
            [1]={
                sortId=427,
                type=1,
                --前台区分显示文字
                version=1,
                --充值返利的条件
                goldcondition=3600,
                --充值返利奖励
                goldreward=3600,
                levellimit=20, --此等级以上才可领取每日奖励
                --每日奖励
                daily={u={{r1=3600000,index=1},{r2=3600000,index=2},{r3=3600000,index=3},{r4=3600000,index=4},{gold=3600000,index=5},},},
                --修理坦克减少的金币或者晶石消耗 减少100%
                repairVate=1,
                serverreward={
                    --每日奖励
                    daily={userinfo_r1=3600000,userinfo_r2=3600000,userinfo_r3=3600000,userinfo_r4=3600000,userinfo_gold=3600000,},
                },
            },
            --3k
            [2]={
                sortId=427,
                type=1,
                --前台区分显示文字
                version=2,
                --充值返利的条件
                goldcondition=3000,
                --充值返利奖励
                goldreward=3000,
                levellimit=20, --此等级以上才可领取每日奖励
                --每日奖励
                daily={u={{r1=3000000,index=1},{r2=3000000,index=2},{r3=3000000,index=3},{r4=3000000,index=4},{gold=3000000,index=5},},},
                --修理坦克减少的金币或者晶石消耗 减少100%
                repairVate=1,
                serverreward={
                    --每日奖励
                    daily={userinfo_r1=3000000,userinfo_r2=3000000,userinfo_r3=3000000,userinfo_r4=3000000,userinfo_gold=3000000,},
                },
            },
            --新配置
            [3]={
                sortId=427,
                type=1,
                --前台区分显示文字
                version=3,
                --充值返利的条件
                goldcondition=3000,
                --充值返利奖励
                goldreward=3000,
                levellimit=20, --此等级以上才可领取每日奖励
                --每日奖励
                daily={u={{r1=3000000,index=1},{r2=3000000,index=2},{r3=3000000,index=3},{r4=3000000,index=4},{gold=3000000,index=5},},},
                --修理坦克减少的金币或者晶石消耗 减少100%
                repairVate=1,
                serverreward={
                    --每日奖励
                    daily={userinfo_r1=3000000,userinfo_r2=3000000,userinfo_r3=3000000,userinfo_r4=3000000,userinfo_gold=3000000,},
                },
            },
        },

        --废墟探索
        feixutansuo={
            multiSelectType=true,
            [1]={
                sortId=437,
                type=1,
                cost=38, --不免费时抽1次的金币花费
                mul=10,--10倍连抽
                mulc=10, --10连抽花费的金币是mulc*cost
                version=1,
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10054={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10053',1},
                        upgradePropConsume={{"p19",1},{"p411",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={p={{p32=1,index=1,isSpecial=1},{p33=1,index=2,isSpecial=1},{p34=1,index=3,isSpecial=1},{p35=1,index=4,isSpecial=1},{p26=1,index=5,isSpecial=0},{p27=1,index=6,isSpecial=0},{p28=1,index=7,isSpecial=0},{p29=1,index=8,isSpecial=0},},},
                    [2]={p={{p411=1,index=1,isSpecial=1},{p411=5,index=2,isSpecial=1},{p32=1,index=3,isSpecial=0},{p33=1,index=4,isSpecial=0},{p34=1,index=5,isSpecial=0},{p35=1,index=6,isSpecial=0},},},
                    [3]={o={{a10053=1,index=1,isSpecial=1},{a10053=5,index=2,isSpecial=1},},p={{p411=2,index=3,isSpecial=1},{p411=10,index=4,isSpecial=1},{p1=1,index=5,isSpecial=1},{p19=10,index=6,isSpecial=0},},},
                    [4]={o={{a10054=5,index=1,isSpecial=1},{a10054=20,index=2,isSpecial=1},{a10053=5,index=3,isSpecial=1},{a10053=20,index=4,isSpecial=1},},p={{p411=3,index=5,isSpecial=1},{p411=15,index=6,isSpecial=1},},},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {6,8,12,14,9,12,18,21,},
                            {{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},},
                        },
                        [2]={
                            {100},
                            {20,10,10.5,14,21,24.5,},
                            {{"props_p411",1},{"props_p411",5},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},},
                        },
                        [3]={
                            {100},
                            {20,10,30,10,5,25,},
                            {{"troops_a10053",1},{"troops_a10053",5},{"props_p411",2},{"props_p411",10},{"props_p1",1},{"props_p19",10},},
                        },
                        [4]={
                            {100},
                            {20,10,20,10,30,10,},
                            {{"troops_a10054",5},{"troops_a10054",20},{"troops_a10053",5},{"troops_a10053",20},{"props_p411",3},{"props_p411",15},},
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={80,75,70,0},
                },
            },
            [2]={
                sortId=437,
                type=1,
                cost=38, --不免费时抽1次的金币花费
                version=2,
                mul=10,--10倍连抽
                mulc=10, --10连抽花费的金币是mulc*cost
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10044={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10043',1},
                        upgradePropConsume={{"p19",1},{"p410",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={p={{p32=1,index=1,isSpecial=1},{p33=1,index=2,isSpecial=1},{p34=1,index=3,isSpecial=1},{p35=1,index=4,isSpecial=1},{p26=1,index=5,isSpecial=0},{p27=1,index=6,isSpecial=0},{p28=1,index=7,isSpecial=0},{p29=1,index=8,isSpecial=0},},},
                    [2]={p={{p410=1,index=1,isSpecial=1},{p410=5,index=2,isSpecial=1},{p32=1,index=3,isSpecial=0},{p33=1,index=4,isSpecial=0},{p34=1,index=5,isSpecial=0},{p35=1,index=6,isSpecial=0},},},
                    [3]={o={{a10043=1,index=1,isSpecial=1},{a10043=5,index=2,isSpecial=1},},p={{p410=2,index=3,isSpecial=1},{p410=10,index=4,isSpecial=1},{p1=1,index=5,isSpecial=1},{p19=10,index=6,isSpecial=0},},},
                    [4]={o={{a10044=5,index=1,isSpecial=1},{a10044=20,index=2,isSpecial=1},{a10043=5,index=3,isSpecial=1},{a10043=20,index=4,isSpecial=1},},p={{p410=3,index=5,isSpecial=1},{p410=15,index=6,isSpecial=1},},},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {6,8,12,14,9,12,18,21,},
                            {{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},},
                        },
                        [2]={
                            {100},
                            {20,10,10.5,14,21,24.5,},
                            {{"props_p410",1},{"props_p410",5},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},},
                        },
                        [3]={
                            {100},
                            {20,10,30,10,5,25,},
                            {{"troops_a10043",1},{"troops_a10043",5},{"props_p410",2},{"props_p410",10},{"props_p1",1},{"props_p19",10},},
                        },
                        [4]={
                            {100},
                            {20,10,20,10,30,10,},
                            {{"troops_a10044",5},{"troops_a10044",20},{"troops_a10043",5},{"troops_a10043",20},{"props_p410",3},{"props_p410",15},},
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={80,75,70,0},
                },
            },
            [3]={
                sortId=437,
                type=1,
                cost=38, --不免费时抽1次的金币花费
                mul=10,--10倍连抽
                mulc=10, --10连抽花费的金币是mulc*cost
                version=3,
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10064={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10063',1},
                        upgradePropConsume={{"p19",1},{"p412",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={p={{p32=1,index=1,isSpecial=1},{p33=1,index=2,isSpecial=1},{p34=1,index=3,isSpecial=1},{p35=1,index=4,isSpecial=1},{p26=1,index=5,isSpecial=0},{p27=1,index=6,isSpecial=0},{p28=1,index=7,isSpecial=0},{p29=1,index=8,isSpecial=0},},},
                    [2]={p={{p412=1,index=1,isSpecial=1},{p412=5,index=2,isSpecial=1},{p32=1,index=3,isSpecial=0},{p33=1,index=4,isSpecial=0},{p34=1,index=5,isSpecial=0},{p35=1,index=6,isSpecial=0},},},
                    [3]={o={{a10063=1,index=1,isSpecial=1},{a10063=5,index=2,isSpecial=1},},p={{p412=2,index=3,isSpecial=1},{p412=10,index=4,isSpecial=1},{p1=1,index=5,isSpecial=1},{p19=10,index=6,isSpecial=0},},},
                    [4]={o={{a10064=5,index=1,isSpecial=1},{a10064=20,index=2,isSpecial=1},{a10063=5,index=3,isSpecial=1},{a10063=20,index=4,isSpecial=1},},p={{p412=3,index=5,isSpecial=1},{p412=15,index=6,isSpecial=1},},},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {6,8,12,14,9,12,18,21,},
                            {{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},},
                        },
                        [2]={
                            {100},
                            {20,10,10.5,14,21,24.5,},
                            {{"props_p412",1},{"props_p412",5},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},},
                        },
                        [3]={
                            {100},
                            {20,10,30,10,5,25,},
                            {{"troops_a10063",1},{"troops_a10063",5},{"props_p412",2},{"props_p412",10},{"props_p1",1},{"props_p19",10},},
                        },
                        [4]={
                            {100},
                            {20,10,20,10,30,10,},
                            {{"troops_a10064",5},{"troops_a10064",20},{"troops_a10063",5},{"troops_a10063",20},{"props_p412",3},{"props_p412",15},},
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={80,75,70,0},
                },
            },
            [4]={
                sortId=437,
                type=1,
                cost=38, --不免费时抽1次的金币花费
                mul=10,--10倍连抽
                mulc=10, --10连抽花费的金币是mulc*cost
                version=4,
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10074={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10073',1},
                        upgradePropConsume={{"p19",1},{"p413",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={p={{p32=1,index=1,isSpecial=1},{p33=1,index=2,isSpecial=1},{p34=1,index=3,isSpecial=1},{p35=1,index=4,isSpecial=1},{p26=1,index=5,isSpecial=0},{p27=1,index=6,isSpecial=0},{p28=1,index=7,isSpecial=0},{p29=1,index=8,isSpecial=0},},},
                    [2]={p={{p413=1,index=1,isSpecial=1},{p413=5,index=2,isSpecial=1},{p32=1,index=3,isSpecial=0},{p33=1,index=4,isSpecial=0},{p34=1,index=5,isSpecial=0},{p35=1,index=6,isSpecial=0},},},
                    [3]={o={{a10073=1,index=1,isSpecial=1},{a10073=5,index=2,isSpecial=1},},p={{p413=2,index=3,isSpecial=1},{p413=10,index=4,isSpecial=1},{p1=1,index=5,isSpecial=1},{p19=10,index=6,isSpecial=0},},},
                    [4]={o={{a10074=5,index=1,isSpecial=1},{a10074=20,index=2,isSpecial=1},{a10073=5,index=3,isSpecial=1},{a10073=20,index=4,isSpecial=1},},p={{p413=3,index=5,isSpecial=1},{p413=15,index=6,isSpecial=1},},},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {6,8,12,14,9,12,18,21,},
                            {{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},},
                        },
                        [2]={
                            {100},
                            {20,10,10.5,14,21,24.5,},
                            {{"props_p413",1},{"props_p413",5},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},},
                        },
                        [3]={
                            {100},
                            {20,10,30,10,5,25,},
                            {{"troops_a10073",1},{"troops_a10073",5},{"props_p413",2},{"props_p413",10},{"props_p1",1},{"props_p19",10},},
                        },
                        [4]={
                            {100},
                            {20,10,20,10,30,10,},
                            {{"troops_a10074",5},{"troops_a10074",20},{"troops_a10073",5},{"troops_a10073",20},{"props_p413",3},{"props_p413",15},},
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={80,75,70,0},
                },
            },
 
            [5]={    --99式坦克
                sortId=437,
                type=1,
                cost=38,     --不免费时抽1次的金币花费
                version=6,
                mul=10, --10倍连抽
                mulc=10,     --10连抽花费的金币是mulc*cost
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10094={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10093',1},
                        upgradePropConsume={{"p19",1},{"p835",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={   p={ {p32=1,index=1,isSpecial=1},    {p33=1,index=2,isSpecial=1},    {p34=1,index=3,isSpecial=1},    {p35=1,index=4,isSpecial=1},    {p26=1,index=5,isSpecial=0},    {p27=1,index=6,isSpecial=0},    {p28=1,index=7,isSpecial=0},    {p29=1,index=8,isSpecial=0},    },},
                    [2]={   p={ {p835=1,index=1,isSpecial=1},   {p835=5,index=2,isSpecial=1},   {p32=1,index=3,isSpecial=0},    {p33=1,index=4,isSpecial=0},    {p34=1,index=5,isSpecial=0},    {p35=1,index=6,isSpecial=0},            },},
                    [3]={   o={ {a10093=1,index=1,isSpecial=1}, {a10093=5,index=2,isSpecial=1}, },p={   {p835=2,index=3,isSpecial=1},   {p835=10,index=4,isSpecial=1},  {p1=1,index=5,isSpecial=1}, {p19=10,index=6,isSpecial=0},       },},
                    [4]={   o={ {a10094=5,index=1,isSpecial=1}, {a10094=20,index=2,isSpecial=1},    {a10093=5,index=3,isSpecial=1}, {a10093=20,index=4,isSpecial=1},    },p={   {p835=3,index=5,isSpecial=1},   {p835=15,index=6,isSpecial=1},      },},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {   6,  8,  12, 14, 9,  12, 18, 21, },
                            {   {"props_p32",1},    {"props_p33",1},    {"props_p34",1},    {"props_p35",1},    {"props_p26",1},    {"props_p27",1},    {"props_p28",1},    {"props_p29",1},    },
                        },
                        [2]={
                            {100},
                            {   20, 10, 10.5,   14, 21, 24.5,           },
                            {   {"props_p835",1},   {"props_p835",5},   {"props_p32",1},    {"props_p33",1},    {"props_p34",1},    {"props_p35",1},            },
                        },
                        [3]={
                            {100},
                            {   20, 10, 30, 10, 5,  25,         },
                            {   {"troops_a10093",1},    {"troops_a10093",5},    {"props_p835",2},   {"props_p835",10},  {"props_p1",1}, {"props_p19",10},           },
                        },
                        [4]={
                            {100},
                            {   20, 10, 20, 10, 30, 10,         },
                            {   {"troops_a10094",5},    {"troops_a10094",20},   {"troops_a10093",5},    {"troops_a10093",20},   {"props_p835",3},   {"props_p835",15},          },
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={  80, 75, 70, 0},
                },
            },
            [6]={     --萤火虫
                sortId=437,
                type=1,
                version=7,
                cost=38,     --不免费时抽1次的金币花费
                mul=10, --10倍连抽
                mulc=10,     --10连抽花费的金币是mulc*cost
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10114={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10113',1},
                        upgradePropConsume={{"p19",1},{"p836",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={   p={ {p32=1,index=1,isSpecial=1},    {p33=1,index=2,isSpecial=1},    {p34=1,index=3,isSpecial=1},    {p35=1,index=4,isSpecial=1},    {p26=1,index=5,isSpecial=0},    {p27=1,index=6,isSpecial=0},    {p28=1,index=7,isSpecial=0},    {p29=1,index=8,isSpecial=0},    },},
                    [2]={   p={ {p836=1,index=1,isSpecial=1},   {p836=5,index=2,isSpecial=1},   {p32=1,index=3,isSpecial=0},    {p33=1,index=4,isSpecial=0},    {p34=1,index=5,isSpecial=0},    {p35=1,index=6,isSpecial=0},            },},
                    [3]={   o={ {a10113=1,index=1,isSpecial=1}, {a10113=5,index=2,isSpecial=1}, },p={   {p836=2,index=3,isSpecial=1},   {p836=10,index=4,isSpecial=1},  {p1=1,index=5,isSpecial=1}, {p19=10,index=6,isSpecial=0},       },},
                    [4]={   o={ {a10114=5,index=1,isSpecial=1}, {a10114=20,index=2,isSpecial=1},    {a10113=5,index=3,isSpecial=1}, {a10113=20,index=4,isSpecial=1},    },p={   {p836=3,index=5,isSpecial=1},   {p836=15,index=6,isSpecial=1},      },},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {   6,  8,  12, 14, 9,  12, 18, 21, },
                            {   {"props_p32",1},    {"props_p33",1},    {"props_p34",1},    {"props_p35",1},    {"props_p26",1},    {"props_p27",1},    {"props_p28",1},    {"props_p29",1},    },
                        },
                        [2]={
                            {100},
                            {   20, 10, 10.5,   14, 21, 24.5,           },
                            {   {"props_p836",1},   {"props_p836",5},   {"props_p32",1},    {"props_p33",1},    {"props_p34",1},    {"props_p35",1},            },
                        },
                        [3]={
                            {100},
                            {   20, 10, 30, 10, 5,  25,         },
                            {   {"troops_a10113",1},    {"troops_a10113",5},    {"props_p836",2},   {"props_p836",10},  {"props_p1",1}, {"props_p19",10},           },
                        },
                        [4]={
                            {100},
                            {   20, 10, 20, 10, 30, 10,         },
                            {   {"troops_a10114",5},    {"troops_a10114",20},   {"troops_a10113",5},    {"troops_a10113",20},   {"props_p836",3},   {"props_p836",15},          },
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={  80, 75, 70, 0},
                },
            },
            [7]={    --虎II式坦克
                sortId=437,
                type=1,
                cost=38,     --不免费时抽1次的金币花费
                version=8,
                mul=10, --10倍连抽
                mulc=10,     --10连抽花费的金币是mulc*cost
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                    a10124={--目标坦克,以下为改装需要的道具，参考tank的conf
                        upgradeMetalConsume=1880000,
                        upgradeOilConsume=1880000,
                        upgradeSiliconConsume=1880000,
                        upgradeUraniumConsume=1180000,
                        upgradeMoneyConsume=0,
                        upgradeShipConsume={'a10123',1},
                        upgradePropConsume={{"p19",1},{"p837",1},},
                    },
                },
                --前段说明显示
                rewardlist={
                    [1]={   p={ {p32=1,index=1,isSpecial=1},    {p33=1,index=2,isSpecial=1},    {p34=1,index=3,isSpecial=1},    {p35=1,index=4,isSpecial=1},    {p26=1,index=5,isSpecial=0},    {p27=1,index=6,isSpecial=0},    {p28=1,index=7,isSpecial=0},    {p29=1,index=8,isSpecial=0},    },},
                    [2]={   p={ {p837=1,index=1,isSpecial=1},   {p837=5,index=2,isSpecial=1},   {p32=1,index=3,isSpecial=0},    {p33=1,index=4,isSpecial=0},    {p34=1,index=5,isSpecial=0},    {p35=1,index=6,isSpecial=0},            },},
                    [3]={   o={ {a10123=1,index=1,isSpecial=1}, {a10123=5,index=2,isSpecial=1}, },p={   {p837=2,index=3,isSpecial=1},   {p837=10,index=4,isSpecial=1},  {p1=1,index=5,isSpecial=1}, {p19=10,index=6,isSpecial=0},       },},
                    [4]={   o={ {a10124=5,index=1,isSpecial=1}, {a10124=20,index=2,isSpecial=1},    {a10123=5,index=3,isSpecial=1}, {a10123=20,index=4,isSpecial=1},    },p={   {p837=3,index=5,isSpecial=1},   {p837=15,index=6,isSpecial=1},      },},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {   6,  8,  12, 14, 9,  12, 18, 21, },
                            {   {"props_p32",1},    {"props_p33",1},    {"props_p34",1},    {"props_p35",1},    {"props_p26",1},    {"props_p27",1},    {"props_p28",1},    {"props_p29",1},    },
                        },
                        [2]={
                            {100},
                            {   20, 10, 10.5,   14, 21, 24.5,           },
                            {   {"props_p837",1},   {"props_p837",5},   {"props_p32",1},    {"props_p33",1},    {"props_p34",1},    {"props_p35",1},            },
                        },
                        [3]={
                            {100},
                            {   20, 10, 30, 10, 5,  25,         },
                            {   {"troops_a10123",1},    {"troops_a10123",5},    {"props_p837",2},   {"props_p837",10},  {"props_p1",1}, {"props_p19",10},           },
                        },
                        [4]={
                            {100},
                            {   20, 10, 20, 10, 30, 10,         },
                            {   {"troops_a10124",5},    {"troops_a10124",20},   {"troops_a10123",5},    {"troops_a10123",20},   {"props_p837",3},   {"props_p837",15},          },
                        },
                    },
                    --能够成功探索下一个奖池的概率
                    vate={  80, 75, 70, 0},
                },
            },

        },

        -- 回炉再造
        huiluzaizao={
            multiSelectType=true,
            [1]={
                sortId=437,
                type=1,
                cost=38, --不免费时抽1次的金币花费
                mul=10,--10倍连抽
                mulc=10, --10连抽花费的金币是mulc*cost
                version=1,
                vipCost={
                    --{vip等级， 消耗的金币， 取第四个奖池, 每日次数限制}
                    {{0,0},128,4,0},
                    {{1,1},128,4,1},
                    {{2,2},128,4,2},
                    {{3,3},128,4,3},
                    {{4,4},128,4,4},
                    {{5,5},128,4,5},
                    {{6,6},128,4,6},
                    {{7,7},128,4,7},
                    {{8,8},128,4,8},
                    {{9,9},128,4,9},
                    {{10,10},128,4,10},
                    {{11,11},128,4,11},
                    {{12,12},128,4,12},
                    {{13,13},128,4,13},
                },
                consume={
                        {--目标坦克 A型 萤火虫坦克，升级
                            upgradeMetalConsume=1880000,
                            upgradeOilConsume=1880000,
                            upgradeSiliconConsume=1880000,
                            upgradeUraniumConsume=1180000,
                            upgradeMoneyConsume=0,
                            upgradeShipConsume={'a10113',1},
                            upgradePropConsume={{"p19",1},{"p836",1},},
                            TransShipConsume={'a10114',1},
                        },
                        {----目标坦克 B型 萤火虫坦克，升级
                            upgradeMetalConsume=1880000,
                            upgradeOilConsume=1880000,
                            upgradeSiliconConsume=1880000,
                            upgradeUraniumConsume=1180000,
                            upgradeMoneyConsume=0,
                            upgradeShipConsume={'a10113',1},
                            upgradePropConsume={{"p19",1},{"p836",1},},
                            TransShipConsume={'a20114',1},
                        },
                        {----目标坦克 A型 萤火虫坦克，改造
                            upgradeShipConsume={'a20114',1},
                            upgradePropConsume={{"p19",1}},
                            TransShipConsume={'a10114',1},
                        },
                        {----目标坦克 B型 萤火虫坦克，改造
                            upgradeShipConsume={'a10114',1},
                            upgradePropConsume={{"p19",1}},
                            TransShipConsume={'a20114',1},
                        },
                },
                --前段说明显示
                rewardlist={
                    [1]={p={{p32=1,index=1,isSpecial=1},{p33=1,index=2,isSpecial=1},{p34=1,index=3,isSpecial=1},{p35=1,index=4,isSpecial=1},{p26=1,index=5,isSpecial=0},{p27=1,index=6,isSpecial=0},{p28=1,index=7,isSpecial=0},{p29=1,index=8,isSpecial=0},},},
                    [2]={p={{p836=1,index=1,isSpecial=1},{p836=5,index=2,isSpecial=1},{p32=1,index=3,isSpecial=0},{p33=1,index=4,isSpecial=0},{p34=1,index=5,isSpecial=0},{p35=1,index=6,isSpecial=0},},},
                    [3]={o={{a10113=1,index=1,isSpecial=1},{a10113=5,index=2,isSpecial=1},},p={{p836=2,index=3,isSpecial=1},{p836=10,index=4,isSpecial=1},{p1=1,index=5,isSpecial=1},{p19=10,index=6,isSpecial=0},},},
                    [4]={o={{a10114=5,index=1,isSpecial=1},{a10114=20,index=2,isSpecial=1},{a10113=5,index=3,isSpecial=1},{a10113=20,index=4,isSpecial=1},},p={{p836=3,index=5,isSpecial=1},{p836=15,index=6,isSpecial=1},},},
                },
                serverreward={
                    --四个奖池
                    pool={
                        [1]={
                            {100},
                            {6,8,12,14,9,12,18,21,},
                            {{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},},
                            },
                        [2]={
                            {100},
                            {20,10,10.5,14,21,24.5,},
                            {{"props_p836",1},{"props_p836",5},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},},
                        },
                        [3]={
                            {100},
                            {20,10,30,10,5,25,},
                            {{"troops_a10113",1},{"troops_a10113",5},{"props_p836",2},{"props_p836",10},{"props_p1",1},{"props_p19",10},},
                        },
                        [4]={
                            {100},
                            {20,10,20,10,30,10,},
                            {{"troops_a10114",5},{"troops_a10114",20},{"troops_a10113",5},{"troops_a10113",20},{"props_p836",3},{"props_p836",15},},
                        },
                    },
                                --能够成功探索下一个奖池的概率
                                vate={80,75,70,0},
                    },
            },






        },
        --狂怒之师
        kuangnuzhishi={
            sortId=467,
            type=1,
            cost=38, --不免费时抽1次的金币花费
            mul=10, --10连抽
            mulc=9, --10连抽花费的金币是mulc*cost
            --本服电影票限制，后台运营配置
            limit=0, --由管理工具配置
            --抽奖配置 isSpecial 1发公告 score 狂怒点 最小， 最大值
            rewardlist={
                o={{a10113=1,index=1,isPecial=1,score={27,49}},{a10123=1,index=3,isPecial=1,score={27,49}},{a10113=3,index=7,isPecial=1,score={80,148}},{a10123=3,index=9,isPecial=1,score={80,148}},},p={{p12=1,index=2,isPecial=0,score={27,49}},{p11=1,index=4,isPecial=0,score={27,49}},{p19=2,index=6,isPecial=0,score={34,62}},{p277=5,index=8,isPecial=0,score={42,78}},{p677=1,index=5,isPecial=1,score={140,260}},
                },
            },
            --多少积分可以上榜
            scoreLimit=3000,
            --榜单显示几条
            ranklimit=10,
            --排名奖励
            rankReward={
                {{1,1},{o={{a10113=0.5,index=1},{a10123=0.5,index=2},},}},
                {{2,2},{o={{a10113=0.35,index=1},{a10123=0.35,index=2},},}},
                {{3,3},{o={{a10113=0.25,index=1},{a10123=0.25,index=2},},}},
                {{4,5},{o={{a10113=0.15,index=1},{a10123=0.15,index=2},},}},
                {{6,10},{o={{a10113=0.1,index=1},{a10123=0.1,index=2},},}},
            },
            serverreward={
                pool={
                    {100},
                    {24,30,6,8,8,8,8,8,},
                    --道具id  {道具数量，{狂怒点最小值，最大值}}
                    {{"troops_a10113",{1,{27,49}}},{"troops_a10123",{1,{27,49}}},{"troops_a10113",{3,{80,148}}},{"troops_a10123",{3,{80,148}}},{"props_p12",{1,{27,49}}},{"props_p11",{1,{27,49}}},{"props_p19",{2,{34,62}}},{"props_p277",{5,{42,78}}},},
                },
                --抽到电影票概率0.1%
                vate=0.1,
                --每个人最多抽到几张电影票
                aperson=1,
                --电影票对应的 礼包id = 礼包数量 狂怒点最小值，最大值
                movie={props_p677={1,{100,100}}},
                --可以抽取到电影票的渠道
                appid={1011,1016,12715,11315,10213,10313,10413,10613,10113},
                --排名奖励
                rankReward={
                    {{1,1},{troops_a10113=0.5,troops_a10123=0.5,}},
                    {{2,2},{troops_a10113=0.35,troops_a10123=0.35,}},
                    {{3,3},{troops_a10113=0.25,troops_a10123=0.25,}},
                    {{4,5},{troops_a10113=0.15,troops_a10123=0.15,}},
                    {{6,10},{troops_a10113=0.1,troops_a10123=0.1,}},
                },
            },
        },

        --飞流_真情反馈
        zhenqinghuikui={
            multiSelectType=true,
            --iphone plus
            [1] = {
                type=1,
                sortId=477,
                version=1,
                --f1={11:00-12:00, 18:00-19:00} 每天可以获取免费次数的俩个时间段
                startTime={
                    {{11,00},{12,0}},
                    {{18,00},{19,0}},
                },
                activeTitle="真情回馈",
                gamename="112233",
                --mm实物奖励
                showlist={
                    p={{p20=1,index=1}, {p19=3,index=2},    {p12=1,index=3},    {p11=1,index=5},    {p47=1,index=6},    {p2=1,index=7}, {p89=1,index=9},    {p15=1,index=10},   {p5=1,index=11},},
                    mm={{m1=1,index=4},{m2=1,index=8},{m3=1,index=12}},
                },
                --goldNum 获取一次抽奖机会的条件 每充值满200金币 可获得一次奖励机会
                goldNum=200,
                --自定义道具名称
                rewardtype={"iphone6","小王子","小公主"},
                serverreward={
                    --抽到实物奖励的概率 20%
                    vate=20,
                    --共12个  这里配9个虚拟道具 其他自定义配置
                    pool={
                        {100},
                        {20,    20, 15, 15, 10, 3,  2,  10, 5,},
                        {{"props_p20",1},   {"props_p19",3},    {"props_p12",1},    {"props_p11",1},    {"props_p47",1},    {"props_p2",1}, {"props_p89",1},    {"props_p15",1},    {"props_p5",1},},
                    },
                },
            },
            --京东礼品卡
            [2] = {
                type=1,
                sortId=477,
                version=2,
                activeTitle="真情回馈",
                gamename="112233",
                --f1={11:00-12:00, 18:00-19:00} 每天可以获取免费次数的俩个时间段
                startTime={
                    {{11,00},{12,0}},
                    {{18,00},{19,0}},
                },
                --mm实物奖励
                showlist={
                    p={{p20=1,index=1},{p19=3,index=3},{p12=1,index=5},{p11=1,index=7},{p47=1,index=9},{p2=1,index=11},{p89=1,index=2},{p15=1,index=4},{p5=1,index=6},{p17=1,index=8},{p18=1,index=10},},
                    mm={{m1=1,index=12},},
                },
                --goldNum 获取一次抽奖机会的条件 每充值满200金币 可获得一次奖励机会
                goldNum=200,
                --自定义道具名称
                rewardtype={"京东代金卷50元"},
                serverreward={
                    --抽到实物奖励的概率 20%
                    vate=20,
                    --共12个  这里配11个虚拟道具 其他自定义配置
                    pool={
                        {100},
                        {20,20,15,15,10,3,3,5,3,3,3,},
                        {{"props_p20",1},{"props_p19",3},{"props_p12",1},{"props_p11",1},{"props_p47",1},{"props_p2",1},{"props_p89",1},{"props_p15",1},{"props_p5",1},{"props_p17",1},{"props_p18",1},},
                    },
                },
            },
            --京东礼品卡 春节版本
            [3] = {
                type=1,
                sortId=477,
                version=3,
                activeTitle="真情回馈",
                gamename="112233",
                --f1={11:00-12:00, 18:00-19:00} 每天可以获取免费次数的俩个时间段
                startTime={
                    {{11,00},{12,0}},
                    {{18,00},{19,0}},
                },
                --mm实物奖励
                showlist={
                    p={{p20=1,index=1},{p19=3,index=3},{p12=1,index=5},{p11=1,index=7},{p47=1,index=9},{p2=1,index=11},{p89=1,index=2},{p15=1,index=4},{p5=1,index=6},{p17=1,index=8},{p18=1,index=10},},
                    mm={{m1=1,index=12},},
                },
                --goldNum 获取一次抽奖机会的条件 每充值满200金币 可获得一次奖励机会
                goldNum=200,
                --自定义道具名称
                rewardtype={"京东代金卷50元"},
                serverreward={
                    --抽到实物奖励的概率 20%
                    vate=20,
                    --共12个  这里配11个虚拟道具 其他自定义配置
                    pool={
                        {100},
                        {20,20,15,15,10,3,3,5,3,3,3,},
                        {{"props_p20",1},{"props_p19",3},{"props_p12",1},{"props_p11",1},{"props_p47",1},{"props_p2",1},{"props_p89",1},{"props_p15",1},{"props_p5",1},{"props_p17",1},{"props_p18",1},},
                    },
                },
            },
            --大波京东代金券
            [4] = {
                type=1,
                sortId=477,
                version=4,
                activeTitle="真情回馈",
                gamename="112233",
                --f1={11:00-12:00, 18:00-19:00} 每天可以获取免费次数的俩个时间段
                startTime={
                    {{11,00},{12,0}},
                    {{18,00},{19,0}},
                },
                --mm实物奖励
                showlist={
                    p={{p20=1,index=1},{p19=3,index=3},{p12=1,index=5},{p11=1,index=7},{p47=1,index=9},{p2=1,index=11},{p89=1,index=2},{p15=1,index=4},{p5=1,index=6},{p17=1,index=8},{p18=1,index=10},},
                    mm={{m1=1,index=12},},
                },
                --goldNum 获取一次抽奖机会的条件 每充值满200金币 可获得一次奖励机会
                goldNum=200,
                --自定义道具名称
                rewardtype={"京东代金卷50元"},
                serverreward={
                    --抽到实物奖励的概率 20%
                    vate=20,
                    --共12个  这里配11个虚拟道具 其他自定义配置
                    pool={
                        {100},
                        {20,20,15,15,10,3,3,5,3,3,3,},
                        {{"props_p20",1},{"props_p19",3},{"props_p12",1},{"props_p11",1},{"props_p47",1},{"props_p2",1},{"props_p89",1},{"props_p15",1},{"props_p5",1},{"props_p17",1},{"props_p18",1},},
                    },
                },
            },
            --大波电影票
            [5] = {
                type=1,
                sortId=477,
                version=5,
                activeTitle="真情回馈",
                gamename="112233",
                --f1={11:00-12:00, 18:00-19:00} 每天可以获取免费次数的俩个时间段
                startTime={
                    {{11,00},{12,0}},
                    {{18,00},{19,0}},
                },
                --mm实物奖励
                showlist={
                    p={{p20=1,index=1},{p19=3,index=3},{p12=1,index=5},{p11=1,index=7},{p47=1,index=9},{p2=1,index=11},{p89=1,index=2},{p15=1,index=4},{p5=1,index=6},{p17=1,index=8},{p18=1,index=10},},
                    mm={{m1=1,index=12},},
                },
                --goldNum 获取一次抽奖机会的条件 每充值满200金币 可获得一次奖励机会
                goldNum=200,
                --自定义道具名称
                rewardtype={"京东代金卷50元"},
                serverreward={
                    --抽到实物奖励的概率 20%
                    vate=20,
                    --共12个  这里配11个虚拟道具 其他自定义配置
                    pool={
                        {100},
                        {20,20,15,15,10,3,3,5,3,3,3,},
                        {{"props_p20",1},{"props_p19",3},{"props_p12",1},{"props_p11",1},{"props_p47",1},{"props_p2",1},{"props_p89",1},{"props_p15",1},{"props_p5",1},{"props_p17",1},{"props_p18",1},},
                    },
                },
            },
            --大波京东代金券、电影票
            [6] = {
                type=1,
                sortId=477,
                version=6,
                activeTitle="真情回馈",
                gamename="112233",
                --f1={11:00-12:00, 18:00-19:00} 每天可以获取免费次数的俩个时间段
                startTime={
                    {{11,00},{12,0}},
                    {{18,00},{19,0}},
                },
                --mm实物奖励
                showlist={
                    p={{p20=1,index=1},{p19=3,index=3},{p12=1,index=5},{p11=1,index=7},{p47=1,index=9},{p2=1,index=11},{p89=1,index=2},{p15=1,index=4},{p5=1,index=6},{p17=1,index=8},},
                    mm={{m1=1,index=12},{m2=1,index=10},},
                },
                --goldNum 获取一次抽奖机会的条件 每充值满200金币 可获得一次奖励机会
                goldNum=200,
                --自定义道具名称
                rewardtype={"京东代金卷50元", "电影票"},
                serverreward={
                    --抽到实物奖励的概率 20%
                    vate=20,
                    --共12个  这里配11个虚拟道具 其他自定义配置
                    pool={
                        {100},
                        {20,20,15,15,10,3,3,5,3,3},
                        {{"props_p20",1},{"props_p19",3},{"props_p12",1},{"props_p11",1},{"props_p47",1},{"props_p2",1},{"props_p89",1},{"props_p15",1},{"props_p5",1},{"props_p17",1}},
                    },
                },
            },
        },

                --圣诞宝藏
        shengdanbaozang={
            multiSelectType=true,
            [1]={ -- 1-4配件 以及 5-6配件
                sortId = 447,
                type =1,
                version=1,
                --每次随机选几个
                selectNum=6,
                --不免费时抽1次的金币花费
                cost=38,
                --挖掘全部需要消耗的金币
                allCost=498,
                --展示的道具
                showlist={p={{p230=1,index=1},{p90=1,index=2},{p270=1,index=3},},},
                --商店配置 mm_m1 糖果棒 num糖果棒的数量
                shopItem={
                    {id="i1",buynum=100,price={mm_m1=1},reward={p={{p19=5}}},serverReward={props_p19=5}},
                    {id="i2",buynum=1,price={mm_m1=50},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i3",buynum=1,price={mm_m1=150},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i4",buynum=1,price={mm_m1=350},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i5",buynum=50,price={mm_m1=2},reward={e={{p1=1}}},serverReward={accessory_p1=1}},
                    {id="i6",buynum=50,price={mm_m1=2},reward={e={{p2=2}}},serverReward={accessory_p2=2}},
                    {id="i7",buynum=100,price={mm_m1=2},reward={e={{p3=5}}},serverReward={accessory_p3=5}},
                    {id="i8",buynum=1,price={mm_m1=80},reward={p={{p90=1}}},serverReward={props_p90=1}},
                    {id="i9",buynum=20,price={mm_m1=1},reward={p={{p572=1}}},serverReward={props_p572=1}},
                    {id="i10",buynum=20,price={mm_m1=1},reward={p={{p573=1}}},serverReward={props_p573=1}},
                    {id="i11",buynum=20,price={mm_m1=1},reward={p={{p574=1}}},serverReward={props_p574=1}},
                    {id="i12",buynum=20,price={mm_m1=1},reward={p={{p575=1}}},serverReward={props_p575=1}},
                },
                --可以抽四次
                allowNum=4,
                serverreward={
                    --大小奖池分别抽取
                    smallPool={
                        {0,0,0,0,100},
                        {10,10,8,8,8,8,8,8,8,8,8,8,},
                        {{"mm_m1",1},{"mm_m1",2},{"props_p20",1},{"props_p36",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"accessory_p3",5},{"accessory_p3",10},{"accessory_p2",2},{"accessory_p1",1},},
                    },
                    bigPool={
                        {100},
                        {57,35,40,30,15,1,20,2,9,1,},
                        {{"mm_m1",5},{"mm_m1",10},{"accessory_p3",50},{"accessory_p2",10},{"accessory_p1",5},{"props_p230",1},{"props_p89",1},{"props_p90",1},{"props_p269",1},{"props_p270",1},},
                    },
                    --从大奖池抽取几个
                    bigNum=1,
                    --从第几个位置开始叉
                    insertlocation=4,
                },
            },

				[2]={
				sortId = 447,
				type =1,
				version=2,
				 --每次随机选几个
				selectNum=6,
				 --不免费时抽1次的金币花费
				cost=38,
				 --挖掘全部需要消耗的金币
				allCost=498,
				 --展示的道具
				showlist={p={{p230=1,index=1},{p90=1,index=2},{p270=1,index=3}},},
				 --商店配置 mm_m1 糖果棒 num糖果棒的数量
								shopItem={
				{id="i1",buynum=100,price={mm_m1=1},reward={p={{p19=5}}},serverReward={props_p19=5}},
				{id="i2",buynum=1,price={mm_m1=50},reward={p={{p230=1}}},serverReward={props_p230=1}},
				{id="i3",buynum=1,price={mm_m1=150},reward={p={{p230=1}}},serverReward={props_p230=1}},
				{id="i4",buynum=1,price={mm_m1=350},reward={p={{p230=1}}},serverReward={props_p230=1}},
				{id="i5",buynum=50,price={mm_m1=2},reward={e={{p1=1}}},serverReward={accessory_p1=1}},
				{id="i6",buynum=50,price={mm_m1=2},reward={e={{p2=2}}},serverReward={accessory_p2=2}},
				{id="i7",buynum=100,price={mm_m1=2},reward={e={{p3=5}}},serverReward={accessory_p3=5}},
				{id="i8",buynum=1,price={mm_m1=50},reward={p={{p90=1}}},serverReward={props_p90=1}},
				{id="i9",buynum=20,price={mm_m1=1},reward={p={{p1409=1}}},serverReward={props_p1409=1}},
				{id="i10",buynum=20,price={mm_m1=1},reward={p={{p1410=1}}},serverReward={props_p1410=1}},
				{id="i11",buynum=20,price={mm_m1=1},reward={p={{p1411=1}}},serverReward={props_p1411=1}},
				{id="i12",buynum=20,price={mm_m1=1},reward={p={{p1412=1}}},serverReward={props_p1412=1}},
				},
				 --可以抽四次
				allowNum=4,
				serverreward={
				 --大小奖池分别抽取
				smallPool={
				{0,0,0,0,100},
				{10,10,8,8,8,8,8,8,8,8,8,8,},
				{{"mm_m1",1},{"mm_m1",2},{"props_p20",1},{"alien_r1",400},{"alien_r2",200},{"alien_r4",10},{"alien_r5",40},{"alien_r6",5},{"accessory_p3",5},{"accessory_p3",10},{"accessory_p2",2},{"accessory_p1",1},},
				},
				bigPool={
				{100},
				{57,35,40,30,15,1,20,2,9,1,},
				{{"mm_m1",5},{"mm_m1",10},{"accessory_p3",50},{"accessory_p2",10},{"accessory_p1",5},{"props_p230",1},{"props_p89",1},{"props_p90",1},{"props_p269",1},{"props_p270",1},},
				},

											

				 --从大奖池抽取几个
				bigNum=1,
				 --从第几个位置开始叉
				insertlocation=4,
				},
				},
            --3:   投放1-4配置 非圣诞节界面版本
            [3]={ -- 1-4配件 以及 5-6配件
                sortId = 447,
                type =1,
                version=3,
                --每次随机选几个
                selectNum=6,
                --不免费时抽1次的金币花费
                cost=38,
                --挖掘全部需要消耗的金币
                allCost=498,
                --展示的道具
                showlist={p={{p230=1,index=1},{p90=1,index=2},{p270=1,index=3},},},
                --商店配置 mm_m1 糖果棒 num糖果棒的数量
                shopItem={
                    {id="i1",buynum=100,price={mm_m1=1},reward={p={{p19=5}}},serverReward={props_p19=5}},
                    {id="i2",buynum=1,price={mm_m1=50},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i3",buynum=1,price={mm_m1=150},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i4",buynum=1,price={mm_m1=350},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i5",buynum=50,price={mm_m1=2},reward={e={{p1=1}}},serverReward={accessory_p1=1}},
                    {id="i6",buynum=50,price={mm_m1=2},reward={e={{p2=2}}},serverReward={accessory_p2=2}},
                    {id="i7",buynum=100,price={mm_m1=2},reward={e={{p3=5}}},serverReward={accessory_p3=5}},
                    {id="i8",buynum=1,price={mm_m1=80},reward={p={{p90=1}}},serverReward={props_p90=1}},
                    {id="i9",buynum=20,price={mm_m1=1},reward={p={{p572=1}}},serverReward={props_p572=1}},
                    {id="i10",buynum=20,price={mm_m1=1},reward={p={{p573=1}}},serverReward={props_p573=1}},
                    {id="i11",buynum=20,price={mm_m1=1},reward={p={{p574=1}}},serverReward={props_p574=1}},
                    {id="i12",buynum=20,price={mm_m1=1},reward={p={{p575=1}}},serverReward={props_p575=1}},
                },
                --可以抽四次
                allowNum=4,
                serverreward={
                    --大小奖池分别抽取
                    smallPool={
                        {0,0,0,0,100},
                        {10,10,8,8,8,8,8,8,8,8,8,8,},
                        {{"mm_m1",1},{"mm_m1",2},{"props_p20",1},{"props_p36",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"accessory_p3",5},{"accessory_p3",10},{"accessory_p2",2},{"accessory_p1",1},},
                    },
                    bigPool={
                        {100},
                        {57,35,40,30,15,1,20,2,9,1,},
                        {{"mm_m1",5},{"mm_m1",10},{"accessory_p3",50},{"accessory_p2",10},{"accessory_p1",5},{"props_p230",1},{"props_p89",1},{"props_p90",1},{"props_p269",1},{"props_p270",1},},
                    },
                    --从大奖池抽取几个
                    bigNum=1,
                    --从第几个位置开始叉
                    insertlocation=4,
                },
            },
            --4:   投放1-6配置 非圣诞节界面版本
            [4]={ -- 1-4配件
                sortId = 447,
                type =1,
                version=4,
                --每次随机选几个
                selectNum=6,
                --不免费时抽1次的金币花费
                cost=38,
                --挖掘全部需要消耗的金币
                allCost=498,
                --展示的道具
                showlist={p={{p230=1,index=1},{p90=1,index=2}}},

                --商店配置 mm_m1 糖果棒 num糖果棒的数量
                shopItem={
                    {id="i1",buynum=100,price={mm_m1=1},reward={p={{p19=5}}},serverReward={props_p19=5}},
                    {id="i2",buynum=1,price={mm_m1=50},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i3",buynum=1,price={mm_m1=150},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i4",buynum=1,price={mm_m1=350},reward={p={{p230=1}}},serverReward={props_p230=1}},
                    {id="i5",buynum=50,price={mm_m1=2},reward={e={{p1=1}}},serverReward={accessory_p1=1}},
                    {id="i6",buynum=50,price={mm_m1=2},reward={e={{p2=2}}},serverReward={accessory_p2=2}},
                    {id="i7",buynum=100,price={mm_m1=2},reward={e={{p3=5}}},serverReward={accessory_p3=5}},
                    {id="i8",buynum=1,price={mm_m1=80},reward={p={{p90=1}}},serverReward={props_p90=1}},
                    {id="i9",buynum=20,price={mm_m1=1},reward={p={{p572=1}}},serverReward={props_p572=1}},
                    {id="i10",buynum=20,price={mm_m1=1},reward={p={{p573=1}}},serverReward={props_p573=1}},
                    {id="i11",buynum=20,price={mm_m1=1},reward={p={{p574=1}}},serverReward={props_p574=1}},
                    {id="i12",buynum=20,price={mm_m1=1},reward={p={{p575=1}}},serverReward={props_p575=1}},
                },
                --可以抽四次
                allowNum=4,
                serverreward={
                    --大小奖池分别抽取
                    smallPool={
                        {0,0,0,0,100},
                        {10,10,8,8,8,8,8,8,8,8,8,8,},
                        {{"mm_m1",1},{"mm_m1",2},{"props_p20",1},{"props_p36",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"accessory_p3",5},{"accessory_p3",10},{"accessory_p2",2},{"accessory_p1",1},},
                    },
                    bigPool={
                        {100},
                        {57,35,40,30,15,1,20,2,},
                        {{"mm_m1",5},{"mm_m1",10},{"accessory_p3",50},{"accessory_p2",10},{"accessory_p1",5},{"props_p230",1},{"props_p89",1},{"props_p90",1},},
                    },
                    --从大奖池抽取几个
                    bigNum=1,
                    --从第几个位置开始叉
                    insertlocation=4,
                },
            },												
			 --阿拉伯活动：1-4配件，5.5级船														
			[5]={														
				sortId = 447,													
				type =1,													
				version=5,													
				 --每次随机选几个													
				selectNum=6,													
				 --不免费时抽1次的金币花费													
				cost=38,													
				 --挖掘全部需要消耗的金币													
				allCost=498,													
				 --展示的道具													
				showlist={p={{p230=1,index=1},{p90=1,index=2},},},													
				shopItem={													
					{id="i1",	buynum=100,	price={mm_m1=1},	reward={p={{p19=5}}},	serverReward={props_p19=5}	},
					{id="i2",	buynum=1,	price={mm_m1=50},	reward={p={{p230=1}}},	serverReward={props_p230=1}	},
					{id="i3",	buynum=1,	price={mm_m1=150},	reward={p={{p230=1}}},	serverReward={props_p230=1}	},
					{id="i4",	buynum=1,	price={mm_m1=350},	reward={p={{p230=1}}},	serverReward={props_p230=1}	},
					{id="i5",	buynum=50,	price={mm_m1=2},	reward={e={{p1=1}}},	serverReward={accessory_p1=1}	},
					{id="i6",	buynum=50,	price={mm_m1=2},	reward={e={{p2=2}}},	serverReward={accessory_p2=2}	},
					{id="i7",	buynum=100,	price={mm_m1=2},	reward={e={{p3=5}}},	serverReward={accessory_p3=5}	},
					{id="i8",	buynum=1,	price={mm_m1=80},	reward={p={{p90=1}}},	serverReward={props_p90=1}	},
					{id="i9",	buynum=20,	price={mm_m1=1},	reward={p={{p239=1}}},	serverReward={props_p239=1}	},
					{id="i10",	buynum=20,	price={mm_m1=1},	reward={p={{p240=1}}},	serverReward={props_p240=1}	},
					{id="i11",	buynum=20,	price={mm_m1=1},	reward={p={{p241=1}}},	serverReward={props_p241=1}	},
					{id="i12",	buynum=20,	price={mm_m1=1},	reward={p={{p242=1}}},	serverReward={props_p242=1}	},					
				},													
				 --可以抽四次													
				allowNum=4,													
				serverreward={													
				 --大小奖池分别抽取													
				smallPool={													
				{0,0,0,0,100},													
				{	10,	10,	8,	8,	8,	8,	8,	8,	8,	8,	8,	8,	},
				{	{"mm_m1",1},	{"mm_m1",2},	{"props_p20",1},	{"props_p36",1},	{"props_p32",1},	{"props_p33",1},	{"props_p34",1},	{"props_p35",1},	{"accessory_p3",5},	{"accessory_p3",10},	{"accessory_p2",2},	{"accessory_p1",1},	},
				},													
				bigPool={													
				{100},													
				{	57,	35,	40,	30,	15,	1,	20,	2,			},		
				{	{"mm_m1",5},	{"mm_m1",10},	{"accessory_p3",50},	{"accessory_p2",10},	{"accessory_p1",5},	{"props_p230",1},	{"props_p89",1},	{"props_p90",1},			},		
				},													
				 --从大奖池抽取几个													
				bigNum=1,													
				 --从第几个位置开始叉													
				insertlocation=4,													
				},													
			},														
			 --阿拉伯活动：5、6配件 6.5级船														
			[6]={														
				sortId = 447,													
				type =1,													
				version=6,													
				 --每次随机选几个													
				selectNum=6,													
				 --不免费时抽1次的金币花费													
				cost=38,													
				 --挖掘全部需要消耗的金币													
				allCost=498,													
				 --展示的道具													
				showlist={p={{p230=1,index=1},{p90=1,index=2},{p270=1,index=3},},},													
								shopItem={													
				{id="i1",	buynum=100,	price={mm_m1=1},	reward={p={{p19=5}}},	serverReward={props_p19=5}	},								
				{id="i2",	buynum=1,	price={mm_m1=50},	reward={p={{p230=1}}},	serverReward={props_p230=1}	},								
				{id="i3",	buynum=1,	price={mm_m1=150},	reward={p={{p230=1}}},	serverReward={props_p230=1}	},								
				{id="i4",	buynum=1,	price={mm_m1=350},	reward={p={{p230=1}}},	serverReward={props_p230=1}	},								
				{id="i5",	buynum=50,	price={mm_m1=2},	reward={e={{p1=1}}},	serverReward={accessory_p1=1}	},								
				{id="i6",	buynum=50,	price={mm_m1=2},	reward={e={{p2=2}}},	serverReward={accessory_p2=2}	},								
				{id="i7",	buynum=100,	price={mm_m1=2},	reward={e={{p3=5}}},	serverReward={accessory_p3=5}	},								
				{id="i8",	buynum=1,	price={mm_m1=80},	reward={p={{p90=1}}},	serverReward={props_p90=1}	},								
				{id="i9",	buynum=20,	price={mm_m1=1},	reward={p={{p820=1}}},	serverReward={props_p820=1}	},								
				{id="i10",	buynum=20,	price={mm_m1=1},	reward={p={{p821=1}}},	serverReward={props_p821=1}	},								
				{id="i11",	buynum=20,	price={mm_m1=1},	reward={p={{p822=1}}},	serverReward={props_p822=1}	},								
				{id="i12",	buynum=20,	price={mm_m1=1},	reward={p={{p823=1}}},	serverReward={props_p823=1}	},								
				},													
				 --可以抽四次													
				allowNum=4,													
				serverreward={													
				 --大小奖池分别抽取													
				smallPool={													
				{0,0,0,0,100},													
				{	10,	10,	8,	8,	8,	8,	8,	8,	8,	8,	8,	8,	},
				{	{"mm_m1",1},	{"mm_m1",2},	{"props_p20",1},	{"props_p36",1},	{"props_p32",1},	{"props_p33",1},	{"props_p34",1},	{"props_p35",1},	{"accessory_p3",5},	{"accessory_p3",10},	{"accessory_p2",2},	{"accessory_p1",1},	},
				},													
				bigPool={													
				{100},													
				{	565,	350,	400,	300,	150,	10,	200,	25,	90,	5,			},
				{	{"mm_m1",5},	{"mm_m1",10},	{"accessory_p3",50},	{"accessory_p2",10},	{"accessory_p1",5},	{"props_p230",1},	{"props_p89",1},	{"props_p90",1},	{"props_p269",1},	{"props_p270",1},			},
				},													
				 --从大奖池抽取几个													
				bigNum=1,													
				 --从第几个位置开始叉													
				insertlocation=4,													
				},													
			},														
											

        },

        --圣诞狂欢
        shengdankuanghuan={
            multiSelectType=true,
            [1]={
                sortId=457,
                type=1,
                --充值金币X等于1成长值   
                goldVate=10,
                --10000资源等于1成长值
                resourceVate=2000000,
                --最大值，最小值，返利，前台用
                smallPoint=0.1,
                bigPoint=2,
                --圣诞树奖励（成长树积分条件，可以领取的奖励）
                treeReward={
                    {100000,{p={{p230=1,index=1},},}},
                    {75000,{p={{p19=30,index=1},{p20=5,index=2},},}},
                    {50000,{e={{p1=3,index=1},{p2=5,index=2},{p3=30,index=3},},}},
                    {25000,{p={{p5=1,index=1},{p12=1,index=2},{p11=1,index=3},{p15=1,index=4},},}},
                },
                serverreward={
                    pool={
                        {100},
                        --概率，比例
                        {27,25,20,15,8,4,1,},
                        {0.1,0.15,0.2,0.3,0.5,1,2,},
                    },
                    --圣诞树奖励（成长树积分条件，可以领取的奖励）
                    treeReward={
                        {100000,{props_p230=1,}},
                        {75000,{props_p19=30,props_p20=5,}},
                        {50000,{accessory_p1=3,accessory_p2=5,accessory_p3=30,}},
                        {25000,{props_p5=1,props_p12=1,props_p11=1,props_p15=1,}},
                    },
                },
                goods=1,
            },
            [2]={
                sortId=457,
                type=1,
                --充值金币X等于1成长值
                goldVate=10,
                --10000资源等于1成长值
                resourceVate=2000000,
                --最大值，最小值，返利，前台用
                smallPoint=0.1,
                bigPoint=2,
                --圣诞树奖励（成长树积分条件，可以领取的奖励）
                treeReward={
                    {60000,{p={{p230=1,index=1},},}},
                    {45000,{p={{p19=30,index=1},{p20=5,index=2},},}},
                    {30000,{e={{p1=3,index=1},{p2=5,index=2},{p3=30,index=3},},}},
                    {15000,{p={{p5=1,index=1},{p12=1,index=2},{p11=1,index=3},{p15=1,index=4},},}},
                },
                serverreward={
                    pool={
                        {100},
                        --概率，比例
                        {27,25,20,15,8,4,1,},
                        {0.1,0.15,0.2,0.3,0.5,1,2,},
                    },
                    --圣诞树奖励（成长树积分条件，可以领取的奖励）
                    treeReward={
                        {60000,{props_p230=1,}},
                        {45000,{props_p19=30,props_p20=5,}},
                        {30000,{accessory_p1=3,accessory_p2=5,accessory_p3=30,}},
                        {15000,{props_p5=1,props_p12=1,props_p11=1,props_p15=1,}},
                    },
                },
                goods=1,
            },
        },
        
                --元旦献礼
        yuandanxianli={
            multiSelectType=true,
            [1]={
                type=1,
                sortId=487,
                --每日抽奖免费次数
                freeLottery=1,
                cost=38, --不免费时抽一次的金币花费
                mul=10, --10连抽
                mulc=9, --10连抽花费的金币是mulC*cost
                --黑客修改记录需要的金币数
                rR=388,
                --强化概率提升
                --倍率（最终倍率=基础倍率+基础倍率*successUp+VIP提升倍率）
                successUp=1,
                --每日次数
                freeTime=3,
                --每日充值奖励
                dailyReward={
                    {p={{p20=1,index=1}},e={{p3=10,index=2},{p2=2,index=3},{p1=1,index=4},}},
                    {p={{p20=2,index=1}},e={{p3=20,index=2},{p2=4,index=3},{p1=2,index=4},}},
                    {p={{p20=2,index=1}},e={{p3=20,index=2},{p2=4,index=3},{p1=2,index=4},}},
                    {p={{p20=3,index=1}},e={{p3=30,index=2},{p2=6,index=3},{p1=3,index=4},}},
                    {p={{p20=3,index=1}},e={{p3=30,index=2},{p2=6,index=3},{p1=3,index=4},}},
                    {p={{p20=4,index=1}},e={{p3=40,index=2},{p2=8,index=3},{p1=4,index=4},}},
                    {p={{p20=5,index=1}},e={{p3=50,index=2},{p2=10,index=3},{p1=5,index=4},}},
                },
                --最终奖励
                bigReward={p={{p230=1,index=1}},},
                --抽奖显示
                rewardlist={
                    p={{p393=1,index=1},{p394=1,index=4},{p395=1,index=7},{p396=1,index=10},{p30=1,index=2},{p26=1,index=5},{p27=1,index=8},{p28=1,index=11},{p29=1,index=3},},e={{p3=5,index=6},{p2=1,index=9},{p1=1,index=12},},
                },
                reportList={[1]=10,[4]=10,[7]=10,[10]=10,[2]=10,[5]=10,[8]=10,[11]=10,[3]=10,[6]=20,[9]=20,[12]=50,},
                serverreward={
                    dailyReward={
                        {props_p20=1,accessory_p3=10,accessory_p2=2,accessory_p1=1,},
                        {props_p20=2,accessory_p3=20,accessory_p2=4,accessory_p1=2,},
                        {props_p20=2,accessory_p3=20,accessory_p2=4,accessory_p1=2,},
                        {props_p20=3,accessory_p3=30,accessory_p2=6,accessory_p1=3,},
                        {props_p20=3,accessory_p3=30,accessory_p2=6,accessory_p1=3,},
                        {props_p20=4,accessory_p3=40,accessory_p2=8,accessory_p1=4,},
                        {props_p20=5,accessory_p3=50,accessory_p2=10,accessory_p1=5,},
                    },
                    bigReward={props_p230=1},
                    --抽奖配置
                    pool={
                        {100},
                        {10,10,10,10,5,5,5,5,5,20,10,5,},
                        {{"props_p393",1},{"props_p394",1},{"props_p395",1},{"props_p396",1},{"props_p30",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"accessory_p3",5},{"accessory_p2",1},{"accessory_p1",1},},
                    },
                    --倍数配置
                    numPool={
                        {100},
                        {35,30,25,10,},
                        {1,2,5,10,},
                    },
                },
                colorMap={1,2,5,10,},
                reportNum=100,
            },
            [2]={
                type=1,
                sortId=487,
                --每日抽奖免费次数
                freeLottery=1,
                cost=38, --不免费时抽一次的金币花费
                mul=10, --10连抽
                mulc=9, --10连抽花费的金币是mulC*cost
                --黑客修改记录需要的金币数
                rR=388,
                --强化概率提升
                --倍率（最终倍率=基础倍率+基础倍率*successUp+VIP提升倍率）
                successUp=1,
                --每日次数
                freeTime=3,
                --每日充值奖励
                dailyReward={
                    {p={{p20=1,index=1}},e={{p3=10,index=2},{p2=2,index=3},{p1=1,index=4},}},
                    {p={{p20=2,index=1}},e={{p3=20,index=2},{p2=4,index=3},{p1=2,index=4},}},
                    {p={{p20=2,index=1}},e={{p3=20,index=2},{p2=4,index=3},{p1=2,index=4},}},
                    {p={{p20=3,index=1}},e={{p3=30,index=2},{p2=6,index=3},{p1=3,index=4},}},
                    {p={{p20=3,index=1}},e={{p3=30,index=2},{p2=6,index=3},{p1=3,index=4},}},
                    {p={{p20=4,index=1}},e={{p3=40,index=2},{p2=8,index=3},{p1=4,index=4},}},
                    {p={{p20=5,index=1}},e={{p3=50,index=2},{p2=10,index=3},{p1=5,index=4},}},
                },
                --最终奖励
                bigReward={p={{p230=1,index=1}},},
                --抽奖显示
                rewardlist={
                    o={{a10005=1,index=1},{a10015=1,index=4},{a10025=1,index=7},{a10035=1,index=10},},p={{p30=1,index=2},{p26=1,index=5},{p27=1,index=8},{p28=1,index=11},{p29=1,index=3},},e={{p3=5,index=6},{p2=1,index=9},{p1=1,index=12},},
                },
                reportList={[1]=10,[4]=10,[7]=10,[10]=10,[2]=10,[5]=10,[8]=10,[11]=10,[3]=10,[6]=20,[9]=20,[12]=50,},
                serverreward={
                    dailyReward={
                        {props_p20=1,accessory_p3=10,accessory_p2=2,accessory_p1=1,},
                        {props_p20=2,accessory_p3=20,accessory_p2=4,accessory_p1=2,},
                        {props_p20=2,accessory_p3=20,accessory_p2=4,accessory_p1=2,},
                        {props_p20=3,accessory_p3=30,accessory_p2=6,accessory_p1=3,},
                        {props_p20=3,accessory_p3=30,accessory_p2=6,accessory_p1=3,},
                        {props_p20=4,accessory_p3=40,accessory_p2=8,accessory_p1=4,},
                        {props_p20=5,accessory_p3=50,accessory_p2=10,accessory_p1=5,},
                    },
                    bigReward={props_p230=1},
                    --抽奖配置
                    pool={
                        {100},
                        {10,10,10,10,5,5,5,5,5,20,10,5,},
                        {{"troops_a10005",1},{"troops_a10015",1},{"troops_a10025",1},{"troops_a10035",1},{"props_p30",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"accessory_p3",5},{"accessory_p2",1},{"accessory_p1",1},},
                    },
                    --倍数配置
                    numPool={
                        {100},
                        {40,30,20,10,},
                        {1,2,5,10,},
                    },
                },
                colorMap={1,2,5,10,},
                reportNum=100,
            },


        },

        --坦克嘉年华
        tankjianianhua={
            multiSelectType=true,
            [1]={
                type=1,
                sortId=507,
                --单排抽奖
                cost=48,
                --三排抽奖
                mulCost=328,
                --几种类型的icon
                showicon={
                    ["a1"]={o={{a10043=1,index=1}}},
                    ["a2"]={o={{a10053=1,index=1}}},
                    ["a3"]={o={{a10063=1,index=1}}},
                    ["a4"]={o={{a10073=1,index=1}}},
                    ["a5"]={o={{a10082=1,index=1}}},
                    ["a6"]={o={{a10093=1,index=1}}},
                    ["a7"]={o={{a10113=1,index=1}}},
                    ["a8"]={o={{a10123=1,index=1}}},
                    ["a9"]={u={{gems=1,index=1}}},
                    ["a10"]={u={{gems=1,index=1}}},
                },
                rewardlist={
                    ["a1-3"]={o={a10043=5}},
                    ["a2-3"]={o={a10053=5}},
                    ["a3-3"]={o={a10063=5}},
                    ["a4-3"]={o={a10073=5}},
                    ["a5-3"]={o={a10082=5}},
                    ["a6-3"]={o={a10093=5}},
                    ["a7-3"]={o={a10113=5}},
                    ["a8-3"]={o={a10123=5}},
                    ["a9-3"]={u={gems=200}},
                    ["a10-3"]={u={gems=1000}},
                    ["a1-2"]={o={a10043=1}},
                    ["a2-2"]={o={a10053=1}},
                    ["a3-2"]={o={a10063=1}},
                    ["a4-2"]={o={a10073=1}},
                    ["a5-2"]={o={a10082=1}},
                    ["a6-2"]={o={a10093=1}},
                    ["a7-2"]={o={a10113=1}},
                    ["a8-2"]={o={a10123=1}},
                    ["a9-2"]={u={gems=50}},
                    ["a1-1"]={o={a10025=1}},
                    ["a2-1"]={o={a10015=1}},
                    ["a3-1"]={o={a10025=1}},
                    ["a4-1"]={o={a10005=1}},
                    ["a5-1"]={o={a10035=1}},
                    ["a6-1"]={o={a10005=1}},
                    ["a7-1"]={o={a10015=1}},
                    ["a8-1"]={o={a10005=1}},
                    ["a9-1"]={u={gems=10}},
                },
                --万能icon
                niubiicon={"a10"},
                serverreward={
                    --抽取配置
                    pool={
                        {100},
                        {1,1,1,1,1,1,1,1,1,1},
                        {"a1","a2","a3","a4","a5","a6","a7","a8","a9","a10"},
                    },
                    --奖励类型
                    rewardlist={
                        ["a1-3"]={troops_a10043=5},
                        ["a2-3"]={troops_a10053=5},
                        ["a3-3"]={troops_a10063=5},
                        ["a4-3"]={troops_a10073=5},
                        ["a5-3"]={troops_a10082=5},
                        ["a6-3"]={troops_a10093=5},
                        ["a7-3"]={troops_a10113=5},
                        ["a8-3"]={troops_a10123=5},
                        ["a9-3"]={userinfo_gems=200},
                        ["a10-3"]={userinfo_gems=1000},
                        ["a1-2"]={troops_a10043=1},
                        ["a2-2"]={troops_a10053=1},
                        ["a3-2"]={troops_a10063=1},
                        ["a4-2"]={troops_a10073=1},
                        ["a5-2"]={troops_a10082=1},
                        ["a6-2"]={troops_a10093=1},
                        ["a7-2"]={troops_a10113=1},
                        ["a8-2"]={troops_a10123=1},
                        ["a9-2"]={userinfo_gems=50},
                        ["a1-1"]={troops_a10025=1},
                        ["a2-1"]={troops_a10015=1},
                        ["a3-1"]={troops_a10025=1},
                        ["a4-1"]={troops_a10005=1},
                        ["a5-1"]={troops_a10035=1},
                        ["a6-1"]={troops_a10005=1},
                        ["a7-1"]={troops_a10015=1},
                        ["a8-1"]={troops_a10005=1},
                        ["a9-1"]={userinfo_gems=10},
                    },
                },
            },
            [2]={
                type=1,
                sortId=507,
                --单排抽奖
                cost=38,
                --三排抽奖
                mulCost=268,
                --几种类型的icon
                showicon={
                    ["a1"]={o={{a10043=1,index=1}}},
                    ["a2"]={o={{a10053=1,index=1}}},
                    ["a3"]={o={{a10063=1,index=1}}},
                    ["a4"]={o={{a10073=1,index=1}}},
                    ["a5"]={o={{a10082=1,index=1}}},
                    ["a6"]={o={{a10093=1,index=1}}},
                    ["a7"]={o={{a10113=1,index=1}}},
                    ["a8"]={o={{a10123=1,index=1}}},
                    ["a9"]={u={{gems=1,index=1}}},
                    ["a10"]={u={{gems=1,index=1}}},
                },
                rewardlist={
                    ["a1-3"]={o={a10043=5}},
                    ["a2-3"]={o={a10053=5}},
                    ["a3-3"]={o={a10063=5}},
                    ["a4-3"]={o={a10073=5}},
                    ["a5-3"]={o={a10082=5}},
                    ["a6-3"]={o={a10093=5}},
                    ["a7-3"]={o={a10113=5}},
                    ["a8-3"]={o={a10123=5}},
                    ["a9-3"]={u={gems=200}},
                    ["a10-3"]={u={gems=1000}},
                    ["a1-2"]={o={a10043=1}},
                    ["a2-2"]={o={a10053=1}},
                    ["a3-2"]={o={a10063=1}},
                    ["a4-2"]={o={a10073=1}},
                    ["a5-2"]={o={a10082=1}},
                    ["a6-2"]={o={a10093=1}},
                    ["a7-2"]={o={a10113=1}},
                    ["a8-2"]={o={a10123=1}},
                    ["a9-2"]={u={gems=50}},
                    ["a1-1"]={o={a10025=3}},
                    ["a2-1"]={o={a10015=3}},
                    ["a3-1"]={o={a10025=3}},
                    ["a4-1"]={o={a10005=3}},
                    ["a5-1"]={o={a10035=3}},
                    ["a6-1"]={o={a10005=3}},
                    ["a7-1"]={o={a10015=3}},
                    ["a8-1"]={o={a10005=3}},
                    ["a9-1"]={u={gems=10}},
                },
                --万能icon
                niubiicon={"a10"},
                serverreward={
                    --抽取配置
                    pool={
                        {100},
                        {1,1,1,1,1,1,1,1,1,1},
                        {"a1","a2","a3","a4","a5","a6","a7","a8","a9","a10"},
                    },
                    --奖励类型
                    rewardlist={
                        ["a1-3"]={troops_a10043=5},
                        ["a2-3"]={troops_a10053=5},
                        ["a3-3"]={troops_a10063=5},
                        ["a4-3"]={troops_a10073=5},
                        ["a5-3"]={troops_a10082=5},
                        ["a6-3"]={troops_a10093=5},
                        ["a7-3"]={troops_a10113=5},
                        ["a8-3"]={troops_a10123=5},
                        ["a9-3"]={userinfo_gems=200},
                        ["a10-3"]={userinfo_gems=1000},
                        ["a1-2"]={troops_a10043=1},
                        ["a2-2"]={troops_a10053=1},
                        ["a3-2"]={troops_a10063=1},
                        ["a4-2"]={troops_a10073=1},
                        ["a5-2"]={troops_a10082=1},
                        ["a6-2"]={troops_a10093=1},
                        ["a7-2"]={troops_a10113=1},
                        ["a8-2"]={troops_a10123=1},
                        ["a9-2"]={userinfo_gems=50},
                        ["a1-1"]={troops_a10025=3},
                        ["a2-1"]={troops_a10015=3},
                        ["a3-1"]={troops_a10025=3},
                        ["a4-1"]={troops_a10005=3},
                        ["a5-1"]={troops_a10035=3},
                        ["a6-1"]={troops_a10005=3},
                        ["a7-1"]={troops_a10015=3},
                        ["a8-1"]={troops_a10005=3},
                        ["a9-1"]={userinfo_gems=10},
                    },
                },
            },
            [3]={
                type=1,
                sortId=507,
                --单排抽奖
                cost=68,
                --三排抽奖
                mulCost=468,
                --几种类型的icon
                showicon={
                    ["a1"]={o={{a10043=1,index=1}}},
                    ["a2"]={o={{a10053=1,index=1}}},
                    ["a3"]={o={{a10063=1,index=1}}},
                    ["a4"]={o={{a10073=1,index=1}}},
                    ["a5"]={o={{a10082=1,index=1}}},
                    ["a6"]={o={{a10093=1,index=1}}},
                    ["a7"]={o={{a10113=1,index=1}}},
                    ["a8"]={o={{a10123=1,index=1}}},
                    ["a9"]={u={{gems=1,index=1}}},
                    ["a10"]={u={{gems=1,index=1}}},
                },
                rewardlist={
                    ["a1-3"]={o={a10043=5}},
                    ["a2-3"]={o={a10053=5}},
                    ["a3-3"]={o={a10063=5}},
                    ["a4-3"]={o={a10073=5}},
                    ["a5-3"]={o={a10082=5}},
                    ["a6-3"]={o={a10093=5}},
                    ["a7-3"]={o={a10113=5}},
                    ["a8-3"]={o={a10123=5}},
                    ["a9-3"]={u={gems=200}},
                    ["a10-3"]={u={gems=1000}},
                    ["a1-2"]={o={a10043=1}},
                    ["a2-2"]={o={a10053=1}},
                    ["a3-2"]={o={a10063=1}},
                    ["a4-2"]={o={a10073=1}},
                    ["a5-2"]={o={a10082=1}},
                    ["a6-2"]={o={a10093=1}},
                    ["a7-2"]={o={a10113=1}},
                    ["a8-2"]={o={a10123=1}},
                    ["a9-2"]={u={gems=50}},
                    ["a1-1"]={o={a10025=1}},
                    ["a2-1"]={o={a10015=1}},
                    ["a3-1"]={o={a10025=1}},
                    ["a4-1"]={o={a10005=1}},
                    ["a5-1"]={o={a10035=1}},
                    ["a6-1"]={o={a10005=1}},
                    ["a7-1"]={o={a10015=1}},
                    ["a8-1"]={o={a10005=1}},
                    ["a9-1"]={u={gems=10}},
                },
                --万能icon
                niubiicon={"a10"},
                serverreward={
                    --抽取配置
                    pool={
                        {100},
                        {1,1,1,1,1,1,1,1,1,1},
                        {"a1","a2","a3","a4","a5","a6","a7","a8","a9","a10"},
                    },
                    --奖励类型
                    rewardlist={
                        ["a1-3"]={troops_a10043=5},
                        ["a2-3"]={troops_a10053=5},
                        ["a3-3"]={troops_a10063=5},
                        ["a4-3"]={troops_a10073=5},
                        ["a5-3"]={troops_a10082=5},
                        ["a6-3"]={troops_a10093=5},
                        ["a7-3"]={troops_a10113=5},
                        ["a8-3"]={troops_a10123=5},
                        ["a9-3"]={userinfo_gems=200},
                        ["a10-3"]={userinfo_gems=1000},
                        ["a1-2"]={troops_a10043=1},
                        ["a2-2"]={troops_a10053=1},
                        ["a3-2"]={troops_a10063=1},
                        ["a4-2"]={troops_a10073=1},
                        ["a5-2"]={troops_a10082=1},
                        ["a6-2"]={troops_a10093=1},
                        ["a7-2"]={troops_a10113=1},
                        ["a8-2"]={troops_a10123=1},
                        ["a9-2"]={userinfo_gems=50},
                        ["a1-1"]={troops_a10025=1},
                        ["a2-1"]={troops_a10015=1},
                        ["a3-1"]={troops_a10025=1},
                        ["a4-1"]={troops_a10005=1},
                        ["a5-1"]={troops_a10035=1},
                        ["a6-1"]={troops_a10005=1},
                        ["a7-1"]={troops_a10015=1},
                        ["a8-1"]={troops_a10005=1},
                        ["a9-1"]={userinfo_gems=10},
                    },
                },
            },
            [4]={
                type=1,
                sortId=507,
                --单排抽奖
                cost=58,
                --三排抽奖
                mulCost=398,
                --几种类型的icon
                showicon={
                    ["a1"]={o={{a10043=1,index=1}}},
                    ["a2"]={o={{a10053=1,index=1}}},
                    ["a3"]={o={{a10063=1,index=1}}},
                    ["a4"]={o={{a10073=1,index=1}}},
                    ["a5"]={o={{a10082=1,index=1}}},
                    ["a6"]={o={{a10093=1,index=1}}},
                    ["a7"]={o={{a10113=1,index=1}}},
                    ["a8"]={o={{a10123=1,index=1}}},
                    ["a9"]={u={{gems=1,index=1}}},
                    ["a10"]={u={{gems=1,index=1}}},
                },
                rewardlist={
                    ["a1-3"]={o={a10043=5}},
                    ["a2-3"]={o={a10053=5}},
                    ["a3-3"]={o={a10063=5}},
                    ["a4-3"]={o={a10073=5}},
                    ["a5-3"]={o={a10082=5}},
                    ["a6-3"]={o={a10093=5}},
                    ["a7-3"]={o={a10113=5}},
                    ["a8-3"]={o={a10123=5}},
                    ["a9-3"]={u={gems=200}},
                    ["a10-3"]={u={gems=1000}},
                    ["a1-2"]={o={a10043=1}},
                    ["a2-2"]={o={a10053=1}},
                    ["a3-2"]={o={a10063=1}},
                    ["a4-2"]={o={a10073=1}},
                    ["a5-2"]={o={a10082=1}},
                    ["a6-2"]={o={a10093=1}},
                    ["a7-2"]={o={a10113=1}},
                    ["a8-2"]={o={a10123=1}},
                    ["a9-2"]={u={gems=50}},
                    ["a1-1"]={o={a10025=3}},
                    ["a2-1"]={o={a10015=3}},
                    ["a3-1"]={o={a10025=3}},
                    ["a4-1"]={o={a10005=3}},
                    ["a5-1"]={o={a10035=3}},
                    ["a6-1"]={o={a10005=3}},
                    ["a7-1"]={o={a10015=3}},
                    ["a8-1"]={o={a10005=3}},
                    ["a9-1"]={u={gems=10}},
                },
                --万能icon
                niubiicon={"a10"},
                serverreward={
                    --抽取配置
                    pool={
                        {100},
                        {1,1,1,1,1,1,1,1,1,1},
                        {"a1","a2","a3","a4","a5","a6","a7","a8","a9","a10"},
                    },
                    --奖励类型
                    rewardlist={
                        ["a1-3"]={troops_a10043=5},
                        ["a2-3"]={troops_a10053=5},
                        ["a3-3"]={troops_a10063=5},
                        ["a4-3"]={troops_a10073=5},
                        ["a5-3"]={troops_a10082=5},
                        ["a6-3"]={troops_a10093=5},
                        ["a7-3"]={troops_a10113=5},
                        ["a8-3"]={troops_a10123=5},
                        ["a9-3"]={userinfo_gems=200},
                        ["a10-3"]={userinfo_gems=1000},
                        ["a1-2"]={troops_a10043=1},
                        ["a2-2"]={troops_a10053=1},
                        ["a3-2"]={troops_a10063=1},
                        ["a4-2"]={troops_a10073=1},
                        ["a5-2"]={troops_a10082=1},
                        ["a6-2"]={troops_a10093=1},
                        ["a7-2"]={troops_a10113=1},
                        ["a8-2"]={troops_a10123=1},
                        ["a9-2"]={userinfo_gems=50},
                        ["a1-1"]={troops_a10025=3},
                        ["a2-1"]={troops_a10015=3},
                        ["a3-1"]={troops_a10025=3},
                        ["a4-1"]={troops_a10005=3},
                        ["a5-1"]={troops_a10035=3},
                        ["a6-1"]={troops_a10005=3},
                        ["a7-1"]={troops_a10015=3},
                        ["a8-1"]={troops_a10005=3},
                        ["a9-1"]={userinfo_gems=10},
                    },
                },
            },
			[5]={	
				type=1,	
				sortId=507,	
				 --单排抽奖	
				cost=48,	
				 --三排抽奖	
				mulCost=328,	
				 --几种类型的icon	
				showicon={	
				["a1"]={	o={{a10044=1,index=1}}},
				["a2"]={	o={{a10054=1,index=1}}},
				["a3"]={	o={{a10064=1,index=1}}},
				["a4"]={	o={{a10074=1,index=1}}},
				["a5"]={	o={{a10083=1,index=1}}},
				["a6"]={	o={{a10094=1,index=1}}},
				["a7"]={	o={{a10114=1,index=1}}},
				["a8"]={	o={{a10124=1,index=1}}},
				["a9"]={	u={{gems=1,index=1}}},
				["a10"]={	u={{gems=1,index=1}}},
				},	
				rewardlist={	
				["a1-3"]={	o={a10044=5}},
				["a2-3"]={	o={a10054=5}},
				["a3-3"]={	o={a10064=5}},
				["a4-3"]={	o={a10074=5}},
				["a5-3"]={	o={a10083=5}},
				["a6-3"]={	o={a10094=5}},
				["a7-3"]={	o={a10114=5}},
				["a8-3"]={	o={a10124=5}},
				["a9-3"]={	u={gems=200}},
				["a10-3"]={	u={gems=1000}},
				["a1-2"]={	o={a10044=1}},
				["a2-2"]={	o={a10054=1}},
				["a3-2"]={	o={a10064=1}},
				["a4-2"]={	o={a10074=1}},
				["a5-2"]={	o={a10083=1}},
				["a6-2"]={	o={a10094=1}},
				["a7-2"]={	o={a10114=1}},
				["a8-2"]={	o={a10124=1}},
				["a9-2"]={	u={gems=50}},
				["a1-1"]={	o={a10026=1}},
				["a2-1"]={	o={a10016=1}},
				["a3-1"]={	o={a10026=1}},
				["a4-1"]={	o={a10006=1}},
				["a5-1"]={	o={a10036=1}},
				["a6-1"]={	o={a10006=1}},
				["a7-1"]={	o={a10016=1}},
				["a8-1"]={	o={a10006=1}},
				["a9-1"]={	u={gems=10}},
				},	
				 --万能icon	
				niubiicon={"a10"},	
				serverreward={	
				 --抽取配置	
				pool={	
				{100},	
				{1,1,1,1,1,1,1,1,1,1},	
				{"a1","a2","a3","a4","a5","a6","a7","a8","a9","a10"},	
				},	
				 --奖励类型	
				rewardlist={	
				["a1-3"]={	troops_a10044=5},
				["a2-3"]={	troops_a10054=5},
				["a3-3"]={	troops_a10064=5},
				["a4-3"]={	troops_a10074=5},
				["a5-3"]={	troops_a10083=5},
				["a6-3"]={	troops_a10094=5},
				["a7-3"]={	troops_a10114=5},
				["a8-3"]={	troops_a10124=5},
				["a9-3"]={	userinfo_gems=200},
				["a10-3"]={	userinfo_gems=1000},
				["a1-2"]={	troops_a10044=1},
				["a2-2"]={	troops_a10054=1},
				["a3-2"]={	troops_a10064=1},
				["a4-2"]={	troops_a10074=1},
				["a5-2"]={	troops_a10083=1},
				["a6-2"]={	troops_a10094=1},
				["a7-2"]={	troops_a10114=1},
				["a8-2"]={	troops_a10124=1},
				["a9-2"]={	userinfo_gems=50},
				["a1-1"]={	troops_a10026=1},
				["a2-1"]={	troops_a10016=1},
				["a3-1"]={	troops_a10026=1},
				["a4-1"]={	troops_a10006=1},
				["a5-1"]={	troops_a10036=1},
				["a6-1"]={	troops_a10006=1},
				["a7-1"]={	troops_a10016=1},
				["a8-1"]={	troops_a10006=1},
				["a9-1"]={	userinfo_gems=10},
				},	
				},	
				},	
        },



                --在线送好礼
        onlineReward={
            multiSelectType=true,
            --原活动
            [1] = {
                type=1,
                sortId=497,
                oward={
                    {t=300,icon="item_baoxiang_03.png",award={o={{a10004=3,index=1}},p={{p26=1,index=2},}},serverReward={troops_a10004=3,props_p26=1,}},
                    {t=1800,icon="item_baoxiang_05.png",award={o={{a10014=3,index=1}},p={{p27=1,index=2},{p277=1,index=3},}},serverReward={troops_a10014=3,props_p27=1,props_p277=1,}},
                    {t=3600,icon="item_baoxiang_09.png",award={o={{a10024=3,index=1}},p={{p28=1,index=2},{p12=1,index=3},{p30=1,index=4},}},serverReward={troops_a10024=3,props_p28=1,props_p12=1,props_p30=1,}},
                    {t=7200,icon="item_baoxiang_07.png",award={o={{a10034=3,index=1}},p={{p29=1,index=2},{p11=1,index=3},{p20=1,index=4},}},serverReward={troops_a10034=3,props_p29=1,props_p11=1,props_p20=1,}},
                },
            },
            --元宵节
            [2] = {
                type=1,
                sortId=497,
                oward={
                    {t=300,icon="item_baoxiang_03.png",award={p={{p446=3,index=1},{p393=5,index=2},}},serverReward={props_p446=3,props_p393=5,}},
                    {t=1800,icon="item_baoxiang_05.png",award={p={{p20=2,index=1},{p394=5,index=2},{p12=2,index=3},}},serverReward={props_p20=2,props_p394=5,props_p12=2,}},
                    {t=3600,icon="item_baoxiang_09.png",award={p={{p447=2,index=1},{p395=5,index=2},{p601=30,index=3},}},serverReward={props_p447=2,props_p395=5,props_p601=30,}},
                    {t=7200,icon="item_baoxiang_07.png",award={p={{p90=1,index=1},{p396=5,index=2},{p19=30,index=3},{p11=2,index=4},}},serverReward={props_p90=1,props_p396=5,props_p19=30,props_p11=2,}},
                },
            },
        },


        --许愿炉
        xuyuanlu={
            multiSelectType=true,
            [1]={
                type=1,
                sortId=517,
                version=1,
                --每天的金币许愿次数
                goldTimes={4,5,6,7,8,9,10,},
                --消耗金币 {消耗的金币,返回的金币范围}
                goldReward={
                    {50,{61,110},0},
                    {100,{121,220},0},
                    {200,{241,440},0},
                    {500,{551,800},0},
                    {1000,{1101,1600},1},
                    {2000,{2201,3200},1},
                    {5000,{5501,8000},1},
                    {10000,{10001,12000},1},
                    {20000,{20001,24000},1},
                    {50000,{50001,60000},1},
                },
                --资源任务
                --攻打关卡的次数,采集资源的数量,消耗的水晶数量
                resourceTask={
                    {3,100000,250000,},
                    {5,1000000,2500000,},
                    {10,10000000,25000000,},
                },
                serverreward={
                    --道具炉
                    pool={
                        {100},
                        {100,100,200,100,100,100,100,100,96,4,},
                        {{"props_p12",1},{"props_p11",1},{"props_p20",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p89",1},{"props_p90",1},},
                    },
                },
                br={"p90"}, --公告
                --超过18%发公告
                speakVate=18,
            },
            [2]={
                type=1,
                sortId=517,
                version=2,
                --每天的金币许愿次数
                goldTimes={4,5,6,7,8,9,10,},
                --消耗金币 {消耗的金币,返回的金币范围}
                goldReward={
                    {50,{61,110},0},
                    {100,{121,220},0},
                    {200,{241,440},0},
                    {500,{551,800},0},
                    {1000,{1101,1600},1},
                    {2000,{2201,3200},1},
                    {5000,{5501,8000},1},
                    {10000,{10001,12000},1},
                    {20000,{20001,24000},1},
                    {50000,{50001,60000},1},
                },
                --资源任务
                --攻打关卡的次数,采集资源的数量,消耗的水晶数量
                resourceTask={
                    {3,100000,250000,},
                    {5,1000000,2500000,},
                    {10,10000000,25000000,},
                },
                serverreward={
                    --道具炉
                    pool={
                        {100},
                        {100,100,200,100,100,100,100,100,96,4,},
                        {{"props_p12",1},{"props_p11",1},{"props_p20",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p89",1},{"props_p90",1},},
                    },
                },
                br={"p90"}, --公告
                --超过18%发公告
                speakVate=18,
            },

        },

        
        --战争之路
        battleRoad={
        multiSelectType=true,
            [1]={
                type=1,
                sortId=517,

                serverreward={
                    {id=1,num=1,reward={troops_a10002=5,props_p21=1,props_p47=1}},
                    {id=2,num=2,reward={troops_a10012=5,props_p12=1,props_p47=1}},
                    {id=3,num=3,reward={troops_a10022=5,props_p44=1,props_p47=1}},
                    {id=4,num=5,reward={troops_a10032=5,props_p11=1,props_p47=1}},
                    {id=5,num=10,reward={troops_a10003=5,props_p42=1,props_p47=2}},
                },

                reward={
                    {id=1,num=1,reward={o={{a10002=5,index=1}},p={{p21=1,index=2},{p47=1,index=3}}}},
                    {id=2,num=2,reward={o={{a10012=5,index=1}},p={{p12=1,index=2},{p47=1,index=3}}}},
                    {id=3,num=3,reward={o={{a10022=5,index=1}},p={{p44=1,index=2},{p47=1,index=3}}}},
                    {id=4,num=5,reward={o={{a10032=5,index=1}}, p={{p11=1,index=2},{p47=1,index=3}}}},
                    {id=5,num=10,reward={o={{a10003=5,index=1}},p={{p42=1,index=2},{p47=2,index=3}}}},
                }
            },
            [2]={
                type=1,
                sortId=517,

                serverreward={
                    {id=1,num=1,reward={troops_a10004=5,props_p36=1,props_p47=1}},
                    {id=2,num=2,reward={troops_a10014=5,props_p12=1,props_p47=1}},
                    {id=3,num=3,reward={troops_a10024=5,props_p44=1,props_p47=1}},
                    {id=4,num=5,reward={troops_a10034=5,props_p43=1,props_p47=1}},
                    {id=5,num=10,reward={troops_a10005=5,props_p42=1,props_p47=2}},
                },

                reward={
                    {id=1,num=1,reward={o={{a10004=5,index=1}},p={{p36=1,index=2},{p47=1,index=3}}}},
                    {id=2,num=2,reward={o={{a10014=5,index=1}},p={{p12=1,index=2},{p47=1,index=3}}}},
                    {id=3,num=3,reward={o={{a10024=5,index=1}},p={{p44=1,index=2},{p47=1,index=3}}}},
                    {id=4,num=5,reward={o={{a10034=5,index=1}},p={{p43=1,index=2},{p47=1,index=3}}}},
                    {id=5,num=10,reward={o={{a10005=5,index=1}},p={{p42=1,index=2},{p47=2,index=3}}}},
                }
            },

            [3]={
                type=1,
                sortId=517,

                serverreward={
                    {id=1,num=1,reward={troops_a10005=10,props_p36=1,props_p47=1}},
                    {id=2,num=2,reward={troops_a10015=10,props_p12=1,props_p47=1}},
                    {id=3,num=3,reward={troops_a10025=10,props_p44=1,props_p47=1}},
                    {id=4,num=5,reward={troops_a10035=10,props_p43=1,props_p47=1}},
                    {id=5,num=10,reward={troops_a10043=10,props_p42=1,props_p47=2}},
                },

                reward={
                    {id=1,num=1,reward={o={{a10005=10,index=1}},p={{p36=1,index=2},{p47=1,index=3}}}},
                    {id=2,num=2,reward={o={{a10015=10,index=1}},p={{p12=1,index=2},{p47=1,index=3}}}},
                    {id=3,num=3,reward={o={{a10025=10,index=1}},p={{p44=1,index=2},{p47=1,index=3}}}},
                    {id=4,num=5,reward={o={{a10035=10,index=1}},p={{p43=1,index=2},{p47=1,index=3}}}},
                    {id=5,num=10,reward={o={{a10043=10,index=1}},p={{p42=1,index=2},{p47=2,index=3}}}},
                }
            },


        },


        --新春红包活动非英雄版
        xinchunhongbao={
            multiSelectType=true,
            [1]={
                sortId=527,
                type=1,
                --赠送小礼包得到代币数
                smallGiftGems=200,
                --赠送大礼包得到代币数
                bigGiftGems=2000,
                --每日的赠送次数
                dailyTimes=10,
                --赠送小礼包消耗的金币数
                smallCost=38,
                --赠送大礼包消耗的金币数
                bigCost=188,
                --打开小礼包消耗的代币数
                openSmall=100,
                --打开大礼包消耗的代币数
                openBig=1000,
                --广播的道具
                showlist={p={{p275=1,index=1},{p266=1,index=1},{p89=1,index=1},{p267=1,index=4},{p813=1,index=5},{p90=1,index=6},}},
                --记录显示条数 30条
                recordNum=30,
                smallPool={p={{p275=1,index=1},{p266=1,index=2},{p89=1,index=3},}},
                bigPool={p={{p267=1,index=1},{p813=1,index=2},{p90=1,index=3},}},
                serverreward={
                    --小红包
                    smallPool={
                        {100},
                        {10,11,8,10,8,8,20,19,5,1,},
                        {{"props_p25",1},{"props_p19",1},{"props_p20",1},{"props_p12",1},{"props_p11",1},{"props_p277",5},{"props_p276",1},{"props_p275",1},{"props_p266",1},{"props_p89",1},},
                    },
                    --大红包
                    bigPool={
                        {100},
                        {12,12,12,12,12,12,10,12,4,2,},
                        {{"props_p19",10},{"props_p20",1},{"props_p36",1},{"props_p277",10},{"props_p276",2},{"props_p275",1},{"props_p812",1},{"props_p267",1},{"props_p813",1},{"props_p90",1},},
                    },
                },
            },
            --英雄版


            [2]={
                sortId=527,
                type=1,
                --赠送小礼包得到代币数
                smallGiftGems=200,
                --赠送大礼包得到代币数
                bigGiftGems=2000,
                --每日的赠送次数
                dailyTimes=10,
                --赠送小礼包消耗的金币数
                smallCost=38,
                --赠送大礼包消耗的金币数
                bigCost=188,
                --打开小礼包消耗的代币数
                openSmall=100,
                --打开大礼包消耗的代币数
                openBig=1000,
                --广播的道具
                showlist={p={{p601=1,index=1},{p812=1,index=2},{p89=1,index=3},{p815=1,index=4},{p813=1,index=5},{p90=1,index=6},}},
                --记录显示条数 30条
                recordNum=30,
                smallPool={p={{p601=1,index=1},{p812=1,index=2},{p89=1,index=3},}},
                bigPool={p={{p815=1,index=1},{p813=1,index=2},{p90=1,index=3},}},
                serverreward={
                    --小红包
                    smallPool={
                        {100},
                        {10,14,10,10,20,12,20,3,1,},
                        {{"props_p19",5},{"props_p20",1},{"props_p12",1},{"props_p11",1},{"props_p447",1},{"props_p606",1},{"props_p601",1},{"props_p812",1},{"props_p89",1},},
                    },
                    --大红包
                    bigPool={
                        {100},
                        {6,6,6,18,18,15,10,12,4,4,1,},
                        {{"props_p20",2},{"props_p12",1},{"props_p11",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p606",3},{"props_p812",1},{"props_p815",1},{"props_p813",1},{"props_p90",1},},
                    },
                },
            },

        },




        --水晶回馈活动
        --配置1：返利比1000，配置2：返利比10000
        shuijinghuikui={
            multiSelectType=true,
            [1] = {
                type=1,
                sortId=517,
                --金币：水晶 = 1:1000 小于1向下取整
                gemsVate=1000,
                --每日首充可以领取的水晶
                dailyGold=300000,
                gemsReward={u={{gold=1,index=1},}},
                dailyReward={u={{gold=1,index=1},}},
                serverreward={
                    --充值金币给的奖励
                    gemsReward={userinfo_gold=1},
                    --每日首充奖励
                    dailyReward={userinfo_gold=1},
                }
            },
            [2] = {
                type=1,
                sortId=517,
                --金币：水晶 = 1:1000 小于1向下取整
                gemsVate=10000,
                --每日首充可以领取的水晶
                dailyGold=3000000,
                gemsReward={u={{gold=1,index=1},}},
                dailyReward={u={{gold=1,index=1},}},
                serverreward={
                    --充值金币给的奖励
                    gemsReward={userinfo_gold=1},
                    --每日首充奖励
                    dailyReward={userinfo_gold=1},
                }
            },

        },

         -- 火线名将
        huoxianmingjiang={
            multiSelectType=true,
            [1]={   --  主送 麦克阿瑟    配送 图哈切夫斯基
                type=1,
                sortId=527,
                version=1,
                cost=98, --不免费时抽一次的金币花费
                value=1, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h26=2},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,84,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h19",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.02,0.0175,0.015,0.0125}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [2]={   --  主送 铁木辛哥    配送 布劳希奇
                type=1,
                sortId=527,
                version=2,
                cost=98, --不免费时抽一次的金币花费
                value=1, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h15=2},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,84,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h9",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.02,0.0175,0.015,0.0125}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [3]={   --  主送 麦克阿瑟    配送 图哈切夫斯基
                type=1,
                sortId=527,
                version=3,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h26=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                        {3,3,3,3,84,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,160,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                        {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h19",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s19",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [4]={   --  主送 铁木辛哥    配送 布劳希奇
                type=1,
                sortId=527,
                version=4,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h15=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                        {3,3,3,3,84,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,160,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                        {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h9",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s9",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [5]={   
        --主要投放将领：曼施坦因次要投放将领：罗科索夫斯基
                type=1,
                sortId=527,
                version=5,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h3=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                        {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                        {{"hero_h18",1},{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s18",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [6]={   
        --主要投放将领：巴顿次要投放将领：迪特里希
                type=1,
                sortId=527,
                version=6,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h24=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
{68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
{{"hero_h8",1},{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s8",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [7]={   
        --主要投放将领：朱可夫次要投放将领：克莱斯特
                type=1,
                sortId=527,
                version=7,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h13=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
            {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
            {{"hero_h6",1},{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s6",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [8]={
        --主要投放将领：隆美尔次要投放将领：叶廖缅科
                type=1,
                sortId=527,
                version=8,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h1=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
            {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
            {{"hero_h16",1},{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s16",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [9]={
        --主要投放将领：崔可夫次要投放将领：曼陀菲尔
                type=1,
                sortId=527,
                version=9,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h14=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
            {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
            {{"hero_h7",1},{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s7",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
            [10]={
            --主要投放将领：古德里安次要投放将领：科涅夫
                type=1,
                sortId=527,
                version=10,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h2=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
            {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
            {{"hero_h17",1},{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s17",2},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                    },
                    starRate = {0.03,0.02,0.012,0.006}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率
                    --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
			[11]={   --  主送 安特普瑞思    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h101=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },
			 [12]={   --  主送 斯多姆    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h102=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [13]={   --  主送 赛琳斯塔芙    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h103=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [14]={   --  主送 安吉妮    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h104=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [15]={   --  主送 瑟莫弗   无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h105=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [16]={   --  主送 艾薇瑞克斯    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h106=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [17]={   --  主送 艾恩克兰德    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h107=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [18]={   --  主送 格莱法   无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h108=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [19]={   --  主送 比格提彻尔    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h109=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },

            [20]={   --  主送 阿特尔雷    无配送
                type=1,
                sortId=527,
                version=11,
                cost=98, --不免费时抽一次的金币花费
                value=0.9, -- 抽十次的话打9折 int(取整)
                -- 4 ★ 级到了 必给英雄
                mustGetHero={hero_h110=4},
                serverreward={ -- 十连抽 普通随即
                    pool={{100},
                    {3,3,3,3,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                    {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"hero_s4",2},{"hero_s30",2},{"hero_s32",2},{"hero_s39",2},{"hero_s11",2},{"hero_s12",2},{"hero_s21",2},{"hero_s22",2},{"hero_s23",2},{"hero_s27",2},{"hero_s28",2},{"hero_s29",2},{"hero_s31",2},{"hero_s33",2},{"hero_s34",2},{"hero_s35",2},{"hero_s36",2},{"hero_s37",2},{"hero_s38",2},{"hero_s40",2},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",2},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",15},{"props_p632",15},{"props_p633",10},{"props_p634",10},{"props_p635",10},{"props_p636",10},{"props_p637",10}}
                },
                starRate = {0.03,0.02,0.012,0.005}, ---- 每次随机 1号星星，2号星星，3号星星，4号星星的分别概率 
                --每次抽取可能一次多个星星，星星之间的概率没有关联性，但是星星的激活状态区分顺序
                }
            },


        },
        
        --军资派送(超级舰队开服）
        junzipaisong={
        multiSelectType=true,
        [1]={
        version=51,
        type=1,
        sortId=547,
         --单次花费金币
        cost=28,
         --十次抽奖花费金币
        mulCost=252,
         --发公告道具
        showlist={p={{p20=1,index=2},}},
         --展示道具
        circleList={p={{p26=1,index=1},{p27=1,index=3},{p28=1,index=5},{p29=1,index=7},{p30=1,index=9},{p20=2,index=2},},o={{a10003=1,index=8},{a10013=1,index=6},{a10023=1,index=4},{a10033=1,index=10},}},
        serverreward={
        pool={
        {100},
        {8,8,8,8,8,12,12,12,12,12,},
        {{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p20",2},{"troops_a10003",1},{"troops_a10013",1},{"troops_a10023",1},{"troops_a10033",1},},
        },
        },
        },

        },

        --卡夫卡馈赠
        kafkagift={
            multiSelectType = true,
            [1]={
            sortID=899,
            version=1,
            cost={10,460,960,3420,8400 }, 
            reward={
                r1={
                    {{h={s40=5}},{h={s38=5}},{h={s37=5}},{h={s36=5}},{h={s27=5}},{h={s30=5}},{h={s32=5}},{h={s25=5}},},
                    {{h={s40=5}},{h={s38=5}},{h={s37=5}},{h={s36=5}},{h={s27=5}},{h={s30=5}},{h={s32=5}},{h={s25=5}},},
                    {{h={s40=10}},{h={s38=10}},{h={s37=10}},{h={s36=10}},{h={s27=10}},{h={s30=10}},{h={s32=10}},{h={s25=10}},},
                    {{h={s40=10}},{h={s38=10}},{h={s37=10}},{h={s36=10}},{h={s27=10}},{h={s30=10}},{h={s32=10}},{h={s25=10}},},
                    {{h={s40=20}},{h={s38=20}},{h={s37=20}},{h={s36=20}},{h={s27=20}},{h={s30=20}},{h={s32=20}},{h={s25=20}},},
                },
                r2={
                    {p={{p20=1,index=1},{p881=1,index=2}}},
                    {p={{p20=2,index=1},{p881=3,index=2}}},
                    {p={{p20=3,index=1},{p881=5,index=2}}},
                    {p={{p20=5,index=1},{p881=10,index=2}}},
                    {p={{p20=10,index=1},{p881=20,index=2}}},
                },
            },
            serverreward={
                r1={ --可选道具
                    {{hero_s40=5},{hero_s38=5},{hero_s37=5},{hero_s36=5},{hero_s27=5},{hero_s30=5},{hero_s32=5},{hero_s25=5},},
                    {{hero_s40=5},{hero_s38=5},{hero_s37=5},{hero_s36=5},{hero_s27=5},{hero_s30=5},{hero_s32=5},{hero_s25=5},},
                    {{hero_s40=10},{hero_s38=10},{hero_s37=10},{hero_s36=10},{hero_s27=10},{hero_s30=10},{hero_s32=10},{hero_s25=10},},
                    {{hero_s40=10},{hero_s38=10},{hero_s37=10},{hero_s36=10},{hero_s27=10},{hero_s30=10},{hero_s32=10},{hero_s25=10},},
                    {{hero_s40=20},{hero_s38=20},{hero_s37=20},{hero_s36=20},{hero_s27=20},{hero_s30=20},{hero_s32=20},{hero_s25=20},},
                },
                r2={ --必得道具
                    {props_p20=1,props_p881=1,},--统率书*1,改造工具箱*1
                    {props_p20=2,props_p881=3,},--统率书*2,改造工具箱*3
                    {props_p20=3,props_p881=5,},--统率书*3,改造工具箱*5
                    {props_p20=5,props_p881=10,},--统率书*5,改造工具箱*10
                    {props_p20=10,props_p881=20,},--统率书*10,改造工具箱*20
                },
            },
                rule={ --选择奖励VIP等级
                    r1={
                        {0,0,0,0,3, 3, 3,8,}, --第1充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第2充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第3充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第4充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第5充值档对应所有道具
                    },
                },    

            },
            [2]={
                sortID=899,
                version=2,
                cost={10,460,960,3420,8400 }, 
                reward={
                    r1={
                        {{h={s12=5}},{h={s11=5}},{h={s28=5}},{h={s29=5}},{h={s21=5}},{h={s39=5}},{h={s4=5}},{h={s25=5}},},
                        {{h={s12=5}},{h={s11=5}},{h={s28=5}},{h={s29=5}},{h={s21=5}},{h={s39=5}},{h={s4=5}},{h={s25=5}},},
                        {{h={s12=10}},{h={s11=10}},{h={s28=10}},{h={s29=10}},{h={s21=10}},{h={s39=10}},{h={s4=10}},{h={s25=10}},},
                        {{h={s12=10}},{h={s11=10}},{h={s28=10}},{h={s29=10}},{h={s21=10}},{h={s39=10}},{h={s4=10}},{h={s25=10}},},
                        {{h={s12=20}},{h={s11=20}},{h={s28=20}},{h={s29=20}},{h={s21=20}},{h={s39=20}},{h={s4=20}},{h={s25=20}},},
                    },
                    r2={
                        {p={{p601=3,index=1},{p881=1,index=2}}},
                        {p={{p601=5,index=1},{p881=3,index=2}}},
                        {p={{p601=10,index=1},{p881=5,index=2}}},
                        {p={{p601=20,index=1},{p881=10,index=2}}},
                        {p={{p601=50,index=1},{p881=20,index=2}}},
                    },
                },
                serverreward={
                    r1={ --可选道具
                        {{hero_s12=5},{hero_s11=5},{hero_s28=5},{hero_s29=5},{hero_s21=5},{hero_s39=5},{hero_s4=5},{hero_s25=5},},
                        {{hero_s12=5},{hero_s11=5},{hero_s28=5},{hero_s29=5},{hero_s21=5},{hero_s39=5},{hero_s4=5},{hero_s25=5},},
                        {{hero_s12=10},{hero_s11=10},{hero_s28=10},{hero_s29=10},{hero_s21=10},{hero_s39=10},{hero_s4=10},{hero_s25=10},},
                        {{hero_s12=10},{hero_s11=10},{hero_s28=10},{hero_s29=10},{hero_s21=10},{hero_s39=10},{hero_s4=10},{hero_s25=10},},
                        {{hero_s12=20},{hero_s11=20},{hero_s28=20},{hero_s29=20},{hero_s21=20},{hero_s39=20},{hero_s4=20},{hero_s25=20},},
                    },
                    r2={ --必得道具
                        {props_p601=3,props_p881=1,},--精锐勋章*3,改造工具箱*1
                        {props_p601=5,props_p881=3,},--精锐勋章*5,改造工具箱*3
                        {props_p601=10,props_p881=5,},--精锐勋章*10,改造工具箱*5
                        {props_p601=20,props_p881=10,},--精锐勋章*20,改造工具箱*10
                        {props_p601=50,props_p881=20,},--精锐勋章*50,改造工具箱*20
                    },
                },
                rule={ --选择奖励VIP等级
                    r1={
                        {0,0,0,0,3, 3, 3,8,}, --第1充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第2充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第3充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第4充值档对应所有道具
                        {0,0,0,0,3, 3, 3,8,}, --第5充值档对应所有道具
                    },
                },    

            },
            [3]={
                sortID=899,
                version=3,
                cost={40,298,960,3420,8400 }, 
                reward={
                    r1={
                        {{p={p182=1}},{p={p194=1}},{p={p206=1}},{p={p218=1}},{p={p185=1}},{p={p197=1}},{p={p209=1}},{p={p221=1}},},
                        {{p={p188=2}},{p={p200=2}},{p={p212=2}},{p={p224=2}},{p={p191=2}},{p={p203=2}},{p={p215=2}},{p={p227=2}},},
                        {{p={p353=2}},{p={p361=2}},{p={p369=2}},{p={p377=2}},{p={p357=2}},{p={p365=2}},{p={p373=2}},{p={p381=2}},},
                        {{p={p534=1}},{p={p542=1}},{p={p550=1}},{p={p558=1}},{p={p538=1}},{p={p546=1}},{p={p554=1}},{p={p562=1}},},
                        {{p={p534=3}},{p={p542=3}},{p={p550=3}},{p={p558=3}},{p={p538=3}},{p={p546=3}},{p={p554=3}},{p={p562=3}},},
                    },
                    r2={
                        {p={{p601=3,index=1},{p881=1,index=2}}},
                        {p={{p601=10,index=1},{p881=5,index=2}}},
                        {p={{p601=30,index=1},{p881=10,index=2}}},
                        {p={{p601=50,index=1},{p881=30,index=2}}},
                        {p={{p601=100,index=1},{p881=50,index=2}}},
                    },
                },
                serverreward={
                    r1={ --可选道具
                        {{props_p182=1},{props_p194=1},{props_p206=1},{props_p218=1},{props_p185=1},{props_p197=1},{props_p209=1},{props_p221=1},},
                        {{props_p188=2},{props_p200=2},{props_p212=2},{props_p224=2},{props_p191=2},{props_p203=2},{props_p215=2},{props_p227=2},},
                        {{props_p353=2},{props_p361=2},{props_p369=2},{props_p377=2},{props_p357=2},{props_p365=2},{props_p373=2},{props_p381=2},},
                        {{props_p534=1},{props_p542=1},{props_p550=1},{props_p558=1},{props_p538=1},{props_p546=1},{props_p554=1},{props_p562=1},},
                        {{props_p534=3},{props_p542=3},{props_p550=3},{props_p558=3},{props_p538=3},{props_p546=3},{props_p554=3},{props_p562=3},},
                    },
                    r2={ --必得道具
                        {props_p601=3,props_p881=1,},--精锐勋章*3,改造工具箱*1
                        {props_p601=10,props_p881=5,},--精锐勋章*10,改造工具箱*5
                        {props_p601=30,props_p881=10,},--精锐勋章*30,改造工具箱*10
                        {props_p601=50,props_p881=30,},--精锐勋章*50,改造工具箱*30
                        {props_p601=100,props_p881=50,},--精锐勋章*100,改造工具箱*50
                    },
                },
                rule={ --选择奖励VIP等级
                    r1={
                        {0,0,0,0,0, 0, 0,0,}, --第1充值档对应所有道具
                        {0,0,0,0,0, 0, 0,0,}, --第2充值档对应所有道具
                        {0,0,0,0,0, 0, 0,0,}, --第3充值档对应所有道具
                        {0,0,0,0,0, 0, 0,0,}, --第4充值档对应所有道具
                        {0,0,0,0,0, 0, 0,0,}, --第5充值档对应所有道具
                    },
                },    
            },
		[4]={
				sortID=899,
				version=4,
				cost={10,460,960,1920,3420}, 
				reward={
				r1={
				{{p={p302=1}},{p={p310=1}},{p={p318=1}},{p={p326=1}},{p={p306=1}},{p={p314=1}},{p={p322=1}},{p={p330=1}},},
				{{p={p302=1}},{p={p310=1}},{p={p318=1}},{p={p326=1}},{p={p306=1}},{p={p314=1}},{p={p322=1}},{p={p330=1}},},
				{{p={p353=1}},{p={p361=1}},{p={p369=1}},{p={p377=1}},{p={p357=1}},{p={p365=1}},{p={p373=1}},{p={p381=1}},},
				{{p={p353=2}},{p={p361=2}},{p={p369=2}},{p={p377=2}},{p={p357=2}},{p={p365=2}},{p={p373=2}},{p={p381=2}},},
				{{p={p353=3}},{p={p361=3}},{p={p369=3}},{p={p377=3}},{p={p357=3}},{p={p365=3}},{p={p373=3}},{p={p381=3}},},
				},
				r2={
				{p={{p601=3,index=1},{p881=1,index=2}}},
				{p={{p601=15,index=1},{p881=8,index=2}}},
				{p={{p601=30,index=1},{p881=10,index=2}}},
				{p={{p601=50,index=1},{p881=30,index=2}}},
				{p={{p601=100,index=1},{p881=50,index=2}}},
				},
				},
				serverreward={
				r1={--可选道具
				{{props_p302=1},{props_p310=1},{props_p318=1},{props_p326=1},{props_p306=1},{props_p314=1},{props_p322=1},{props_p330=1},},
				{{props_p302=1},{props_p310=1},{props_p318=1},{props_p326=1},{props_p306=1},{props_p314=1},{props_p322=1},{props_p330=1},},
				{{props_p353=1},{props_p361=1},{props_p369=1},{props_p377=1},{props_p357=1},{props_p365=1},{props_p373=1},{props_p381=1},},
				{{props_p353=2},{props_p361=2},{props_p369=2},{props_p377=2},{props_p357=2},{props_p365=2},{props_p373=2},{props_p381=2},},
				{{props_p353=3},{props_p361=3},{props_p369=3},{props_p377=3},{props_p357=3},{props_p365=3},{props_p373=3},{props_p381=3},},
				},
				r2={--必得道具
				{props_p601=3,props_p881=1,},--精锐勋章*3,改造工具箱*1
				{props_p601=15,props_p881=8,},--精锐勋章*15,改造工具箱*8
				{props_p601=30,props_p881=10,},--精锐勋章*30,改造工具箱*10
				{props_p601=50,props_p881=30,},--精锐勋章*50,改造工具箱*30
				{props_p601=100,props_p881=50,},--精锐勋章*100,改造工具箱*50
				},
				},
				rule={--选择奖励VIP等级
				r1={
				{0,0,0,0,0,0, 0,0,},--第1充值档对应所有道具
				{0,0,0,0,0,0, 0,0,},--第2充值档对应所有道具
				{0,0,0,0,0,0, 0,0,},--第3充值档对应所有道具
				{0,0,0,0,0,0, 0,0,},--第4充值档对应所有道具
				{0,0,0,0,0,0, 0,0,},--第5充值档对应所有道具
				},
				},   

				},

		[5]={										
				sortID=899,										
				version=5,										
				cost={	10,	460,	960,	1920,	3420	 }, 				
				reward={										
				r1={										
				{	{p={p182=1}},	{p={p194=1}},	{p={p206=1}},	{p={p218=1}},	{p={p185=1}},	{p={p197=1}},	{p={p209=1}},	{p={p221=1}},	},	
				{	{p={p182=1}},	{p={p194=1}},	{p={p206=1}},	{p={p218=1}},	{p={p185=1}},	{p={p197=1}},	{p={p209=1}},	{p={p221=1}},	},	
				{	{p={p188=2}},	{p={p200=2}},	{p={p212=2}},	{p={p224=2}},	{p={p191=2}},	{p={p203=2}},	{p={p215=2}},	{p={p227=2}},	},	
				{	{p={p533=1}},	{p={p541=1}},	{p={p549=1}},	{p={p557=1}},	{p={p537=1}},	{p={p545=1}},	{p={p553=1}},	{p={p561=1}},	},	
				{	{p={p533=3}},	{p={p541=3}},	{p={p549=3}},	{p={p557=3}},	{p={p537=3}},	{p={p545=3}},	{p={p553=3}},	{p={p561=3}},	},	
				},										
				r2={										
				{	e={{	p4=100,index=1}	},p={{	p881=1,index=2}	}},					
				{	e={{	p4=300,index=1}	},p={{	p881=3,index=2}	}},					
				{	e={{	p4=500,index=1}	},p={{	p881=5,index=2}	}},					
				{	e={{	p4=1000,index=1}	},p={{	p881=10,index=2}	}},					
				{	e={{	p4=1500,index=1}	},p={{	p881=15,index=2}	}},					
				},										
				},										
				serverreward={										
				r1={	 --可选道具									
				{	{props_p182=1},	{props_p194=1},	{props_p206=1},	{props_p218=1},	{props_p185=1},	{props_p197=1},	{props_p209=1},	{props_p221=1},	},	
				{	{props_p182=1},	{props_p194=1},	{props_p206=1},	{props_p218=1},	{props_p185=1},	{props_p197=1},	{props_p209=1},	{props_p221=1},	},	
				{	{props_p188=2},	{props_p200=2},	{props_p212=2},	{props_p224=2},	{props_p191=2},	{props_p203=2},	{props_p215=2},	{props_p227=2},	},	
				{	{props_p533=1},	{props_p541=1},	{props_p549=1},	{props_p557=1},	{props_p537=1},	{props_p545=1},	{props_p553=1},	{props_p561=1},	},	
				{	{props_p533=3},	{props_p541=3},	{props_p549=3},	{props_p557=3},	{props_p537=3},	{props_p545=3},	{props_p553=3},	{props_p561=3},	},	
				},										
				r2={	 --必得道具									
				{	accessory_p4=100,	props_p881=1,	},	--零件*100,	改造工具箱*1					
				{	accessory_p4=300,	props_p881=3,	},	--零件*300,	改造工具箱*3					
				{	accessory_p4=500,	props_p881=5,	},	--零件*500,	改造工具箱*5					
				{	accessory_p4=1000,	props_p881=10,	},	--零件*1000,	改造工具箱*10					
				{	accessory_p4=1500,	props_p881=15,	},	--零件*1500,	改造工具箱*15					
				},										
				},										
				rule={	 --选择奖励VIP等级									
				r1={										
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第1充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第2充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第3充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第4充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第5充值档对应所有道具
				},										
				},					    					
														
				},	
		[6]={										
				sortID=899,										
				version=6,										
				cost={	40,	298,	960,	3420,	8400	 }, 				
				reward={										
				r1={										
				{	{p={p182=1}},	{p={p194=1}},	{p={p206=1}},	{p={p218=1}},	{p={p185=1}},	{p={p197=1}},	{p={p209=1}},	{p={p221=1}},	},	
				{	{p={p188=2}},	{p={p200=2}},	{p={p212=2}},	{p={p224=2}},	{p={p191=2}},	{p={p203=2}},	{p={p215=2}},	{p={p227=2}},	},	
				{	{p={p353=2}},	{p={p361=2}},	{p={p369=2}},	{p={p377=2}},	{p={p357=2}},	{p={p365=2}},	{p={p373=2}},	{p={p381=2}},	},	
				{	{p={p534=1}},	{p={p542=1}},	{p={p550=1}},	{p={p558=1}},	{p={p538=1}},	{p={p546=1}},	{p={p554=1}},	{p={p562=1}},	},	
				{	{p={p534=3}},	{p={p542=3}},	{p={p550=3}},	{p={p558=3}},	{p={p538=3}},	{p={p546=3}},	{p={p554=3}},	{p={p562=3}},	},	
				},										
				r2={										
				{	p={{	p601=3,index=1}	,{	p881=1,index=2}	}},					
				{	p={{	p601=10,index=1}	,{	p881=5,index=2}	}},					
				{	p={{	p601=30,index=1}	,{	p881=10,index=2}	}},					
				{	p={{	p601=50,index=1}	,{	p881=30,index=2}	}},					
				{	p={{	p601=100,index=1}	,{	p881=50,index=2}	}},					
				},										
				},										
				serverreward={										
				r1={	 --可选道具									
				{	{props_p182=1},	{props_p194=1},	{props_p206=1},	{props_p218=1},	{props_p185=1},	{props_p197=1},	{props_p209=1},	{props_p221=1},	},	
				{	{props_p188=2},	{props_p200=2},	{props_p212=2},	{props_p224=2},	{props_p191=2},	{props_p203=2},	{props_p215=2},	{props_p227=2},	},	
				{	{props_p353=2},	{props_p361=2},	{props_p369=2},	{props_p377=2},	{props_p357=2},	{props_p365=2},	{props_p373=2},	{props_p381=2},	},	
				{	{props_p534=1},	{props_p542=1},	{props_p550=1},	{props_p558=1},	{props_p538=1},	{props_p546=1},	{props_p554=1},	{props_p562=1},	},	
				{	{props_p534=3},	{props_p542=3},	{props_p550=3},	{props_p558=3},	{props_p538=3},	{props_p546=3},	{props_p554=3},	{props_p562=3},	},	
				},										
				r2={	 --必得道具									
				{	props_p601=3,	props_p881=1,	},	--精锐勋章*3,	改造工具箱*1					
				{	props_p601=10,	props_p881=5,	},	--精锐勋章*10,	改造工具箱*5					
				{	props_p601=30,	props_p881=10,	},	--精锐勋章*30,	改造工具箱*10					
				{	props_p601=50,	props_p881=30,	},	--精锐勋章*50,	改造工具箱*30					
				{	props_p601=100,	props_p881=50,	},	--精锐勋章*100,	改造工具箱*50					
				},										
				},										
				rule={	 --选择奖励VIP等级									
				r1={										
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第1充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第2充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第3充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第4充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第5充值档对应所有道具
				},										
				},					    					
														
				},										

														
				[7]={										
				sortID=899,										
				version=7,										
				cost={	50,	960,	1920,	3420,	9000	 }, 				
				reward={										
				r1={										
				{	{p={p353=1}},	{p={p361=1}},	{p={p369=1}},	{p={p377=1}},	{p={p357=1}},	{p={p365=1}},	{p={p373=1}},	{p={p381=1}},	},	
				{	{p={p353=2}},	{p={p361=2}},	{p={p369=2}},	{p={p377=2}},	{p={p357=2}},	{p={p365=2}},	{p={p373=2}},	{p={p381=2}},	},	
				{	{p={p353=2}},	{p={p361=2}},	{p={p369=2}},	{p={p377=2}},	{p={p357=2}},	{p={p365=2}},	{p={p373=2}},	{p={p381=2}},	},	
				{	{p={p534=1}},	{p={p538=1}},	{p={p542=1}},	{p={p546=1}},	{p={p550=1}},	{p={p554=1}},	{p={p558=1}},	{p={p562=1}},	},	
				{	{p={p183=1}},	{p={p186=1}},	{p={p195=1}},	{p={p198=1}},	{p={p207=1}},	{p={p210=1}},	{p={p219=1}},	{p={p222=1}},	},	
				},										
				r2={										
				{	p={{	p277=5,index=1}	,{	p881=2,index=2}	}},					
				{	p={{	p277=20,index=1}	,{	p881=10,index=2}	}},					
				{	p={{	p277=50,index=1}	,{	p881=20,index=2}	}},					
				{	p={{	p277=100,index=1}	,{	p881=50,index=2}	}},					
				{	p={{	p277=200,index=1}	,{	p881=100,index=2}	}},					
				},										
				},										
				serverreward={										
				r1={	 --可选道具									
				{	{props_p353=1},	{props_p361=1},	{props_p369=1},	{props_p377=1},	{props_p357=1},	{props_p365=1},	{props_p373=1},	{props_p381=1},	},	
				{	{props_p353=2},	{props_p361=2},	{props_p369=2},	{props_p377=2},	{props_p357=2},	{props_p365=2},	{props_p373=2},	{props_p381=2},	},	
				{	{props_p353=2},	{props_p361=2},	{props_p369=2},	{props_p377=2},	{props_p357=2},	{props_p365=2},	{props_p373=2},	{props_p381=2},	},	
				{	{props_p534=1},	{props_p538=1},	{props_p542=1},	{props_p546=1},	{props_p550=1},	{props_p554=1},	{props_p558=1},	{props_p562=1},	},	
				{	{props_p183=1},	{props_p186=1},	{props_p195=1},	{props_p198=1},	{props_p207=1},	{props_p210=1},	{props_p219=1},	{props_p222=1},	},	
				},										
				r2={	 --必得道具									
				{	props_p277=5,	props_p881=2,	},	--电钻_道具*5,	改造工具箱*2					
				{	props_p277=20,	props_p881=10,	},	--电钻_道具*20,	改造工具箱*10					
				{	props_p277=50,	props_p881=20,	},	--电钻_道具*50,	改造工具箱*20					
				{	props_p277=100,	props_p881=50,	},	--电钻_道具*100,	改造工具箱*50					
				{	props_p277=200,	props_p881=100,	},	--电钻_道具*200,	改造工具箱*100					
				},										
				},										
				rule={	 --选择奖励VIP等级									
				r1={										
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第1充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第2充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第3充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第4充值档对应所有道具
				{	0,	0,	0,	0,	0,	 0, 	0,	0,	},	 --第5充值档对应所有道具
				},										
				},					    					
														
				},										


								

	},									
				

        --充值有礼
        chongzhiyouli={
            type=1,
            sortId=557,
            activeTitle="充值有‘礼’",
            --充值的金币数
            addGemCondition=100,
            --返还的金币数
            addGemsNum=100,
        },

       --连续充值送将领
        songjiangling={
            multiSelectType=true,
            [1]={
                type=1,
                sortId=587,
                --黑客修改记录需要的金币数
                rR=128,
                --最终奖励
                bigReward={p={{p834=1,index=1}},},
                serverreward={
                    bigReward={props_p834=1},
                },
            },
        },

        --51xingyunzhuanpan
         --幸运转盘
        xingyunzhuanpan={
            multiSelectType = true,
             --j将领相关，78配件
            [1]={
			
				sortId=527,
				type=1,
				version=1,
				cost=28,--单指针价格
				doubleCost=38,--双指针价格
				value=0.9,--十倍模式折扣
				mul=10, --倍率
				shopItem={
				 --mm_m1 代币
					{id="i1",buynum=1,price=50,reward={e={{f0=1}}},serverReward={accessory_f0=1}},
					{id="i2",buynum=5,price=150,reward={p={{p863=1}}},serverReward={props_p863=1}},
					{id="i3",buynum=50,price=12,reward={p={{p672=1}}},serverReward={props_p672=1}},
					{id="i4",buynum=2,price=80,reward={e={{f0=1}}},serverReward={accessory_f0=1}},
					{id="i5",buynum=5,price=130,reward={p={{p90=1}}},serverReward={props_p90=1}},
					{id="i6",buynum=30,price=30,reward={p={{p812=1}}},serverReward={props_p812=1}},
					{id="i7",buynum=30,price=120,reward={p={{p813=1}}},serverReward={props_p813=1}},
					{id="i8",buynum=30,price=40,reward={p={{p815=1}}},serverReward={props_p815=1}},
					{id="i9",buynum=30,price=150,reward={p={{p816=1}}},serverReward={props_p816=1}},
					{id="i10",buynum=10,price=80,reward={p={{p860=1}}},serverReward={props_p860=1}},
					{id="i11",buynum=10,price=100,reward={p={{p861=1}}},serverReward={props_p861=1}},
					{id="i12",buynum=10,price=120,reward={p={{p862=1}}},serverReward={props_p862=1}},
				},

				circleList={m={{m1=3,index=4,icon=2},{m1=1,index=7,icon=3},{m1=10,index=1,icon=1},},p={{p601=2,index=2,icon=2},{p447=1,index=3,icon=1},},e={{p3=1,index=5,icon=3},{p2=1,index=8,icon=2},{p1=1,index=6,icon=1},},},

				serverreward={
                pool={
                    {100},
                    {15,11,12,11,12,12,13,14,},
                    {{"mm_m1",3,7},{"mm_m1",1,5},{"mm_m1",10,6},{"props_p601",2,8},{"props_p447",1,2},{"accessory_p3",1,3},{"accessory_p2",1,1},{"accessory_p1",1,4},},
					},
				},
			},
			
            [2]={
			
				sortId=527,
				type=1,
				version=1,
				cost=28,--单指针价格
				doubleCost=38,--双指针价格
				value=0.9,--十倍模式折扣
				mul=10, --倍率
				shopItem={
				 --mm_m1 代币
					{id="i1",buynum=1,price=50,reward={e={{f0=1}}},serverReward={accessory_f0=1}},
					{id="i2",buynum=5,price=150,reward={p={{p863=1}}},serverReward={props_p863=1}},
					{id="i3",buynum=50,price=12,reward={p={{p672=1}}},serverReward={props_p672=1}},
					{id="i4",buynum=2,price=80,reward={e={{f0=1}}},serverReward={accessory_f0=1}},
					{id="i5",buynum=5,price=130,reward={p={{p90=1}}},serverReward={props_p90=1}},
					{id="i6",buynum=30,price=30,reward={p={{p812=1}}},serverReward={props_p812=1}},
					{id="i7",buynum=30,price=120,reward={p={{p813=1}}},serverReward={props_p813=1}},
					{id="i8",buynum=30,price=40,reward={p={{p815=1}}},serverReward={props_p815=1}},
					{id="i9",buynum=30,price=150,reward={p={{p816=1}}},serverReward={props_p816=1}},
					{id="i10",buynum=10,price=80,reward={p={{p860=1}}},serverReward={props_p860=1}},
					{id="i11",buynum=10,price=100,reward={p={{p861=1}}},serverReward={props_p861=1}},
				},

				circleList={m={{m1=3,index=4,icon=2},{m1=1,index=7,icon=3},{m1=10,index=1,icon=1},},p={{p601=2,index=2,icon=2},{p447=1,index=3,icon=1},},e={{p3=1,index=5,icon=3},{p2=1,index=8,icon=2},{p1=1,index=6,icon=1},},},

				serverreward={
					pool={
						{100},
						{15,11,12,11,12,12,13,14,},
						{{"mm_m1",3,7},{"mm_m1",1,5},{"mm_m1",10,6},{"props_p601",2,8},{"props_p447",1,2},{"accessory_p3",1,3},{"accessory_p2",1,1},{"accessory_p1",1,4},},
					},
				},
			},
        },


        --5.1钛矿丰收周
        taibumperweek={
            multiSelectType=true,
            [1]={ --新服配置，返利比例 1:1000
                sortId=529,
                type=1,
                version=1,
                res="r4",
                value=0.8,--已激活打折
                task={
                    l={{1,100000}},--登陆
                    t={{10,100000}},
                    r={{100000,100000},{10000000,1000000}}
                },
                dayres={
                    --每天充值给我的资源
                    1000,
                    1100,
                    1200,
                    1300,
                    1500,
                    1700,
                    2000,
                },
            },
            [2]={ --老服配置，返利比例 1:10000
                sortId=529,
                type=1,
                version=1,
                res="r4",
                value=0.8,--已激活打折
                task={
                    l={{1,1000000}},--登陆
                    t={{20,1000000}},
                    r={{1000000,1000000},{100000000,10000000}}
                },
                dayres={
                    --每天充值给我的资源
                    10000,
                    11000,
                    12000,
                    13000,
                    15000,
                    17000,
                    20000,
                },

            },
        },

        --火线名将改
        huoxianmingjianggai={
            multiSelectType=true,
            --xxxx英雄
            [1]={
                --主要投放将领：麦克阿瑟次要投放将领：图哈切夫斯基
                type=1,
                sorId=577,
                version=1,
                --不免费时抽一次的金币花费
                cost=98,
                --抽十次的话打9折 int(取整)
                value=0.9,
                --荣誉点数奖励
                scoreReward={
                    {500,{p={{p601=50,index=1}}}},
                    {1000,{p={{p448=10,index=1}}}},
                    {2000,{p={{p611=5,index=1}}}},
                    {3500,{h={{h26=4,index=1}}}},
                },
                --多少积分可以上榜
                scoreLimit=500,
                --榜单显示几条
                ranklimit=10,
                --排名奖励
                rankReward={
                    {{1,1},{p={{p448=30,index=1},{p601=100,index=2}}}},
                    {{2,2},{p={{p448=20,index=1},{p601=60,index=2}}}},
                    {{3,3},{p={{p448=15,index=1},{p601=30,index=2}}}},
                    {{4,5},{p={{p448=10,index=1},{p601=20,index=2}}}},
                    {{6,10},{p={{p448=5,index=1},{p601=10,index=2}}}},
                },
                --积分值 前后台都对应index
                scorelist={{31,41},{31,41},{64,82},{64,82},{64,82},{64,82},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{4,7},{7,11},{5,9},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,4},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,4},{2,4},{2,4},{2,4},{2,4},{2,4}},
                serverreward={-- 十连抽 普通随即
                    --奖池
                    pool={
                        {100},
                        {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                        {{"hero_h19",{num=1,index=1}},{"hero_h4",{num=2,index=2}},{"hero_h30",{num=2,index=3}},{"hero_h32",{num=2,index=4}},{"hero_h39",{num=2,index=5}},{"hero_h11",{num=1,index=6}},{"hero_h12",{num=1,index=7}},{"hero_h21",{num=1,index=8}},{"hero_h22",{num=1,index=9}},{"hero_h23",{num=1,index=10}},{"hero_h27",{num=1,index=11}},{"hero_h28",{num=1,index=12}},{"hero_h29",{num=1,index=13}},{"hero_h31",{num=1,index=14}},{"hero_h33",{num=1,index=15}},{"hero_h34",{num=1,index=16}},{"hero_h35",{num=1,index=17}},{"hero_h36",{num=1,index=18}},{"hero_h37",{num=1,index=19}},{"hero_h38",{num=1,index=20}},{"hero_h40",{num=1,index=21}},{"hero_s19",{num=2,index=22}},{"hero_s4",{num=2,index=23}},{"hero_s30",{num=2,index=24}},{"hero_s32",{num=2,index=25}},{"hero_s39",{num=2,index=26}},{"hero_s11",{num=2,index=27}},{"hero_s12",{num=2,index=28}},{"hero_s21",{num=2,index=29}},{"hero_s22",{num=2,index=30}},{"hero_s23",{num=2,index=31}},{"hero_s27",{num=2,index=32}},{"hero_s28",{num=2,index=33}},{"hero_s29",{num=2,index=34}},{"hero_s31",{num=2,index=35}},{"hero_s33",{num=2,index=36}},{"hero_s34",{num=2,index=37}},{"hero_s35",{num=2,index=38}},{"hero_s36",{num=2,index=39}},{"hero_s37",{num=2,index=40}},{"hero_s38",{num=2,index=41}},{"hero_s40",{num=2,index=42}},{"props_p447",{num=3,index=43}},{"props_p448",{num=1,index=44}},{"props_p601",{num=10,index=45}},{"props_p611",{num=1,index=46}},{"props_p612",{num=1,index=47}},{"props_p613",{num=1,index=48}},{"props_p614",{num=1,index=49}},{"props_p615",{num=1,index=50}},{"props_p616",{num=1,index=51}},{"props_p617",{num=1,index=52}},{"props_p618",{num=1,index=53}},{"props_p606",{num=5,index=54}},{"props_p607",{num=2,index=55}},{"props_p621",{num=5,index=56}},{"props_p622",{num=5,index=57}},{"props_p623",{num=5,index=58}},{"props_p624",{num=5,index=59}},{"props_p625",{num=5,index=60}},{"props_p626",{num=5,index=61}},{"props_p627",{num=5,index=62}},{"props_p631",{num=2,index=63}},{"props_p632",{num=2,index=64}},{"props_p633",{num=2,index=65}},{"props_p634",{num=2,index=66}},{"props_p635",{num=2,index=67}},{"props_p636",{num=2,index=68}},{"props_p637",{num=2,index=69}}},
                    },
                    --排名奖励
                    rankReward={
                        {{1,1},{props_p448=30,props_p601=100}},
                        {{2,2},{props_p448=20,props_p601=60}},
                        {{3,3},{props_p448=15,props_p601=30}},
                        {{4,5},{props_p448=10,props_p601=20}},
                        {{6,10},{props_p448=5,props_p601=10}},
                    },
                    --荣誉点数奖励
                    scoreReward={
                        {500,{props_p601=50}},
                        {1000,{props_p448=10}},
                        {2000,{props_p611=5}},
                        {3500,{hero_h26=4}},
                    },
                },
            },
            [2]={
                --主要投放将领：铁木辛哥次要投放将领：布劳希奇
                type=1,
                sorId=577,
                version=2,
                --不免费时抽一次的金币花费
                cost=98,
                --抽十次的话打9折 int(取整)
                value=0.9,
                --荣誉点数奖励
                scoreReward={
                    {500,{p={{p601=50,index=1}}}},
                    {1000,{p={{p448=10,index=1}}}},
                    {2000,{p={{p611=5,index=1}}}},
                    {3500,{h={{h15=4,index=1}}}},
                },
                --多少积分可以上榜
                scoreLimit=500,
                --榜单显示几条
                ranklimit=10,
                --排名奖励
                rankReward={
                    {{1,1},{p={{p448=30,index=1},{p601=100,index=2}}}},
                    {{2,2},{p={{p448=20,index=1},{p601=60,index=2}}}},
                    {{3,3},{p={{p448=15,index=1},{p601=30,index=2}}}},
                    {{4,5},{p={{p448=10,index=1},{p601=20,index=2}}}},
                    {{6,10},{p={{p448=5,index=1},{p601=10,index=2}}}},
                },
                --积分值 前后台都对应index
                scorelist={{31,41},{31,41},{64,82},{64,82},{64,82},{64,82},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{4,7},{7,11},{5,9},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,4},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,4},{2,4},{2,4},{2,4},{2,4},{2,4}},
                serverreward={-- 十连抽 普通随即
                    --奖池
                    pool={
                        {100},
                        {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                        {{"hero_h9",{num=1,index=1}},{"hero_h4",{num=2,index=2}},{"hero_h30",{num=2,index=3}},{"hero_h32",{num=2,index=4}},{"hero_h39",{num=2,index=5}},{"hero_h11",{num=1,index=6}},{"hero_h12",{num=1,index=7}},{"hero_h21",{num=1,index=8}},{"hero_h22",{num=1,index=9}},{"hero_h23",{num=1,index=10}},{"hero_h27",{num=1,index=11}},{"hero_h28",{num=1,index=12}},{"hero_h29",{num=1,index=13}},{"hero_h31",{num=1,index=14}},{"hero_h33",{num=1,index=15}},{"hero_h34",{num=1,index=16}},{"hero_h35",{num=1,index=17}},{"hero_h36",{num=1,index=18}},{"hero_h37",{num=1,index=19}},{"hero_h38",{num=1,index=20}},{"hero_h40",{num=1,index=21}},{"hero_s9",{num=2,index=22}},{"hero_s4",{num=2,index=23}},{"hero_s30",{num=2,index=24}},{"hero_s32",{num=2,index=25}},{"hero_s39",{num=2,index=26}},{"hero_s11",{num=2,index=27}},{"hero_s12",{num=2,index=28}},{"hero_s21",{num=2,index=29}},{"hero_s22",{num=2,index=30}},{"hero_s23",{num=2,index=31}},{"hero_s27",{num=2,index=32}},{"hero_s28",{num=2,index=33}},{"hero_s29",{num=2,index=34}},{"hero_s31",{num=2,index=35}},{"hero_s33",{num=2,index=36}},{"hero_s34",{num=2,index=37}},{"hero_s35",{num=2,index=38}},{"hero_s36",{num=2,index=39}},{"hero_s37",{num=2,index=40}},{"hero_s38",{num=2,index=41}},{"hero_s40",{num=2,index=42}},{"props_p447",{num=3,index=43}},{"props_p448",{num=1,index=44}},{"props_p601",{num=10,index=45}},{"props_p611",{num=1,index=46}},{"props_p612",{num=1,index=47}},{"props_p613",{num=1,index=48}},{"props_p614",{num=1,index=49}},{"props_p615",{num=1,index=50}},{"props_p616",{num=1,index=51}},{"props_p617",{num=1,index=52}},{"props_p618",{num=1,index=53}},{"props_p606",{num=5,index=54}},{"props_p607",{num=2,index=55}},{"props_p621",{num=5,index=56}},{"props_p622",{num=5,index=57}},{"props_p623",{num=5,index=58}},{"props_p624",{num=5,index=59}},{"props_p625",{num=5,index=60}},{"props_p626",{num=5,index=61}},{"props_p627",{num=5,index=62}},{"props_p631",{num=2,index=63}},{"props_p632",{num=2,index=64}},{"props_p633",{num=2,index=65}},{"props_p634",{num=2,index=66}},{"props_p635",{num=2,index=67}},{"props_p636",{num=2,index=68}},{"props_p637",{num=2,index=69}}},
                    },
                    --排名奖励
                    rankReward={
                        {{1,1},{props_p448=30,props_p601=100}},
                        {{2,2},{props_p448=20,props_p601=60}},
                        {{3,3},{props_p448=15,props_p601=30}},
                        {{4,5},{props_p448=10,props_p601=20}},
                        {{6,10},{props_p448=5,props_p601=10}},
                    },
                    --荣誉点数奖励
                    scoreReward={
                        {500,{props_p601=50}},
                        {1000,{props_p448=10}},
                        {2000,{props_p611=5}},
                        {3500,{hero_h15=4}},
                    },
                },
            },
            [3]={
                --主要投放将领：曼施坦因次要投放将领：罗科索夫斯基
                type=1,
                sorId=577,
                version=3,
                --不免费时抽一次的金币花费
                cost=98,
                --抽十次的话打9折 int(取整)
                value=0.9,
                --荣誉点数奖励
                scoreReward={
                    {500,{p={{p601=50,index=1}}}},
                    {1000,{p={{p448=10,index=1}}}},
                    {2000,{p={{p611=5,index=1}}}},
                    {3500,{h={{h3=4,index=1}}}},
                },
                --多少积分可以上榜
                scoreLimit=500,
                --榜单显示几条
                ranklimit=10,
                --排名奖励
                rankReward={
                    {{1,1},{p={{p448=30,index=1},{p601=100,index=2}}}},
                    {{2,2},{p={{p448=20,index=1},{p601=60,index=2}}}},
                    {{3,3},{p={{p448=15,index=1},{p601=30,index=2}}}},
                    {{4,5},{p={{p448=10,index=1},{p601=20,index=2}}}},
                    {{6,10},{p={{p448=5,index=1},{p601=10,index=2}}}},
                },
                --积分值 前后台都对应index
                scorelist={{31,41},{31,41},{64,82},{64,82},{64,82},{64,82},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{31,41},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{5,9},{4,7},{7,11},{5,9},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,4},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,5},{2,4},{2,4},{2,4},{2,4},{2,4},{2,4}},
                serverreward={-- 十连抽 普通随即
                    --奖池
                    pool={
                        {100},
                        {68,3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,80,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,160,160,160,18,6,6,12,12,10,10,6,160,80,30,30,20,20,20,20,20,15,15,10,10,10,10,10},
                        {{"hero_h18",{num=1,index=1}},{"hero_h4",{num=2,index=2}},{"hero_h30",{num=2,index=3}},{"hero_h32",{num=2,index=4}},{"hero_h39",{num=2,index=5}},{"hero_h11",{num=1,index=6}},{"hero_h12",{num=1,index=7}},{"hero_h21",{num=1,index=8}},{"hero_h22",{num=1,index=9}},{"hero_h23",{num=1,index=10}},{"hero_h27",{num=1,index=11}},{"hero_h28",{num=1,index=12}},{"hero_h29",{num=1,index=13}},{"hero_h31",{num=1,index=14}},{"hero_h33",{num=1,index=15}},{"hero_h34",{num=1,index=16}},{"hero_h35",{num=1,index=17}},{"hero_h36",{num=1,index=18}},{"hero_h37",{num=1,index=19}},{"hero_h38",{num=1,index=20}},{"hero_h40",{num=1,index=21}},{"hero_s18",{num=2,index=22}},{"hero_s4",{num=2,index=23}},{"hero_s30",{num=2,index=24}},{"hero_s32",{num=2,index=25}},{"hero_s39",{num=2,index=26}},{"hero_s11",{num=2,index=27}},{"hero_s12",{num=2,index=28}},{"hero_s21",{num=2,index=29}},{"hero_s22",{num=2,index=30}},{"hero_s23",{num=2,index=31}},{"hero_s27",{num=2,index=32}},{"hero_s28",{num=2,index=33}},{"hero_s29",{num=2,index=34}},{"hero_s31",{num=2,index=35}},{"hero_s33",{num=2,index=36}},{"hero_s34",{num=2,index=37}},{"hero_s35",{num=2,index=38}},{"hero_s36",{num=2,index=39}},{"hero_s37",{num=2,index=40}},{"hero_s38",{num=2,index=41}},{"hero_s40",{num=2,index=42}},{"props_p447",{num=3,index=43}},{"props_p448",{num=1,index=44}},{"props_p601",{num=10,index=45}},{"props_p611",{num=1,index=46}},{"props_p612",{num=1,index=47}},{"props_p613",{num=1,index=48}},{"props_p614",{num=1,index=49}},{"props_p615",{num=1,index=50}},{"props_p616",{num=1,index=51}},{"props_p617",{num=1,index=52}},{"props_p618",{num=1,index=53}},{"props_p606",{num=5,index=54}},{"props_p607",{num=2,index=55}},{"props_p621",{num=5,index=56}},{"props_p622",{num=5,index=57}},{"props_p623",{num=5,index=58}},{"props_p624",{num=5,index=59}},{"props_p625",{num=5,index=60}},{"props_p626",{num=5,index=61}},{"props_p627",{num=5,index=62}},{"props_p631",{num=2,index=63}},{"props_p632",{num=2,index=64}},{"props_p633",{num=2,index=65}},{"props_p634",{num=2,index=66}},{"props_p635",{num=2,index=67}},{"props_p636",{num=2,index=68}},{"props_p637",{num=2,index=69}}},
                    },
                    --排名奖励
                    rankReward={
                        {{1,1},{props_p448=30,props_p601=100}},
                        {{2,2},{props_p448=20,props_p601=60}},
                        {{3,3},{props_p448=15,props_p601=30}},
                        {{4,5},{props_p448=10,props_p601=20}},
                        {{6,10},{props_p448=5,props_p601=10}},
                    },
                    --荣誉点数奖励
                    scoreReward={
                        {500,{props_p601=50}},
                        {1000,{props_p448=10}},
                        {2000,{props_p611=5}},
                        {3500,{hero_h3=4}},
                    },
                },
            },
        },

		diancitanke={			
				multiSelectType=true,			
			[1]={			
				sortId=902,			
				type=1,			
				rate=0.9,			
				maxval=240,			
			cost={	 --不免费时抽1次的金币花费		
				18,38,58			
				},			
			addval={	 --抽奖分值		
				{1,80},			
				{1,160},			
				{1,240},			
				},			
				mul=20,	 --20倍连抽		
				mulc=17,	 --20连抽花费的金币是mulc*cost		
				decay = {	 --衰减率		
				0.5,0.5,0.5			
				},			
			range = {	 --兑奖范围		
				1,	80,	160,	240
				},			
			reward={	 --前台展示		
					{p={{p902=1}}},	{p={{p414=1}}},	{o={{a10082=1}}},	{o={{a10083=1}}},
					},			
			serverreward = {			
					{props_p902=1},	{props_p414=1},	{troops_a10082=1},	{troops_a10083=1},
					},
				report={
						a10083='{"ocean":[1,1,2],"h":[{},{}],"d":[["800-70"],["38500-0","38500-16-0E","38500-0","38500-0","38500-0","38500-0"],["16000-67"],["16000-64"],["21120-12-0e","21120-8-0E","7604-6-0e","7604-5-0E","2738-4-0e","2738-3-0E"],["3000-63"],["20790-0"]],"t":[[["a10043",1],["a10044",24],["a10043",1],["a10043",1],["a10043",1],["a10043",1]],[{},{},{},["a10083",70],{},{}]],"p":[["PLAYER1",6,1,1000],["PLAYER2",60,0,1000]],"r":1}'									
                },
				consume={ --改造需求	
				a10083 = {			
					upgradeMetalConsume=1880000,	 --所消耗的Res		
					upgradeOilConsume=1880000,			
					upgradeSiliconConsume=1880000,			
					upgradeUraniumConsume=1180000,			
					upgradeMoneyConsume=0,			
					upgradeShipConsume={'a10082',1},	 --需要的升级的军舰Lv6		
					upgradePropConsume={{"p19",1},{"p414",1},},	 --需要消耗的道具,荣誉勋章&芯片		
					TransShipConsume={'a10083',1},	 --升级成的军舰Lv6.5		
					upgradeGemConsume=0,			
	
					},	
				},	
			},	
			--胡蜂级航母投放
		[2]={			
			sortId=902,			
				type=1,			
				rate=0.6,			
				maxval=240,			
				cost={	 --不免费时抽1次的金币花费		
				18,38,58			
				},			
				addval={	 --抽奖分值		
				{1,80},			
				{1,160},			
				{1,240},			
				},			
				mul=20,	 --20倍连抽		
				mulc=17,	 --20连抽花费的金币是mulc*cost		
				decay = {	 --衰减率		
				0.5,0.5,0.5			
				},			
				range = {	 --兑奖范围		
				1,	80,	160,	240
				},			
				reward={	 --前台展示		
				{p={{p902=1}}},	{p={{p875=1}}},	{o={{a20153=1}}},	{o={{a20154=1}}},
				},			
				serverreward = {			
				{props_p902=1},	{props_p875=1},	{troops_a20153=1},	{troops_a20154=1},
		},			
				report={
						a20154='{"ocean":[1,1,4],"h":[{},{}],"d":[["204188-745","204188-745","204188-745"],["295597-371-0O","236477-340-0O","591194-269-1O"],["159675-702","159675-702","159675-702"],["557070-127-1O","222828-283-0O","557070-50-1O"],["42694-691"],["548342-0-1","292449-208-0O","731122-0-1"],["97684-676","97684-676","97684-664"],["381467-110"],["381467-12"],["374696-0"]],"t":[[["a10035",500],["a10005",400],["a10025",500],{},{},{}],[["a20154",800],["a20154",800],["a20154",800],{},{},{}]],"p":[["PLAYER2",70,1,1000],["PLAYER1",70,0,1000]],"r":1}'
					},
		consume={ --改造需求	
			a20154={
				upgradeMetalConsume=1880000,	 --所消耗的Res
				upgradeOilConsume=1880000,	
				upgradeSiliconConsume=1880000,	
				upgradeUraniumConsume=1180000,	
				upgradeMoneyConsume=0,	
				upgradeShipConsume={'a20153',1},	 --需要的升级的军舰Lv6
				upgradePropConsume={{"p19",1},{"p875",1},},	 --需要消耗的道具,荣誉勋章&芯片
				TransShipConsume={'a20154',1},	 --升级成的军舰Lv6.5
				upgradeGemConsume=0,	
				},	
			},	
		},	


		},	


        --军事讲坛活动
        junshijiangtan={
            multiSelectType=true,
            --配置1
            [1] = {
                type=1,
                sortId=567,
                --前台展示
                rewardlist={
                    --小奖池
                    [1]={{p={{p446=2,index=1},{p601=1,index=2},{p621=2,index=3},{p622=2,index=4},{p623=2,index=5},{p624=2,index=6},{p625=2,index=7},{p626=2,index=8},{p627=2,index=9},{p631=1,index=10},{p632=1,index=11},{p633=1,index=12},{p634=1,index=13},{p635=1,index=14},{p636=1,index=15},{p637=1,index=16},},},},
                    --中奖池
                    [2]={{p={{p447=1,index=1},{p601=3,index=2},{p601=5,index=3},{p631=1,index=4},{p632=1,index=5},{p633=1,index=6},{p634=1,index=7},{p635=1,index=8},{p636=1,index=9},{p637=1,index=10},{p641=1,index=11},{p642=1,index=12},{p643=1,index=13},{p644=1,index=14},{p645=1,index=15},{p646=1,index=16},{p647=1,index=17},{p611=1,index=18},{p612=1,index=19},{p613=1,index=20},{p614=1,index=21},{p615=1,index=22},{p616=1,index=23},{p617=1,index=24},{p618=1,index=25},},},},
                    --大奖池
                    [3]={{p={{p448=1,index=1},{p606=1,index=2},{p607=1,index=3},{p641=1,index=4},{p642=1,index=5},{p643=1,index=6},{p644=1,index=7},{p645=1,index=8},{p646=1,index=9},{p647=1,index=10},{p611=1,index=11},{p612=1,index=12},{p613=1,index=13},{p614=1,index=14},{p615=1,index=15},{p616=1,index=16},{p617=1,index=17},{p618=1,index=18},},},},
                },
                --花费金币数 {一次， 十次}
                gemcost={
                    [1]={18,162},
                    [2]={28,252},
                    [3]={38,342},
                },
                --积分值 前后台都对应index
                scorelist={
                    [1]={{1,4},{2,5},{4,7},{4,7},{4,7},{4,7},{4,7},{4,7},{4,7},{5,8},{5,8},{5,8},{5,8},{5,8},{5,8},{5,8},},
                    [2]={{5,8},{2,5},{2,5},{5,8},{5,8},{5,8},{5,8},{5,8},{5,8},{5,8},{7,10},{7,10},{7,10},{7,10},{7,10},{7,10},{7,10},{10,13},{10,13},{10,13},{10,13},{10,13},{10,13},{10,13},{10,13},},
                    [3]={{25,28},{2,5},{5,8},{7,10},{7,10},{7,10},{7,10},{7,10},{7,10},{7,10},{10,13},{10,13},{10,13},{10,13},{10,13},{10,13},{10,13},{10,13},},
                },
                --多少积分可以上榜
                scoreLimit=500,
                --榜单显示几条
                ranklimit=10,
                --排名奖励
                rankReward={
                    {{1,1},{p={{p601=288,index=1},}}},
                    {{2,2},{p={{p601=188,index=1},}}},
                    {{3,3},{p={{p601=138,index=1},}}},
                    {{4,5},{p={{p601=98,index=1},}}},
                    {{6,10},{p={{p601=68,index=1},}}},
                },
                serverreward={
                    pool={
                        [1] = {
                            {100},
                            {4,12,8,8,8,8,8,8,8,4,4,4,4,4,4,4,},
                            --道具id  {道具数量，{狂怒点最小值，最大值}}
                            {{"props_p446",{num=2,index=1}},{"props_p601",{num=1,index=2}},{"props_p621",{num=2,index=3}},{"props_p622",{num=2,index=4}},{"props_p623",{num=2,index=5}},{"props_p624",{num=2,index=6}},{"props_p625",{num=2,index=7}},{"props_p626",{num=2,index=8}},{"props_p627",{num=2,index=9}},{"props_p631",{num=1,index=10}},{"props_p632",{num=1,index=11}},{"props_p633",{num=1,index=12}},{"props_p634",{num=1,index=13}},{"props_p635",{num=1,index=14}},{"props_p636",{num=1,index=15}},{"props_p637",{num=1,index=16}},},
                        },
                        [2] = {
                            {100},
                            {5,12,3,5,5,5,5,5,5,5,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,},
                            --道具id  {道具数量，{狂怒点最小值，最大值}}
                            {{"props_p447",{num=1,index=1}},{"props_p601",{num=3,index=2}},{"props_p601",{num=5,index=3}},{"props_p631",{num=1,index=4}},{"props_p632",{num=1,index=5}},{"props_p633",{num=1,index=6}},{"props_p634",{num=1,index=7}},{"props_p635",{num=1,index=8}},{"props_p636",{num=1,index=9}},{"props_p637",{num=1,index=10}},{"props_p641",{num=1,index=11}},{"props_p642",{num=1,index=12}},{"props_p643",{num=1,index=13}},{"props_p644",{num=1,index=14}},{"props_p645",{num=1,index=15}},{"props_p646",{num=1,index=16}},{"props_p647",{num=1,index=17}},{"props_p611",{num=1,index=18}},{"props_p612",{num=1,index=19}},{"props_p613",{num=1,index=20}},{"props_p614",{num=1,index=21}},{"props_p615",{num=1,index=22}},{"props_p616",{num=1,index=23}},{"props_p617",{num=1,index=24}},{"props_p618",{num=1,index=25}},},
                        },
                        [3] = {
                            {100},
                            {5,12,5,2,2,2,2,2,2,2,8,8,8,8,8,8,8,8,},
                            --道具id  {道具数量，{狂怒点最小值，最大值}}
                            {{"props_p448",{num=1,index=1}},{"props_p606",{num=1,index=2}},{"props_p607",{num=1,index=3}},{"props_p641",{num=1,index=4}},{"props_p642",{num=1,index=5}},{"props_p643",{num=1,index=6}},{"props_p644",{num=1,index=7}},{"props_p645",{num=1,index=8}},{"props_p646",{num=1,index=9}},{"props_p647",{num=1,index=10}},{"props_p611",{num=1,index=11}},{"props_p612",{num=1,index=12}},{"props_p613",{num=1,index=13}},{"props_p614",{num=1,index=14}},{"props_p615",{num=1,index=15}},{"props_p616",{num=1,index=16}},{"props_p617",{num=1,index=17}},{"props_p618",{num=1,index=18}},},
                        },
                    },
                    --排名奖励
                    rankReward={
                        {{1,1},{props_p601=288}},
                        {{2,2},{props_p601=188}},
                        {{3,3},{props_p601=138}},
                        {{4,5},{props_p601=98}},
                        {{6,10},{props_p601=68}},
                    },
                },
            },

        },

        --引力失常，加速消费
        speedupdisc = {
            multiSelectType=true,
            [1] = {
                type=1,
                sortId=2,            
                -- 加速类型
                speedup={
                    tech = {0.25, 0.75}, --科技
                    troop = {0.25, 0.75}, --行军
                    tankadd = {0.25, 0.75}, --造船
                    tankdiy = {0.25, 0.75}, --改船
                    building = {0.25, 0.75}, --建筑
                    prop = {0.25, 0.75}, --道具 
                },

                --开启顺序, 从第一天开始，每天0点依次开启一个
                order = {"tech", "troop", "tankadd", "tankdiy", "building", "prop"},
            
            },

        },

        --月度签到
        monthlysign = {
             multiSelectType=true,
             [1] = {
                 type=1,
                 sortId=2,
				 version=1,
                 serverreward = {
                     --免费领奖
                     freereward = {
                     [1] = {r={props_p20=4}, vip=-1},
                     [2] = {r={props_p19=20}, vip=-1},
                     [3] = {r={props_p5=1}, vip=-1},
                     [4] = {r={props_p283=1}, vip=1},
                     [5] = {r={troops_a10005=25}, vip=-1},
                     [6] = {r={props_p277=20}, vip=-1},
                     [7] = {r={userinfo_gems=50}, vip=2},
                     [8] = {r={props_p267=1}, vip=3},
                     [9] = {r={props_p47=5}, vip=-1},
                     [10] = {r={props_p42=1}, vip=-1},
                     [11] = {r={props_p276=10}, vip=4},
                     [12] = {r={props_p17=1}, vip=-1},
                     [13] = {r={props_p13=1}, vip=-1},
                     [14] = {r={props_p267=1}, vip=5},
                     [15] = {r={props_p43=1}, vip=-1},
                     [16] = {r={troops_a10035=25}, vip=-1},
                     [17] = {r={props_p2=1}, vip=-1},
                     [18] = {r={props_p275=5}, vip=6},
                     [19] = {r={props_p14=1}, vip=-1},
                     [20] = {r={props_p47=5}, vip=-1},
                     [21] = {r={props_p15=2}, vip=-1},
                     [22] = {r={userinfo_gems=50}, vip=7},
                     [23] = {r={props_p20=5}, vip=-1},
                     [24] = {r={props_p33=3}, vip=-1},
                     [25] = {r={props_p18=1}, vip=-1},
                     [26] = {r={props_p672=10}, vip=8},
                     [27] = {r={props_p36=2}, vip=-1},
                     [28] = {r={props_p19=20}, vip=-1},
                     [29] = {r={userinfo_gems=50}, vip=9},
                     },
                     --付费领奖
                     payreward ={
                     [1] = {r={props_p267=1,props_p266=1,props_p279=1,},},
                     [2] = {r={props_p277=30,props_p276=10,props_p275=5,},},
                     [3] = {r={props_p46=1,props_p45=1,props_p14=1,},},
                     [4] = {r={props_p278=5,props_p279=5,},},
                     [5] = {r={userinfo_gems=100,},},
                     [6] = {r={props_p33=3,props_p36=3,},},
                     [7] = {r={props_p267=2,},},
                     [8] = {r={userinfo_gems=188,},},
                     [9] = {r={props_p47=20,},},
                     [10] = {r={troops_a10005=50,},},
                     [11] = {r={troops_a10082=15,troops_a10073=15,},},
                     [12] = {r={props_p17=5,},},
                     [13] = {r={troops_a10043=20,},},
                     [14] = {r={userinfo_gems=166,},},
                     [15] = {r={troops_a10082=20,},},
                     [16] = {r={troops_a10035=50,},},
                     [17] = {r={props_p3=1,},},
                     [18] = {r={troops_a10073=20,},},
                     [19] = {r={troops_a10005=20,troops_a10053=15,troops_a10043=5,},},
                     [20] = {r={props_p13=10,},},
                     [21] = {r={troops_a10073=20,},},
                     [22] = {r={userinfo_gems=188,},},
                     [23] = {r={props_p20=10,},},
                     [24] = {r={props_p19=20,props_p47=10,props_p15=1,},},
                     [25] = {r={props_p18=2,props_p17=2,},},
                     [26] = {r={props_p672=10,},},
                     [27] = {r={troops_a10053=15,userinfo_gems=60,},},
                     [28] = {r={troops_a10073=20,},},
                     [29] = {r={userinfo_gems=188,},},
                     },
                 },
                     
                 showReward ={
                     --免费领奖
                     freereward={
                         -- [索引]={r={可领取奖励},vip=vip达到多少级才能领双倍，若vip=-1则表示不支持双倍奖励, m =月，d=日 }
                         [1] = {r={p={p20=4,index=1},},vip=-1,m=2,d=1},
                         [2] = {r={p={p19=20,index=1},},vip=-1,m=2,d=2},
                         [3] = {r={p={p5=1,index=1},},vip=-1,m=2,d=3},
                         [4] = {r={p={p283=1,index=1},},vip=1,m=2,d=4},
                         [5] = {r={o={a10005=25,index=1},},vip=-1,m=2,d=5},
                         [6] = {r={p={p277=20,index=1},},vip=-1,m=2,d=6},
                         [7] = {r={u={gems=50,index=1},},vip=2,m=2,d=7},
                         [8] = {r={p={p267=1,index=1},},vip=3,m=2,d=8},
                         [9] = {r={p={p47=5,index=1},},vip=-1,m=2,d=9},
                         [10] = {r={p={p42=1,index=1},},vip=-1,m=2,d=10},
                         [11] = {r={p={p276=10,index=1},},vip=4,m=2,d=11},
                         [12] = {r={p={p17=1,index=1},},vip=-1,m=2,d=12},
                         [13] = {r={p={p13=1,index=1},},vip=-1,m=2,d=13},
                         [14] = {r={p={p267=1,index=1},},vip=5,m=2,d=14},
                         [15] = {r={p={p43=1,index=1},},vip=-1,m=2,d=15},
                         [16] = {r={o={a10035=25,index=1},},vip=-1,m=2,d=16},
                         [17] = {r={p={p2=1,index=1},},vip=-1,m=2,d=17},
                         [18] = {r={p={p275=5,index=1},},vip=6,m=2,d=18},
                         [19] = {r={p={p14=1,index=1},},vip=-1,m=2,d=19},
                         [20] = {r={p={p47=5,index=1},},vip=-1,m=2,d=20},
                         [21] = {r={p={p15=2,index=1},},vip=-1,m=2,d=21},
                         [22] = {r={u={gems=50,index=1},},vip=7,m=2,d=22},
                         [23] = {r={p={p20=5,index=1},},vip=-1,m=2,d=23},
                         [24] = {r={p={p33=3,index=1},},vip=-1,m=2,d=24},
                         [25] = {r={p={p18=1,index=1},},vip=-1,m=2,d=25},
                         [26] = {r={p={p672=10,index=1},},vip=8,m=2,d=26},
                         [27] = {r={p={p36=2,index=1},},vip=-1,m=2,d=27},
                         [28] = {r={p={p19=20,index=1},},vip=-1,m=2,d=28},
                         [29] = {r={u={gems=50,index=1},},vip=9,m=2,d=29},
                     },
                     -- 付费领奖
                     payreward ={
                         --[索引]={r={可领取奖励},f=节日编号（1除夕 2春节 3情人节 4元宵节 5活动结束日），f=0表示不是任何节日，普通显示}
                         [1]={r={p={{p267=1,index=1},{p266=1,index=2},{p279=1,index=3},},},f=0,m=2,d=1,sf=1},
                         [2]={r={p={{p277=30,index=1},{p276=10,index=2},{p275=5,index=3},},},f=0,m=2,d=2,sf=1},
                         [3]={r={p={{p46=1,index=1},{p45=1,index=2},{p14=1,index=3},},},f=0,m=2,d=3,sf=1},
                         [4]={r={p={{p278=5,index=1},{p279=5,index=2},},},f=0,m=2,d=4,sf=1},
                         [5]={r={u={{gems=100,index=1},},},f=0,m=2,d=5,sf=1},
                         [6]={r={p={{p33=3,index=1},{p36=3,index=2},},},f=0,m=2,d=6,sf=1},
                         [7]={r={p={{p267=2,index=1},},},f=1,m=2,d=7,sf=1},
                         [8]={r={u={{gems=188,index=1},},},f=2,m=2,d=8,sf=2},
                         [9]={r={p={{p47=20,index=1},},},f=0,m=2,d=9,sf=2},
                         [10]={r={o={{a10005=50,index=1},},},f=0,m=2,d=10,sf=2},
                         [11]={r={o={{a10082=15,index=1},{a10073=15,index=2},},},f=0,m=2,d=11,sf=2},
                         [12]={r={p={{p17=5,index=1},},},f=0,m=2,d=12,sf=2},
                         [13]={r={o={{a10043=20,index=1},},},f=0,m=2,d=13,sf=2},
                         [14]={r={u={{gems=166,index=1},},},f=3,m=2,d=14,sf=3},
                         [15]={r={o={{a10082=20,index=1},},},f=0,m=2,d=15,sf=2},
                         [16]={r={o={{a10035=50,index=1},},},f=0,m=2,d=16,sf=2},
                         [17]={r={p={{p3=1,index=1},},},f=0,m=2,d=17,sf=2},
                         [18]={r={o={{a10073=20,index=1},},},f=0,m=2,d=18,sf=2},
                         [19]={r={o={{a10005=20,index=1},{a10053=15,index=2},{a10043=5,index=3},},},f=0,m=2,d=19,sf=2},
                         [20]={r={p={{p13=10,index=1},},},f=0,m=2,d=20,sf=2},
                         [21]={r={o={{a10073=20,index=1},},},f=0,m=2,d=21,sf=2},
                         [22]={r={u={{gems=188,index=1},},},f=4,m=2,d=22,sf=4},
                         [23]={r={p={{p20=10,index=1},},},f=0,m=2,d=23,sf=4},
                         [24]={r={p={{p19=20,index=1},{p47=10,index=2},{p15=1,index=3},},},f=0,m=2,d=24,sf=4},
                         [25]={r={p={{p18=2,index=1},{p17=2,index=2},},},f=0,m=2,d=25,sf=4},
                         [26]={r={p={{p672=10,index=1},},},f=0,m=2,d=26,sf=4},
                         [27]={r={o={{a10053=15,index=1},},u={{gems=60,index=2},},},f=0,m=2,d=27,sf=4},
                         [28]={r={o={{a10073=20,index=1},},},f=0,m=2,d=28,sf=4},
                         [29]={r={u={{gems=188,index=1},},},f=5,m=2,d=29,sf=4},
                     },
                 },
             },
     [2] = {
         type=1,
         sortId=2,
         version=2,
         serverreward = {
             --免费领奖
             freereward = {
             [1] = {r={alien_r1=100}, vip=-1},
             [2] = {r={props_p19=8}, vip=-1},
             [3] = {r={props_p282=2}, vip=1},
             [4] = {r={troops_a10006=15}, vip=-1},
             [5] = {r={userinfo_gems=50}, vip=-1},
             [6] = {r={props_p1286=1}, vip=2},
             [7] = {r={alien_r2=50}, vip=-1},
             [8] = {r={props_p5=1}, vip=-1},
             [9] = {r={props_p20=3}, vip=3},
             [10] = {r={troops_a10026=15}, vip=-1},
             [11] = {r={props_p1287=1}, vip=-1},
             [12] = {r={userinfo_gems=50}, vip=4},
             [13] = {r={alien_r4=40}, vip=-1},
             [14] = {r={props_p47=5}, vip=-1},
             [15] = {r={props_p276=3}, vip=5},
             [16] = {r={troops_a10016=15}, vip=-1},
             [17] = {r={props_p4=1}, vip=-1},
             [18] = {r={props_p275=2}, vip=6},
             [19] = {r={alien_r5=40}, vip=-1},
             [20] = {r={props_p43=1}, vip=-1},
             [21] = {r={props_p672=2}, vip=7},
             [22] = {r={props_p20=3}, vip=-1},
             [23] = {r={props_p1286=1}, vip=-1},
             [24] = {r={props_p282=2}, vip=8},
             [25] = {r={alien_r6=10}, vip=-1},
             [26] = {r={props_p1287=1}, vip=-1},
             [27] = {r={props_p20=3}, vip=-1},
             [28] = {r={troops_a10036=15}, vip=-1},
             [29] = {r={props_p18=1}, vip=-1},
             [30] = {r={props_p672=3}, vip=9},
             [31] = {r={props_p20=3}, vip=-1},
             [32] = {r={props_p17=1}, vip=-1},
             [33] = {r={userinfo_gems=50}, vip=10},
             },
             --付费领奖
             payreward ={
             [1] = {r={props_p278=5,props_p4=2,props_p282=1,},},
             [2] = {r={props_p1286=1,alien_r6=10,},},
             [3] = {r={troops_a10044=10,troops_a10054=5,troops_a10064=5,},},
             [4] = {r={props_p277=30,props_p47=10,props_p34=3,},},
             [5] = {r={userinfo_gems=100,},},
             [6] = {r={troops_a10054=15,troops_a10064=5,troops_a10074=5,},},
             [7] = {r={props_p1287=1,alien_r4=40,},},
             [8] = {r={props_p276=10,props_p275=5,props_p282=1,},},
             [9] = {r={troops_a10064=20,troops_a10074=5,troops_a10083=5,},},
             [10] = {r={userinfo_gems=166,},},
             [11] = {r={props_p45=1,props_p20=5,props_p14=2,},},
             [12] = {r={troops_a10074=15,troops_a10083=5,troops_a10114=5,},},
             [13] = {r={props_p1287=1,props_p20=5,},},
             [14] = {r={props_p19=20,props_p47=10,},},
             [15] = {r={userinfo_gems=188,},},
             [16] = {r={troops_a10083=15,troops_a10114=5,troops_a10094=5,},},
             [17] = {r={props_p1286=1,props_p20=5,},},
             [18] = {r={props_p279=5,alien_r1=100,},},
             [19] = {r={props_p267=1,},},
             [20] = {r={userinfo_gems=166,},},
             [21] = {r={troops_a10114=15,troops_a10094=5,troops_a10124=5,},},
             [22] = {r={props_p672=5,alien_r2=80,},},
             [23] = {r={props_p267=1,},},
             [24] = {r={troops_a10094=20,troops_a10124=5,troops_a10044=5,},},
             [25] = {r={userinfo_gems=188,},},
             [26] = {r={props_p1287=1,props_p20=5,},},
             [27] = {r={props_p279=1,props_p13=10,},},
             [28] = {r={props_p19=15,props_p17=1,props_p15=1,},},
             [29] = {r={troops_a10124=15,troops_a10044=5,troops_a10054=5,},},
             [30] = {r={userinfo_gems=166,},},
             [31] = {r={props_p267=1,},},
             [32] = {r={props_p19=15,alien_r5=40,},},
             [33] = {r={userinfo_gems=188,},},
             },
         },
             
         showReward ={
             --免费领奖
             freereward={
                 -- [索引]={r={可领取奖励},vip=vip达到多少级才能领双倍，若vip=-1则表示不支持双倍奖励, m =月，d=日 }
                 [1] = {r={r={r1=100,index=1},},vip=-1},
                 [2] = {r={p={p19=8,index=1},},vip=-1},
                 [3] = {r={p={p282=2,index=1},},vip=1},
                 [4] = {r={o={a10006=15,index=1},},vip=-1},
                 [5] = {r={u={gems=50,index=1},},vip=-1},
                 [6] = {r={p={p1286=1,index=1},},vip=2},
                 [7] = {r={r={r2=50,index=1},},vip=-1},
                 [8] = {r={p={p5=1,index=1},},vip=-1},
                 [9] = {r={p={p20=3,index=1},},vip=3},
                 [10] = {r={o={a10026=15,index=1},},vip=-1},
                 [11] = {r={p={p1287=1,index=1},},vip=-1},
                 [12] = {r={u={gems=50,index=1},},vip=4},
                 [13] = {r={r={r4=40,index=1},},vip=-1},
                 [14] = {r={p={p47=5,index=1},},vip=-1},
                 [15] = {r={p={p276=3,index=1},},vip=5},
                 [16] = {r={o={a10016=15,index=1},},vip=-1},
                 [17] = {r={p={p4=1,index=1},},vip=-1},
                 [18] = {r={p={p275=2,index=1},},vip=6},
                 [19] = {r={r={r5=40,index=1},},vip=-1},
                 [20] = {r={p={p43=1,index=1},},vip=-1},
                 [21] = {r={p={p672=2,index=1},},vip=7},
                 [22] = {r={p={p20=3,index=1},},vip=-1},
                 [23] = {r={p={p1286=1,index=1},},vip=-1},
                 [24] = {r={p={p282=2,index=1},},vip=8},
                 [25] = {r={r={r6=10,index=1},},vip=-1},
                 [26] = {r={p={p1287=1,index=1},},vip=-1},
                 [27] = {r={p={p20=3,index=1},},vip=-1},
                 [28] = {r={o={a10036=15,index=1},},vip=-1},
                 [29] = {r={p={p18=1,index=1},},vip=-1},
                 [30] = {r={p={p672=3,index=1},},vip=9},
                 [31] = {r={p={p20=3,index=1},},vip=-1},
                 [32] = {r={p={p17=1,index=1},},vip=-1},
                 [33] = {r={u={gems=50,index=1},},vip=10},
             },
             -- 付费领奖
             payreward ={
                 --[索引]={r={可领取奖励},f=节日编号（1除夕 2春节 3情人节 4元宵节 5活动结束日），f=0表示不是任何节日，普通显示}
                 [1]={r={p={{p278=5,index=1},{p4=2,index=2},{p282=1,index=3},},},f=0,sf=0},
                 [2]={r={p={{p1286=1,index=1},},r={{r6=10,index=2},},},f=0,sf=0},
                 [3]={r={o={{a10044=10,index=1},{a10054=5,index=2},{a10064=5,index=3},},},f=0,sf=0},
                 [4]={r={p={{p277=30,index=1},{p47=10,index=2},{p34=3,index=3},},},f=0,sf=0},
                 [5]={r={u={{gems=100,index=1},},},f=0,sf=0},
                 [6]={r={o={{a10054=15,index=1},{a10064=5,index=2},{a10074=5,index=3},},},f=0,sf=0},
                 [7]={r={p={{p1287=1,index=1},},r={{r4=40,index=2},},},f=0,sf=0},
                 [8]={r={p={{p276=10,index=1},{p275=5,index=2},{p282=1,index=3},},},f=0,sf=0},
                 [9]={r={o={{a10064=20,index=1},{a10074=5,index=2},{a10083=5,index=3},},},f=0,sf=0},
                 [10]={r={u={{gems=166,index=1},},},f=0,sf=0},
                 [11]={r={p={{p45=1,index=1},{p20=5,index=2},{p14=2,index=3},},},f=0,sf=0},
                 [12]={r={o={{a10074=15,index=1},{a10083=5,index=2},{a10114=5,index=3},},},f=0,sf=0},
                 [13]={r={p={{p1287=1,index=1},{p20=5,index=2},},},f=0,sf=0},
                 [14]={r={p={{p19=20,index=1},{p47=10,index=2},},},f=0,sf=0},
                 [15]={r={u={{gems=188,index=1},},},f=0,sf=0},
                 [16]={r={o={{a10083=15,index=1},{a10114=5,index=2},{a10094=5,index=3},},},f=0,sf=0},
                 [17]={r={p={{p1286=1,index=1},{p20=5,index=2},},},f=0,sf=0},
                 [18]={r={p={{p279=5,index=1},},r={{r1=100,index=2},},},f=0,sf=0},
                 [19]={r={p={{p267=1,index=1},},},f=0,sf=0},
                 [20]={r={u={{gems=166,index=1},},},f=0,sf=0},
                 [21]={r={o={{a10114=15,index=1},{a10094=5,index=2},{a10124=5,index=3},},},f=0,sf=0},
                 [22]={r={p={{p672=5,index=1},},r={{r2=80,index=2},},},f=0,sf=0},
                 [23]={r={p={{p267=1,index=1},},},f=0,sf=0},
                 [24]={r={o={{a10094=20,index=1},{a10124=5,index=2},{a10044=5,index=3},},},f=0,sf=0},
                 [25]={r={u={{gems=188,index=1},},},f=0,sf=0},
                 [26]={r={p={{p1287=1,index=1},{p20=5,index=2},},},f=0,sf=0},
                 [27]={r={p={{p279=1,index=1},{p13=10,index=2},},},f=0,sf=0},
                 [28]={r={p={{p19=15,index=1},{p17=1,index=2},{p15=1,index=3},},},f=0,sf=0},
                 [29]={r={o={{a10124=15,index=1},{a10044=5,index=2},{a10054=5,index=3},},},f=0,sf=0},
                 [30]={r={u={{gems=166,index=1},},},f=0,sf=0},
                 [31]={r={p={{p267=1,index=1},},},f=0,sf=0},
                 [32]={r={p={{p19=15,index=1},},r={{r5=40,index=2},},},f=0,sf=0},
                 [33]={r={u={{gems=188,index=1},},},f=0,sf=0},
             },
         },
     },
 

             [3] = {
			 type=1,
			 sortId=2,
			 version=3,
			 serverreward = {
				 --免费领奖
				 freereward = {
				 [1] = {r={props_p34=2}, vip=-1},
				 [2] = {r={props_p19=8}, vip=-1},
				 [3] = {r={props_p282=2}, vip=1},
				 [4] = {r={troops_a10005=15}, vip=-1},
				 [5] = {r={userinfo_gems=50}, vip=-1},
				 [6] = {r={props_p1286=1}, vip=2},
				 [7] = {r={props_p32=2}, vip=-1},
				 [8] = {r={props_p5=1}, vip=-1},
				 [9] = {r={props_p20=3}, vip=3},
				 [10] = {r={troops_a10025=15}, vip=-1},
				 [11] = {r={props_p1287=1}, vip=-1},
				 [12] = {r={userinfo_gems=50}, vip=4},
				 [13] = {r={props_p33=2}, vip=-1},
				 [14] = {r={props_p47=5}, vip=-1},
				 [15] = {r={props_p276=3}, vip=5},
				 [16] = {r={troops_a10015=15}, vip=-1},
				 [17] = {r={props_p2=1}, vip=-1},
				 [18] = {r={props_p275=2}, vip=6},
				 [19] = {r={props_p36=2}, vip=-1},
				 [20] = {r={props_p43=1}, vip=-1},
				 [21] = {r={props_p672=2}, vip=7},
				 [22] = {r={props_p20=3}, vip=-1},
				 [23] = {r={props_p1286=1}, vip=-1},
				 [24] = {r={props_p282=2}, vip=8},
				 [25] = {r={props_p35=2}, vip=-1},
				 [26] = {r={props_p1287=1}, vip=-1},
				 [27] = {r={props_p20=3}, vip=9},
				 [28] = {r={troops_a10035=15}, vip=-1},
				 [29] = {r={props_p18=1}, vip=-1},
				 [30] = {r={userinfo_gems=50}, vip=10},
				 },
				 --付费领奖
				 payreward ={
				 [1] = {r={props_p278=5,props_p32=2,props_p282=1,},},
				 [2] = {r={props_p1286=1,props_p3=1,},},
				 [3] = {r={troops_a10043=10,troops_a10053=5,troops_a10063=5,},},
				 [4] = {r={props_p277=30,props_p47=10,props_p34=3,},},
				 [5] = {r={userinfo_gems=100,},},
				 [6] = {r={troops_a10053=15,troops_a10063=5,troops_a10073=5,},},
				 [7] = {r={props_p1287=1,props_p35=2,},},
				 [8] = {r={props_p276=10,props_p275=5,props_p282=1,},},
				 [9] = {r={troops_a10063=20,troops_a10073=5,troops_a10082=5,},},
				 [10] = {r={userinfo_gems=188,},},
				 [11] = {r={props_p45=1,props_p20=5,props_p14=2,},},
				 [12] = {r={troops_a10073=15,troops_a10082=5,troops_a10113=5,},},
				 [13] = {r={props_p1287=1,props_p20=5,},},
				 [14] = {r={props_p19=20,props_p47=10,},},
				 [15] = {r={userinfo_gems=166,},},
				 [16] = {r={troops_a10082=15,troops_a10113=5,troops_a10093=5,},},
				 [17] = {r={props_p1286=1,props_p20=5,},},
				 [18] = {r={props_p279=5,props_p36=3,},},
				 [19] = {r={props_p267=1,},},
				 [20] = {r={userinfo_gems=188,},},
				 [21] = {r={troops_a10113=15,troops_a10093=5,troops_a10123=5,},},
				 [22] = {r={props_p672=5,props_p35=3,},},
				 [23] = {r={props_p267=1,},},
				 [24] = {r={troops_a10093=20,troops_a10123=5,troops_a10043=5,},},
				 [25] = {r={userinfo_gems=166,},},
				 [26] = {r={props_p1287=1,props_p20=5,},},
				 [27] = {r={props_p279=1,props_p13=10,},},
				 [28] = {r={troops_a10123=15,troops_a10043=5,troops_a10053=5,},},
				 [29] = {r={props_p19=15,props_p17=1,props_p15=1,},},
				 [30] = {r={userinfo_gems=188,},},
				 },
			 },
				 
			 showReward ={
				 --免费领奖
				 freereward={
					 -- [索引]={r={可领取奖励},vip=vip达到多少级才能领双倍，若vip=-1则表示不支持双倍奖励, m =月，d=日 }
					 [1] = {r={p={p34=2,index=1},},vip=-1},
					 [2] = {r={p={p19=8,index=1},},vip=-1},
					 [3] = {r={p={p282=2,index=1},},vip=1},
					 [4] = {r={o={a10005=15,index=1},},vip=-1},
					 [5] = {r={u={gems=50,index=1},},vip=-1},
					 [6] = {r={p={p1286=1,index=1},},vip=2},
					 [7] = {r={p={p32=2,index=1},},vip=-1},
					 [8] = {r={p={p5=1,index=1},},vip=-1},
					 [9] = {r={p={p20=3,index=1},},vip=3},
					 [10] = {r={o={a10025=15,index=1},},vip=-1},
					 [11] = {r={p={p1287=1,index=1},},vip=-1},
					 [12] = {r={u={gems=50,index=1},},vip=4},
					 [13] = {r={p={p33=2,index=1},},vip=-1},
					 [14] = {r={p={p47=5,index=1},},vip=-1},
					 [15] = {r={p={p276=3,index=1},},vip=5},
					 [16] = {r={o={a10015=15,index=1},},vip=-1},
					 [17] = {r={p={p2=1,index=1},},vip=-1},
					 [18] = {r={p={p275=2,index=1},},vip=6},
					 [19] = {r={p={p36=2,index=1},},vip=-1},
					 [20] = {r={p={p43=1,index=1},},vip=-1},
					 [21] = {r={p={p672=2,index=1},},vip=7},
					 [22] = {r={p={p20=3,index=1},},vip=-1},
					 [23] = {r={p={p1286=1,index=1},},vip=-1},
					 [24] = {r={p={p282=2,index=1},},vip=8},
					 [25] = {r={p={p35=2,index=1},},vip=-1},
					 [26] = {r={p={p1287=1,index=1},},vip=-1},
					 [27] = {r={p={p20=3,index=1},},vip=9},
					 [28] = {r={o={a10035=15,index=1},},vip=-1},
					 [29] = {r={p={p18=1,index=1},},vip=-1},
					 [30] = {r={u={gems=50,index=1},},vip=10},
				 },
				 -- 付费领奖
				 payreward ={
					 --[索引]={r={可领取奖励},f=节日编号（1除夕 2春节 3情人节 4元宵节 5活动结束日），f=0表示不是任何节日，普通显示}
					 [1]={r={p={{p278=5,index=1},{p32=2,index=2},{p282=1,index=3},},},f=0,sf=0},
					 [2]={r={p={{p1286=1,index=1},{p3=1,index=2},},},f=0,sf=0},
					 [3]={r={o={{a10043=10,index=1},{a10053=5,index=2},{a10063=5,index=3},},},f=0,sf=0},
					 [4]={r={p={{p277=30,index=1},{p47=10,index=2},{p34=3,index=3},},},f=0,sf=0},
					 [5]={r={u={{gems=100,index=1},},},f=0,sf=0},
					 [6]={r={o={{a10053=15,index=1},{a10063=5,index=2},{a10073=5,index=3},},},f=0,sf=0},
					 [7]={r={p={{p1287=1,index=1},{p35=2,index=2},},},f=0,sf=0},
					 [8]={r={p={{p276=10,index=1},{p275=5,index=2},{p282=1,index=3},},},f=0,sf=0},
					 [9]={r={o={{a10063=20,index=1},{a10073=5,index=2},{a10082=5,index=3},},},f=0,sf=0},
					 [10]={r={u={{gems=188,index=1},},},f=0,sf=0},
					 [11]={r={p={{p45=1,index=1},{p20=5,index=2},{p14=2,index=3},},},f=0,sf=0},
					 [12]={r={o={{a10073=15,index=1},{a10082=5,index=2},{a10113=5,index=3},},},f=0,sf=0},
					 [13]={r={p={{p1287=1,index=1},{p20=5,index=2},},},f=0,sf=0},
					 [14]={r={p={{p19=20,index=1},{p47=10,index=2},},},f=0,sf=0},
					 [15]={r={u={{gems=166,index=1},},},f=0,sf=0},
					 [16]={r={o={{a10082=15,index=1},{a10113=5,index=2},{a10093=5,index=3},},},f=0,sf=0},
					 [17]={r={p={{p1286=1,index=1},{p20=5,index=2},},},f=0,sf=0},
					 [18]={r={p={{p279=5,index=1},{p36=3,index=2},},},f=0,sf=0},
					 [19]={r={p={{p267=1,index=1},},},f=0,sf=0},
					 [20]={r={u={{gems=188,index=1},},},f=0,sf=0},
					 [21]={r={o={{a10113=15,index=1},{a10093=5,index=2},{a10123=5,index=3},},},f=0,sf=0},
					 [22]={r={p={{p672=5,index=1},{p35=3,index=2},},},f=0,sf=0},
					 [23]={r={p={{p267=1,index=1},},},f=0,sf=0},
					 [24]={r={o={{a10093=20,index=1},{a10123=5,index=2},{a10043=5,index=3},},},f=0,sf=0},
					 [25]={r={u={{gems=166,index=1},},},f=0,sf=0},
					 [26]={r={p={{p1287=1,index=1},{p20=5,index=2},},},f=0,sf=0},
					 [27]={r={p={{p279=1,index=1},{p13=10,index=2},},},f=0,sf=0},
					 [28]={r={o={{a10123=15,index=1},{a10043=5,index=2},{a10053=5,index=3},},},f=0,sf=0},
					 [29]={r={p={{p19=15,index=1},{p17=1,index=2},{p15=1,index=3},},},f=0,sf=0},
					 [30]={r={u={{gems=188,index=1},},},f=0,sf=0},
				 },
			 },
		 },
	},
        -- 两将活动
twohero={
    multiSelectType=true,
    [1]={ 
        sortId=952,
        type=1,
        cost=58,
        mulCost=522,
        rankpoint=200,
        serverreward={
            scorelist={ 
                {2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{40,60},{140,210},{10,15},{10,15},{140,210},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15},{40,60},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15}
            },
            pool={
                {100},
                {400,10000,500,500,10000,500,500,500,500,500,500,400,500,400,500,500,500,500,500,500,400,500,10,50,50,50,50,50,50,50,50,50,50,10,50,10,50,50,50,50,50,50,10,50},
                {{"hero_s4",{num=2,index=1}},{"hero_s9",{num=2,index=2}},{"hero_s11",{num=2,index=3}},{"hero_s12",{num=2,index=4}},{"hero_s19",{num=2,index=5}},{"hero_s21",{num=2,index=6}},{"hero_s22",{num=2,index=7}},{"hero_s23",{num=2,index=8}},{"hero_s27",{num=2,index=9}},{"hero_s28",{num=2,index=10}},{"hero_s29",{num=2,index=11}},{"hero_s30",{num=2,index=12}},{"hero_s31",{num=2,index=13}},{"hero_s32",{num=2,index=14}},{"hero_s33",{num=2,index=15}},{"hero_s34",{num=2,index=16}},{"hero_s35",{num=2,index=17}},{"hero_s36",{num=2,index=18}},{"hero_s37",{num=2,index=19}},{"hero_s38",{num=2,index=20}},{"hero_s39",{num=2,index=21}},{"hero_s40",{num=2,index=22}},{"hero_h4",{num=2,index=23}},{"hero_h9",{num=3,index=24}},{"hero_h11",{num=1,index=25}},{"hero_h12",{num=1,index=26}},{"hero_h19",{num=3,index=27}},{"hero_h21",{num=1,index=28}},{"hero_h22",{num=1,index=29}},{"hero_h23",{num=1,index=30}},{"hero_h27",{num=1,index=31}},{"hero_h28",{num=1,index=32}},{"hero_h29",{num=1,index=33}},{"hero_h30",{num=2,index=34}},{"hero_h31",{num=1,index=35}},{"hero_h32",{num=2,index=36}},{"hero_h33",{num=1,index=37}},{"hero_h34",{num=1,index=38}},{"hero_h35",{num=1,index=39}},{"hero_h36",{num=1,index=40}},{"hero_h37",{num=1,index=41}},{"hero_h38",{num=1,index=42}},{"hero_h39",{num=2,index=43}},{"hero_h40",{num=1,index=44}}},
            },
            rankReward={
                {range={1,1},serverReward={hero_h9=4,hero_h19=4,hero_h30=3}},
                {range={2,2},serverReward={hero_h9=3,hero_h19=3}},
                {range={3,3},serverReward={hero_h30=3}},
                {range={4,5},serverReward={props_p818=20,props_p819=50,props_p448=20}},
                {range={6,10},serverReward={props_p818=10,props_p819=25,props_p448=10}},
                {range={11,20},serverReward={props_p818=5,props_p819=10,props_p448=5}},
            },
        },
        rankReward={
            {{1,1},{h={{h9=4,index=1},{h19=4,index=2},{h30=3,index=3}}}},
            {{2,2},{h={{h9=3,index=1},{h19=3,index=2}}}},
            {{3,3},{h={{h30=3,index=1}}}},
            {{4,5},{p={{p818=20,index=1},{p819=50,index=2},{p448=20,index=3}}}},
            {{6,10},{p={{p818=10,index=1},{p819=25,index=2},{p448=10,index=3}}}},
            {{11,20},{p={{p818=5,index=1},{p819=10,index=2},{p448=5,index=3}}}},
        },
        showhero={
            {h={{h9=3,index=1}}},
            {h={{h19=3,index=2}}},
        },
    },
    [2]={ 
        sortId=952,
        type=1,
        cost=58,
        mulCost=522,
        rankpoint=200,
        serverreward={
            scorelist={ 
                {2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{40,60},{140,210},{10,15},{10,15},{140,210},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15},{40,60},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15}
            },
            pool={
                {100},
                {400,10000,500,500,10000,500,500,500,500,500,500,400,500,400,500,500,500,500,500,500,400,500,10,50,50,50,50,50,50,50,50,50,50,10,50,10,50,50,50,50,50,50,10,50},
                {{"hero_s4",{num=2,index=1}},{"hero_s8",{num=2,index=2}},{"hero_s11",{num=2,index=3}},{"hero_s12",{num=2,index=4}},{"hero_s18",{num=2,index=5}},{"hero_s21",{num=2,index=6}},{"hero_s22",{num=2,index=7}},{"hero_s23",{num=2,index=8}},{"hero_s27",{num=2,index=9}},{"hero_s28",{num=2,index=10}},{"hero_s29",{num=2,index=11}},{"hero_s30",{num=2,index=12}},{"hero_s31",{num=2,index=13}},{"hero_s32",{num=2,index=14}},{"hero_s33",{num=2,index=15}},{"hero_s34",{num=2,index=16}},{"hero_s35",{num=2,index=17}},{"hero_s36",{num=2,index=18}},{"hero_s37",{num=2,index=19}},{"hero_s38",{num=2,index=20}},{"hero_s39",{num=2,index=21}},{"hero_s40",{num=2,index=22}},{"hero_h4",{num=2,index=23}},{"hero_h8",{num=3,index=24}},{"hero_h11",{num=1,index=25}},{"hero_h12",{num=1,index=26}},{"hero_h18",{num=3,index=27}},{"hero_h21",{num=1,index=28}},{"hero_h22",{num=1,index=29}},{"hero_h23",{num=1,index=30}},{"hero_h27",{num=1,index=31}},{"hero_h28",{num=1,index=32}},{"hero_h29",{num=1,index=33}},{"hero_h30",{num=2,index=34}},{"hero_h31",{num=1,index=35}},{"hero_h32",{num=2,index=36}},{"hero_h33",{num=1,index=37}},{"hero_h34",{num=1,index=38}},{"hero_h35",{num=1,index=39}},{"hero_h36",{num=1,index=40}},{"hero_h37",{num=1,index=41}},{"hero_h38",{num=1,index=42}},{"hero_h39",{num=2,index=43}},{"hero_h40",{num=1,index=44}}},
            },
            rankReward={
                {range={1,1},serverReward={hero_h8=4,hero_h18=4,hero_h32=3}},
                {range={2,2},serverReward={hero_h8=3,hero_h18=3}},
                {range={3,3},serverReward={hero_h32=3}},
                {range={4,5},serverReward={props_p818=20,props_p819=50,props_p448=20}},
                {range={6,10},serverReward={props_p818=10,props_p819=25,props_p448=10}},
                {range={11,20},serverReward={props_p818=5,props_p819=10,props_p448=5}},
            },
        },
        rankReward={
            {{1,1},{h={{h8=4,index=1},{h18=4,index=2},{h32=3,index=3}}}},
            {{2,2},{h={{h8=3,index=1},{h18=3,index=2}}}},
            {{3,3},{h={{h32=3,index=1}}}},
            {{4,5},{p={{p818=20,index=1},{p819=50,index=2},{p448=20,index=3}}}},
            {{6,10},{p={{p818=10,index=1},{p819=25,index=2},{p448=10,index=3}}}},
            {{11,20},{p={{p818=5,index=1},{p819=10,index=2},{p448=5,index=3}}}},
        },
        showhero={
            {h={{h8=3,index=1}}},
            {h={{h18=3,index=2}}},
        },
    },
    [3]={ 
        sortId=952,
        type=1,
        cost=58,
        mulCost=522,
        rankpoint=200,
        serverreward={
            scorelist={ 
                {2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{40,60},{140,210},{10,15},{10,15},{140,210},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15},{40,60},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15}
            },
            pool={
                {100},
                {400,10000,500,500,10000,500,500,500,500,500,500,400,500,400,500,500,500,500,500,500,400,500,10,50,50,50,50,50,50,50,50,50,50,10,50,10,50,50,50,50,50,50,10,50},
                {{"hero_s4",{num=2,index=1}},{"hero_s7",{num=2,index=2}},{"hero_s11",{num=2,index=3}},{"hero_s12",{num=2,index=4}},{"hero_s17",{num=2,index=5}},{"hero_s21",{num=2,index=6}},{"hero_s22",{num=2,index=7}},{"hero_s23",{num=2,index=8}},{"hero_s27",{num=2,index=9}},{"hero_s28",{num=2,index=10}},{"hero_s29",{num=2,index=11}},{"hero_s30",{num=2,index=12}},{"hero_s31",{num=2,index=13}},{"hero_s32",{num=2,index=14}},{"hero_s33",{num=2,index=15}},{"hero_s34",{num=2,index=16}},{"hero_s35",{num=2,index=17}},{"hero_s36",{num=2,index=18}},{"hero_s37",{num=2,index=19}},{"hero_s38",{num=2,index=20}},{"hero_s39",{num=2,index=21}},{"hero_s40",{num=2,index=22}},{"hero_h4",{num=2,index=23}},{"hero_h7",{num=3,index=24}},{"hero_h11",{num=1,index=25}},{"hero_h12",{num=1,index=26}},{"hero_h17",{num=3,index=27}},{"hero_h21",{num=1,index=28}},{"hero_h22",{num=1,index=29}},{"hero_h23",{num=1,index=30}},{"hero_h27",{num=1,index=31}},{"hero_h28",{num=1,index=32}},{"hero_h29",{num=1,index=33}},{"hero_h30",{num=2,index=34}},{"hero_h31",{num=1,index=35}},{"hero_h32",{num=2,index=36}},{"hero_h33",{num=1,index=37}},{"hero_h34",{num=1,index=38}},{"hero_h35",{num=1,index=39}},{"hero_h36",{num=1,index=40}},{"hero_h37",{num=1,index=41}},{"hero_h38",{num=1,index=42}},{"hero_h39",{num=2,index=43}},{"hero_h40",{num=1,index=44}}},
            },
            rankReward={
                {range={1,1},serverReward={hero_h7=4,hero_h17=4,hero_h30=3}},
                {range={2,2},serverReward={hero_h7=3,hero_h17=3}},
                {range={3,3},serverReward={hero_h30=3}},
                {range={4,5},serverReward={props_p818=20,props_p819=50,props_p448=20}},
                {range={6,10},serverReward={props_p818=10,props_p819=25,props_p448=10}},
                {range={11,20},serverReward={props_p818=5,props_p819=10,props_p448=5}},
            },
        },
        rankReward={
            {{1,1},{h={{h7=4,index=1},{h17=4,index=2},{h30=3,index=3}}}},
            {{2,2},{h={{h7=3,index=1},{h17=3,index=2}}}},
            {{3,3},{h={{h30=3,index=1}}}},
            {{4,5},{p={{p818=20,index=1},{p819=50,index=2},{p448=20,index=3}}}},
            {{6,10},{p={{p818=10,index=1},{p819=25,index=2},{p448=10,index=3}}}},
            {{11,20},{p={{p818=5,index=1},{p819=10,index=2},{p448=5,index=3}}}},
        },
        showhero={
            {h={{h7=3,index=1}}},
            {h={{h17=3,index=2}}},
        },
    },
    [4]={ 
        sortId=952,
        type=1,
        cost=58,
        mulCost=522,
        rankpoint=200,
        serverreward={
            scorelist={ 
                {2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{2,3},{40,60},{140,210},{10,15},{10,15},{140,210},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15},{40,60},{10,15},{10,15},{10,15},{10,15},{10,15},{10,15},{40,60},{10,15}
            },
            pool={
                {100},
                {400,10000,500,500,10000,500,500,500,500,500,500,400,500,400,500,500,500,500,500,500,400,500,10,50,50,50,50,50,50,50,50,50,50,10,50,10,50,50,50,50,50,50,10,50},
                {{"hero_s4",{num=2,index=1}},{"hero_s6",{num=2,index=2}},{"hero_s11",{num=2,index=3}},{"hero_s12",{num=2,index=4}},{"hero_s16",{num=2,index=5}},{"hero_s21",{num=2,index=6}},{"hero_s22",{num=2,index=7}},{"hero_s23",{num=2,index=8}},{"hero_s27",{num=2,index=9}},{"hero_s28",{num=2,index=10}},{"hero_s29",{num=2,index=11}},{"hero_s30",{num=2,index=12}},{"hero_s31",{num=2,index=13}},{"hero_s32",{num=2,index=14}},{"hero_s33",{num=2,index=15}},{"hero_s34",{num=2,index=16}},{"hero_s35",{num=2,index=17}},{"hero_s36",{num=2,index=18}},{"hero_s37",{num=2,index=19}},{"hero_s38",{num=2,index=20}},{"hero_s39",{num=2,index=21}},{"hero_s40",{num=2,index=22}},{"hero_h4",{num=2,index=23}},{"hero_h6",{num=3,index=24}},{"hero_h11",{num=1,index=25}},{"hero_h12",{num=1,index=26}},{"hero_h16",{num=3,index=27}},{"hero_h21",{num=1,index=28}},{"hero_h22",{num=1,index=29}},{"hero_h23",{num=1,index=30}},{"hero_h27",{num=1,index=31}},{"hero_h28",{num=1,index=32}},{"hero_h29",{num=1,index=33}},{"hero_h30",{num=2,index=34}},{"hero_h31",{num=1,index=35}},{"hero_h32",{num=2,index=36}},{"hero_h33",{num=1,index=37}},{"hero_h34",{num=1,index=38}},{"hero_h35",{num=1,index=39}},{"hero_h36",{num=1,index=40}},{"hero_h37",{num=1,index=41}},{"hero_h38",{num=1,index=42}},{"hero_h39",{num=2,index=43}},{"hero_h40",{num=1,index=44}}},
            },
            rankReward={
                {range={1,1},serverReward={hero_h6=4,hero_h16=4,hero_h32=3}},
                {range={2,2},serverReward={hero_h6=3,hero_h16=3}},
                {range={3,3},serverReward={hero_h32=3}},
                {range={4,5},serverReward={props_p818=20,props_p819=50,props_p448=20}},
                {range={6,10},serverReward={props_p818=10,props_p819=25,props_p448=10}},
                {range={11,20},serverReward={props_p818=5,props_p819=10,props_p448=5}},
            },
        },
        rankReward={
            {{1,1},{h={{h6=4,index=1},{h16=4,index=2},{h32=3,index=3}}}},
            {{2,2},{h={{h6=3,index=1},{h16=3,index=2}}}},
            {{3,3},{h={{h32=3,index=1}}}},
            {{4,5},{p={{p818=20,index=1},{p819=50,index=2},{p448=20,index=3}}}},
            {{6,10},{p={{p818=10,index=1},{p819=25,index=2},{p448=10,index=3}}}},
            {{11,20},{p={{p818=5,index=1},{p819=10,index=2},{p448=5,index=3}}}},
        },
        showhero={
            {h={{h6=3,index=1}}},
            {h={{h16=3,index=2}}},
        },
    },
},

         --万圣节大作战
        wanshengjiedazuozhan={
        multiSelectType = true,
        [1]={ --舰队 无异星科技
        type=1,
        sortId=73,
        cost=168,
        pumpkinLife={ --每消灭1个南瓜扣血量
        1,1
        },
        bossLife={ --boss血量
        100,
        100,
        },
        noticeNum=9, --1次性消除数高于此值发公告
        serverreward={
        column=3, --地图列数
        map={ --初始地图
        [1]=1,
        [2]=2,
        [3]=1,
        [4]=1,
        [5]=2,
        [6]=2,
        [7]=1,
        [8]=2,
        [9]=1,
        },
        normal1={ --普通南瓜奖池1
        {100},
        {30,25,30,5,8,2,},
        {{"props_p277",5},{"props_p276",2},{"props_p275",1},{"props_p282",1},{"props_p279",1},{"props_p278",1},},
        },
        normal2={ --普通南瓜奖池2
        {100},
        {20,3,4,9,8,8,8,8,8,8,8,8,},
        {{"props_p601",2},{"props_p19",1},{"props_p446",1},{"props_p447",1},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},},
        },
        normal3={ --特殊南瓜奖池3
        {100},
        {15,25,15,15,15,15,},
        {{"troops_a10043",20},{"troops_a10053",20},{"troops_a10063",20},{"troops_a10073",20},{"troops_a10082",20},{"troops_a10093",20},},
        },
        boss1={ --BOSS奖池1
        {100},
        {25,20,20,8,5,4,10,8,},
        {{"props_p277",300},{"props_p276",60},{"props_p275",30},{"props_p283",2},{"props_p279",10},{"props_p278",10},{"props_p90",1},{"props_p284",1},},
        },
        boss2={ --BOSS奖池2
        {100},
        {10,10,10,10,10,10,10,10,10,10,},
        {{"hero_h4",3},{"hero_h21",3},{"hero_h40",3},{"hero_h10",3},{"hero_h20",3},{"hero_h22",3},{"hero_h28",3},{"hero_h30",3},{"hero_h32",3},{"hero_h37",3},},
        },
         --南瓜出现概率
        pumpkinPool = {{100},{49,49,2},{{"1",1},{"2",1},{"3",1}}},
        },
        reward={
        normal1={p={{p277=5,index=1},{p276=2,index=2},{p275=1,index=3},{p282=1,index=4},{p279=1,index=5},{p278=1,index=6},}},
        normal2={p={{p601=2,index=1},{p19=1,index=2},{p446=1,index=3},{p447=1,index=4},{p611=1,index=5},{p612=1,index=6},{p613=1,index=7},{p614=1,index=8},{p615=1,index=9},{p616=1,index=10},{p617=1,index=11},{p618=1,index=12},}},
		normal3={o={{a10043=20,index=1},{a10053=20,index=2},{a10063=20,index=3},{a10073=20,index=4},{a10082=20,index=5},{a10093=20,index=6},}},
		boss1={p={{p277=300,index=1},{p276=60,index=2},{p275=30,index=3},{p283=2,index=4},{p279=10,index=5},{p278=10,index=6},{p90=1,index=7},{p284=1,index=8},}},
        boss2={h={{h4=3,index=1},{h21=3,index=2},{h40=3,index=3},{h10=3,index=4},{h20=3,index=5},{h22=3,index=6},{h28=3,index=7},{h30=3,index=8},{h32=3,index=9},{h37=3,index=10},}},
        },


        taskList = { --任务 k1 杀死南瓜1 k2 杀死南瓜2 k3 杀死南瓜3 hit 单次消除数量 kb1击杀南瓜1BOSS kb2击杀南瓜2BOSS
        t1={index=1,conditions={type="k1",num=50},serverreward={userinfo_gold=30000000,},reward={u={{gold=30000000},}},},
        t2={index=2,conditions={type="k2",num=50},serverreward={props_p601=30,props_p448=5,},reward={p={{p601=30},{p448=5},}},},
        t3={index=3,conditions={type="k3",num=3},serverreward={troops_a10043=100,troops_a10073=100,troops_a10082=100,},reward={o={{a10043=100},{a10073=100},{a10082=100},}},},
        t4={index=4,conditions={type="kb1",num=3},serverreward={props_p277=100,props_p276=20,props_p275=10,},reward={p={{p277=100},{p276=20},{p275=10},}},},
        t5={index=5,conditions={type="kb2",num=3},serverreward={hero_s27=30,},reward={h={{s27=30},}},},
        t6={index=6,conditions={type="hit",num=7},serverreward={props_p267=2,},reward={p={{p267=2},}},},
        t7={index=7,conditions={type="hit",num=8},serverreward={troops_a10006=30,},reward={o={{a10006=30},}},},
        t8={index=8,conditions={type="hit",num=9},serverreward={props_p230=1,},reward={p={{p230=1},}},},
        }

        },

        [2]={    --阿拉伯低奖励配置                                                 
            type=1,                                                     
            sortId=73,                                                      
            cost=168,                                                       
            pumpkinLife={    --每消灭1个南瓜扣血量                                                   
            1,1                                                     
            },                                                      
            bossLife={   --boss血量                                                   
            100,                                                        
            100,                                                        
            },                                                      
            noticeNum=9,     --1次性消除数高于此值发公告                                                    
            serverreward={                                                      
            column=3,    --地图列数                                                 
            map={    --初始地图                                                 
            [1]=1,                                                      
            [2]=2,                                                      
            [3]=1,                                                      
            [4]=1,                                                      
            [5]=2,                                                      
            [6]=2,                                                      
            [7]=1,                                                      
            [8]=2,                                                      
            [9]=1,                                                      
            },                                                      
            normal1={    --普通南瓜奖池1                                                  
            {100},                                                      
            {   30, 25, 30, 5,  8,  2,  },                          
            {   {"props_p277",5},   {"props_p276",2},   {"props_p275",1},   {"props_p282",1},   {"props_p279",1},   {"props_p278",1},   },                          
            },                                                      
            normal2={    --普通南瓜奖池2                                                  
            {100},                                                      
            {   20, 3,  4,  9,  8,  8,  8,  8,  8,  8,  8,  8,  },  
            {   {"props_p601",2},   {"props_p19",1},    {"props_p446",1},   {"props_p447",1},   {"props_p611",1},   {"props_p612",1},   {"props_p613",1},   {"props_p614",1},   {"props_p615",1},   {"props_p616",1},   {"props_p617",1},   {"props_p618",1},   },  
            },                                                      
            normal3={    --特殊南瓜奖池3                                                  
            {100},                                                      
            {   15, 25, 15, 15, 15, 15, },                          
            {   {"troops_a10004",20},   {"troops_a10014",20},   {"troops_a10024",20},   {"troops_a10034",20},   {"troops_a10005",20},   {"troops_a10015",20},   },                          
            },                                                      
            boss1={  --BOSS奖池1                                                  
            {100},                                                      
            {   25, 20, 20, 8,  5,  4,  10, 8,  },                  
            {   {"props_p277",300}, {"props_p276",60},  {"props_p275",30},  {"props_p283",2},   {"props_p279",10},  {"props_p278",10},  {"props_p90",1},    {"props_p284",1},   },                  
            },                                                      
            boss2={  --BOSS奖池2                                                  
            {100},                                                      
            {   10, 10, 10, 10, 10, 10, 10, 10, 10, 10, },          
            {   {"hero_h4",3},  {"hero_h21",3}, {"hero_h40",3}, {"hero_h10",3}, {"hero_h20",3}, {"hero_h22",3}, {"hero_h28",3}, {"hero_h30",3}, {"hero_h32",3}, {"hero_h37",3}, },          
            },                                                      
             --南瓜出现概率                                                       
            pumpkinPool = {{100},{  49, 49, 2   },  {{"1",1},{"2",1},{"3",1}}},                                 
            },                                                      
            reward={                                                        
            normal1={   p={ {p277=5,index=1},   {p276=2,index=2},   {p275=1,index=3},   {p282=1,index=4},   {p279=1,index=5},   {p278=1,index=6},   }},                     
            normal2={   p={ {p601=2,index=1},   {p19=1,index=2},    {p446=1,index=3},   {p447=1,index=4},   {p611=1,index=5},   {p612=1,index=6},   {p613=1,index=7},   {p614=1,index=8},   {p615=1,index=9},   {p616=1,index=10},  {p617=1,index=11},  {p618=1,index=12},  }},
			normal3={o={{a10004=15,index=1},{a10014=25,index=2},{a10024=15,index=3},{a10034=15,index=4},{a10005=15,index=5},{a10015=15,index=6},}},						
            boss1={ p={ {p277=300,index=1}, {p276=60,index=2},  {p275=30,index=3},  {p283=2,index=4},   {p279=10,index=5},  {p278=10,index=6},      {p90=1,index=7},    {p284=1,index=8},   }},         
            boss2={ h={ {h4=3,index=1}, {h21=3,index=2},    {h40=3,index=3},    {h10=3,index=4},    {h20=3,index=5},    {h22=3,index=6},    {h28=3,index=7},    {h30=3,index=8},    {h32=3,index=9},    {h37=3,index=10},   }},     
            },                                                      
                                                                    
                                                                    
            taskList = {     --任务 k1 杀死南瓜1 k2 杀死南瓜2 k3 杀死南瓜3 hit 单次消除数量 kb1击杀南瓜1BOSS kb2击杀南瓜2BOSS                                                   
            t1={    index=1,    conditions={type="k1",num=50},  serverreward={  userinfo_gold=30000000,         },  reward={    u={ {gold=30000000},            }}, },
            t2={    index=2,    conditions={type="k2",num=50},  serverreward={  props_p601=30,  props_p448=5,       },  reward={    p={ {p601=30},  {p448=5},       }}, },
            t3={    index=3,    conditions={type="k3",num=3},   serverreward={  troops_a10004=100,  troops_a10014=100,  troops_a10024=100,  },  reward={    o={ {a10004=100},   {a10014=100},   {a10024=100},   }}, },
            t4={    index=4,    conditions={type="kb1",num=3},  serverreward={  props_p277=100, props_p276=20,  props_p275=10,  },  reward={    p={ {p277=100}, {p276=20},  {p275=10},  }}, },
            t5={    index=5,    conditions={type="kb2",num=3},  serverreward={  hero_s27=30,            },  reward={    h={ {s27=30},           }}, },
            t6={    index=6,    conditions={type="hit",num=7},  serverreward={  props_p267=2,           },  reward={    p={ {p267=2},           }}, },
            t7={    index=7,    conditions={type="hit",num=8},  serverreward={  troops_a10034=30,           },  reward={    o={ {a10034=30},            }}, },
            t8={    index=8,    conditions={type="hit",num=9},  serverreward={  props_p230=1,           },  reward={    p={ {p230=1},           }}, },
            }                                                       
                                                                    
        },      
		[3]={	 --熔炼核心碎片,每次活动max投放4个													
			type=1,														
			sortId=73,														
			cost=168,														
			pumpkinLife={	 --每消灭1个南瓜扣血量													
			1,1														
			},														
			bossLife={	 --boss血量													
			100,														
			100,														
			},														
			noticeNum=9,	 --1次性消除数高于此值发公告													
			serverreward={														
			column=3,	 --地图列数													
			map={	 --初始地图													
			[1]=1,														
			[2]=2,														
			[3]=1,														
			[4]=1,														
			[5]=2,														
			[6]=2,														
			[7]=1,														
			[8]=2,														
			[9]=1,														
			},														
			normal1={	 --普通南瓜奖池1													
			{100},														
			{	30,	25,	30,	5,	8,	2,	},							
			{	{"props_p277",5},	{"props_p276",2},	{"props_p275",1},	{"props_p282",1},	{"props_p279",1},	{"props_p278",1},	},							
			},														
			normal2={	 --普通南瓜奖池2													
			{100},														
			{	20,	3,	4,	9,	8,	8,	8,	8,	8,	8,	8,	8,	},	
			{	{"props_p601",2},	{"props_p19",1},	{"props_p446",1},	{"props_p447",1},	{"props_p611",1},	{"props_p612",1},	{"props_p613",1},	{"props_p614",1},	{"props_p615",1},	{"props_p616",1},	{"props_p617",1},	{"props_p618",1},	},	
			},														
			normal3={	 --特殊南瓜奖池3													
			{100},														
			{	25,	25,	15,	15,	8,	12,	},							
			{	{"troops_a10044",8},	{"troops_a10054",8},	{"troops_a10064",8},	{"troops_a10074",8},	{"troops_a10083",8},	{"troops_a10094",8},	},							
			},														
			boss1={	 --BOSS奖池1													
			{100},														
			{	25,	20,	20,	8,	5,	4,	10,	8,	},					
			{	{"props_p277",300},	{"props_p276",60},	{"props_p275",30},	{"props_p283",2},	{"props_p279",10},	{"props_p278",10},	{"props_p90",1},	{"props_p284",1},	},					
			},														
			boss2={	 --BOSS奖池2													
			{100},														
			{	100,										},			
			{	{"props_p3332",3},										},			
			},														
			 --南瓜出现概率														
			pumpkinPool = {{100},{	49,	49,	2	},	{{"1",1},{"2",1},{"3",1}}},									
			},														
			reward={														
			normal1={	p={	{p277=5,index=1},	{p276=2,index=2},	{p275=1,index=3},	{p282=1,index=4},	{p279=1,index=5},	{p278=1,index=6},	}},						
			normal2={	p={	{p601=2,index=1},	{p19=1,index=2},	{p446=1,index=3},	{p447=1,index=4},	{p611=1,index=5},	{p612=1,index=6},	{p613=1,index=7},	{p614=1,index=8},	{p615=1,index=9},	{p616=1,index=10},	{p617=1,index=11},	{p618=1,index=12},	}},
			normal3={	o={	{a10044=8,index=1},	{a10054=8,index=2},	{a10064=8,index=3},	{a10074=8,index=4},	{a10083=8,index=5},	{a10094=8,index=6},	}},						
			boss1={	p={	{p277=300,index=1},	{p276=60,index=2},	{p275=30,index=3},	{p283=2,index=4},	{p279=10,index=5},	{p278=10,index=6},		{p90=1,index=7},	{p284=1,index=8},	}},			
			boss2={	p={	{p3332=3,index=1},										}},		
			},														
																	
																	
			taskList = {	 --任务 k1 杀死南瓜1 k2 杀死南瓜2 k3 杀死南瓜3 hit 单次消除数量 kb1击杀南瓜1BOSS kb2击杀南瓜2BOSS													
			t1={	index=1,	conditions={type="k1",num=300},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			t2={	index=2,	conditions={type="k1",num=60},	serverreward={	props_p601=30,	props_p448=5,		},	reward={	p={	{p601=30},	{p448=5},		}},	},
			t3={	index=3,	conditions={type="k2",num=150},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			t4={	index=4,	conditions={type="k2",num=60},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			t5={	index=5,	conditions={type="k3",num=3},	serverreward={	troops_a10044=40,	troops_a10074=40,	troops_a10083=40,	},	reward={	o={	{a10044=40},	{a10074=40},	{a10083=40},	}},	},
			t6={	index=6,	conditions={type="kb1",num=3},	serverreward={	hero_s27=30,			},	reward={	h={	{s27=30},			}},	},
			t7={	index=7,	conditions={type="kb2",num=3},	serverreward={	props_p277=100,	props_p276=20,	props_p275=10,	},	reward={	p={	{p277=100},	{p276=20},	{p275=10},	}},	},
			t8={	index=8,	conditions={type="hit",num=7},	serverreward={	props_p267=2,			},	reward={	p={	{p267=2},			}},	},
			t9={	index=9,	conditions={type="hit",num=8},	serverreward={	troops_a10113=15,			},	reward={	o={	{a10113=15},			}},	},
			t10={	index=10,	conditions={type="hit",num=9},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			},														
			},																																						
	
			[4]={	 --熔炼核心碎片,每次活动max投放4个													
			type=1,														
			sortId=73,														
			cost=168,														
			pumpkinLife={	 --每消灭1个南瓜扣血量													
			1,1														
			},														
			bossLife={	 --boss血量													
			100,														
			100,														
			},														
			noticeNum=9,	 --1次性消除数高于此值发公告													
			serverreward={														
			column=3,	 --地图列数													
			map={	 --初始地图													
			[1]=1,														
			[2]=2,														
			[3]=1,														
			[4]=1,														
			[5]=2,														
			[6]=2,														
			[7]=1,														
			[8]=2,														
			[9]=1,														
			},														
			normal1={	 --普通南瓜奖池1													
			{100},														
			{	380,	250,	200,	50,	80,	10,	15,	15,	},					
			{	{"props_p277",5},	{"props_p276",2},	{"props_p275",1},	{"props_p282",1},	{"props_p279",1},	{"props_p278",1},	{"props_p4820",1},	{"props_p4821",1},	},					
			},														
			normal2={	 --普通南瓜奖池2													
			{100},														
			{	40,	5,	5,	10,	10,	10,	5,	5,	5,	5,			},	
			{	{"equip_e1",300},	{"equip_e2",300},	{"equip_e3",300},	{"props_p469",1},	{"props_p470",1},	{"props_p471",1},	{"props_p472",1},	{"props_p473",1},	{"props_p474",1},	{"props_p933",1},			},	
			},														
			normal3={	 --特殊南瓜奖池3													
			{100},														
			{	25,	25,	15,	15,	8,	12,	},							
			{	{"troops_a10044",8},	{"troops_a10054",8},	{"troops_a10064",8},	{"troops_a10074",8},	{"troops_a10083",8},	{"troops_a10094",8},	},							
			},														
			boss1={	 --BOSS奖池1													
			{100},														
			{	14,	15,	15,	8,	5,	4,	5,	8,	13,	13,	},			
			{	{"props_p277",300},	{"props_p276",60},	{"props_p275",30},	{"props_p283",2},	{"props_p279",10},	{"props_p278",10},	{"props_p90",1},	{"props_p284",1},	{"props_p4820",5},	{"props_p4821",5},	},			
			},														
			boss2={	 --BOSS奖池2													
			{100},														
			{	100,										},			
			{	{"props_p3332",3},										},			
			},														
			 --南瓜出现概率														
			pumpkinPool = {{100},{	49,	49,	2	},	{{"1",1},{"2",1},{"3",1}}},									
			},														
			reward={														
			normal1={	p={	{p277=5,index=1},	{p276=2,index=2},	{p275=1,index=3},	{p282=1,index=4},	{p279=1,index=5},	{p278=1,index=6},	{p4820=1,index=7},	{p4821=1,index=8},	}},				
			normal2={	f={	{e1=300,index=1},	{e2=300,index=2},	{e3=300,index=3},	},p={	{p469=1,index=4},	{p470=1,index=5},	{p471=1,index=6},	{p472=1,index=7},	{p473=1,index=8},	{p474=1,index=9},	{p933=1,index=10},		}},
			normal3={	o={	{a10044=8,index=1},	{a10054=8,index=2},	{a10064=8,index=3},	{a10074=8,index=4},	{a10083=8,index=5},	{a10094=8,index=6},	}},						
			boss1={	p={	{p277=300,index=1},	{p276=60,index=2},	{p275=30,index=3},	{p283=2,index=4},	{p279=10,index=5},	{p278=10,index=6},	{p90=1,index=7},	{p284=1,index=8},	{p4820=5,index=9},	{p4821=5,index=10},	}},		
			boss2={	p={	{p3332=3,index=1},										}},		
			},														
																	
																	
			taskList = {	 --任务 k1 杀死南瓜1 k2 杀死南瓜2 k3 杀死南瓜3 hit 单次消除数量 kb1击杀南瓜1BOSS kb2击杀南瓜2BOSS													
			t1={	index=1,	conditions={type="k1",num=300},	serverreward={	accessory_p11=1,	props_p4821=2,		},	reward={	e={	{p11=1},	},p={	{p4821=2},	}},	},
			t2={	index=2,	conditions={type="k1",num=60},	serverreward={	props_p601=30,	props_p448=5,		},	reward={	p={	{p601=30},	{p448=5},		}},	},
			t3={	index=3,	conditions={type="k2",num=150},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			t4={	index=4,	conditions={type="k2",num=60},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			t5={	index=5,	conditions={type="k3",num=3},	serverreward={	troops_a10044=40,	troops_a10074=40,	troops_a10083=40,	},	reward={	o={	{a10044=40},	{a10074=40},	{a10083=40},	}},	},
			t6={	index=6,	conditions={type="kb1",num=3},	serverreward={	hero_s27=30,			},	reward={	h={	{s27=30},			}},	},
			t7={	index=7,	conditions={type="kb2",num=3},	serverreward={	props_p277=100,	props_p276=20,	props_p275=10,	},	reward={	p={	{p277=100},	{p276=20},	{p275=10},	}},	},
			t8={	index=8,	conditions={type="hit",num=7},	serverreward={	props_p4820=2,			},	reward={	p={	{p4820=2},			}},	},
			t9={	index=9,	conditions={type="hit",num=8},	serverreward={	troops_a10113=15,			},	reward={	o={	{a10113=15},			}},	},
			t10={	index=10,	conditions={type="hit",num=9},	serverreward={	accessory_p11=1,			},	reward={	e={	{p11=1},			}},	},
			},														
			},														
			},
	}


    local platCfg = {

        -- 3kwan
        ship_3kwan =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},1950},
                    {{props_p890=1},910},
                    {{props_p891=1},268},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },


        },

        -- 3kios
        ship_3kwanios =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},1950},
                    {{props_p890=1},910},
                    {{props_p891=1},268},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        -- 联运
        ship_android =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},1950},
                    {{props_p890=1},910},
                    {{props_p891=1},268},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        -- 港台
        ship_efun_tw =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},7475},
                    {{props_p888=1},3665},
                    {{props_p889=1},2300},
                    {{props_p890=1},1100},
                    {{props_p891=1},650},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        -- 法国
        ship_fra =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},10000},
                    {{props_p888=1},4000},
                    {{props_p889=1},1500},
                    {{props_p890=1},700},
                    {{props_p891=1},200},
                    {{props_p892=1},120},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        -- 德国
        ship_ger =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},1950},
                    {{props_p890=1},910},
                    {{props_p891=1},268},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        -- 日本
        ship_jap =
        {
                --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},1950},
                    {{props_p890=1},910},
                    {{props_p891=1},268},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },


        },

        --韩国
        ship_korea =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},6200},
                    {{props_p888=1},2500},
                    {{props_p889=1},1420},
                    {{props_p890=1},450},
                    {{props_p891=1},220},
                    {{props_p892=1},40},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        -- 俄罗斯
        ship_russia =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},7500},
                    {{props_p888=1},3450},
                    {{props_p889=1},1320},
                    {{props_p890=1},630},
                    {{props_p891=1},310},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },
         
        --阿拉伯
        ship_arab =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},7000},
                    {{props_p888=1},3250},
                    {{props_p889=1},1250},
                    {{props_p890=1},600},
                    {{props_p891=1},275},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --应用宝
        ship_yyb =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},980},
                    {{props_p890=1},500},
                    {{props_p891=1},180},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --东南亚
        ship_dny =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},7000},
                    {{props_p888=1},3300},
                    {{props_p889=1},1300},
                    {{props_p890=1},630},
                    {{props_p891=1},310},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --北美
        ship_us =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},6000},
                    {{props_p888=1},3000},
                    {{props_p889=1},1800},
                    {{props_p890=1},600},
                    {{props_p891=1},300},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },
               
        --韩国
        ship_korea =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},6200},
                    {{props_p888=1},2500},
                    {{props_p889=1},1420},
                    {{props_p890=1},450},
                    {{props_p891=1},220},
                    {{props_p892=1},40},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --阿拉伯
        ship_arab =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},7000},
                    {{props_p888=1},3250},
                    {{props_p889=1},1250},
                    {{props_p890=1},600},
                    {{props_p891=1},275},
                    {{props_p892=1},50},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --应用宝
        ship_yyb =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},8400},
                    {{props_p888=1},3420},
                    {{props_p889=1},980},
                    {{props_p890=1},500},
                    {{props_p891=1},180},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --东南亚
        ship_dny =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},7000},
                    {{props_p888=1},3300},
                    {{props_p889=1},1300},
                    {{props_p890=1},630},
                    {{props_p891=1},310},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

        --北美
        ship_us =
        {
            --有福同享
            shareHappiness={
                type=1,
                sortId=146,
                serverreward={--后台
                    {{props_p887=1},6000},
                    {{props_p888=1},3000},
                    {{props_p889=1},1800},
                    {{props_p890=1},600},
                    {{props_p891=1},300},
                    {{props_p892=1},60},
                },
                reward={--前台
                    {p={{p887=1,index=1}}},
                    {p={{p888=1,index=1}}},
                    {p={{p889=1,index=1}}},
                    {p={{p890=1,index=1}}},
                    {p={{p891=1,index=1}}},
                    {p={{p892=1,index=1}}},
                },
            },

        },

    }

    -- 首冲特殊处理
    if commonCfg.armor_firstRecharge and moduleIsEnabled('armor') == 1 then
        commonCfg.firstRecharge = commonCfg.armor_firstRecharge
    end

    if clientPlat ~= 'def' then         
        if platCfg and type(platCfg[clientPlat]) == 'table' then
            for k,v in pairs(platCfg[clientPlat]) do
                commonCfg[k] = v
            end
        end
    end
    
    return commonCfg 
end

return returnCfg
