local wdyo={
    multiSelectType=true,
    [1]={
        _activeCfg=true,
        sortId=200,
        type=1,
        
        --抽1次所需金币
        cost1=48,
        --10倍抽奖所需金币，10倍抽奖时，货币和配对成功的奖励道具数量都要*10
        cost2=432,
        
        --配对成功0对,1对,2对,3对所获得的货币数量
        getScore={10,20,40,100},
        
        --前台奖励展示
        reward={o={{a10043=1,index=1},{a10053=1,index=2},{a10063=1,index=3},{a10073=1,index=4},{a10082=1,index=5},{a10093=1,index=6},{a10113=1,index=7},{a10123=1,index=8}}},
        
        --前台图片
        picture={
            {id=1,pic="wukelanLv3.png"},
            {id=2,pic="eluosiLv3.png"},
            {id=3,pic="SturmtigerLv3.png"},
            {id=4,pic="RatTankLv3.png"},
            {id=5,pic="StormRocket.png"},
            {id=6,pic="IconTank59.png"},
            {id=7,pic="IconTank_10113.png"},
            {id=8,pic="IconTank_10123.png"},
        },
        
        serverreward={
            --例：每次抽奖过程：左列3个格子与右列3个格子是独立的
            --1.左列从（1--8中）随机出3个数，3个数不重复
            --2.右列从（1--8中）随机出3个数，3个数不重复
            --3.根据随机的结果，来判断是否配对成功！例：左列（7,3,4）  右列（2,7,3）  则有两对（7和3）配对成功
            
            --配对成功，将获得道具奖励，每次抽奖，有可能有多个配对成功，多个配对成功，则获得多个配对奖励
            --例：id为1,2,4的配对成功，则获得[1],[2],[4]对应的奖励
            prize={
                [1]={troops_a10043=1},
                [2]={troops_a10053=1},
                [3]={troops_a10063=1},
                [4]={troops_a10073=1},
                [5]={troops_a10082=1},
                [6]={troops_a10093=1},
                [7]={troops_a10113=1},
                [8]={troops_a10123=1},
            },
        },
        
        --商店
        --limit:限购次数   无limit字段，物品没有限制次数
        --bn:显示折扣比例，有的物品为0  为0时不显示折扣比例
        --p：显示最初价格  g:打折后价格  商店都是用积分兑换  所有扣取都以（g:打折后价格）为准
        shop={
            i1={limit=1,bn=0,p=3200,g=5000,isflick=1,notice=1,reward={p={p230=1}},serverreward={props_p230=1}},
            i2={limit=1,bn=0,p=2816,g=3300,isflick=1,notice=1,reward={p={p588=1}},serverreward={props_p588=1}},
            i3={limit=2,bn=0,p=2304,g=2700,isflick=1,notice=1,reward={p={p587=1}},serverreward={props_p587=1}},
            i4={limit=3,bn=0,p=700,g=700,reward={p={p1287=1}},serverreward={props_p1287=1}},
            i5={limit=3,bn=0,p=600,g=600,reward={p={p1286=1}},serverreward={props_p1286=1}},
            i6={limit=50,bn=0,p=100,g=100,reward={p={p448=1}},serverreward={props_p448=1}},
            i7={limit=50,bn=0,p=50,g=50,reward={p={p819=1}},serverreward={props_p819=1}},
            i8={limit=50,bn=0,p=100,g=35,reward={p={p20=1}},serverreward={props_p20=1}},
            i9={limit=50,bn=0,p=10,g=10,reward={p={p601=1}},serverreward={props_p601=1}},
            i10={limit=1,bn=0,p=2000,g=2200,isflick=1,notice=1,reward={p={p4007=1}},serverreward={props_p4007=1}},
            i11={limit=2,bn=0,p=800,g=900,isflick=1,notice=1,reward={p={p4002=1}},serverreward={props_p4002=1}},
            i12={limit=2,bn=0,p=998,g=1100,isflick=1,notice=1,reward={p={p4006=1}},serverreward={props_p4006=1}},
            i13={limit=10,bn=0,p=498,g=550,reward={p={p4005=1}},serverreward={props_p4005=1}},
            i14={limit=20,bn=0,p=28,g=30,reward={p={p959=1}},serverreward={props_p959=1}},
            i15={limit=20,bn=0,p=18,g=20,reward={p={p958=1}},serverreward={props_p958=1}},
        },
    },
    [2]={
        _activeCfg=true,
        sortId=200,
        type=1,
        
        --抽1次所需金币
        cost1=78,
        --10倍抽奖所需金币，10倍抽奖时，货币和配对成功的奖励道具数量都要*10
        cost2=702,
        
        --配对成功0对,1对,2对,3对所获得的货币数量
        getScore={15,20,40,100},
        
        --前台奖励展示
        reward={o={{a10044=1,index=1},{a10054=1,index=2},{a10064=1,index=3},{a10074=1,index=4},{a10083=1,index=5},{a10094=1,index=6},{a10114=1,index=7},{a10124=1,index=8}}},
        
        --前台图片
        picture={
            {id=1,pic="IconT99.png"},
            {id=2,pic="IconTujiu.png"},
            {id=3,pic="fightingElephantTank.png"},
            {id=4,pic="largeMouseTank.png"},
            {id=5,pic="SandstormIcon.png"},
            {id=6,pic="IconTank_10094.png"},
            {id=7,pic="IconTank_10114.png"},
            {id=8,pic="IconTank_10124.png"},
        },
        
        serverreward={
            --例：每次抽奖过程：左列3个格子与右列3个格子是独立的
            --1.左列从（1--8中）随机出3个数，3个数不重复
            --2.右列从（1--8中）随机出3个数，3个数不重复
            --3.根据随机的结果，来判断是否配对成功！例：左列（7,3,4）  右列（2,7,3）  则有两对（7和3）配对成功
            
            --配对成功，将获得道具奖励，每次抽奖，有可能有多个配对成功，多个配对成功，则获得多个配对奖励
            --例：id为1,2,4的配对成功，则获得[1],[2],[4]对应的奖励
            prize={
                [1]={troops_a10044=1},
                [2]={troops_a10054=1},
                [3]={troops_a10064=1},
                [4]={troops_a10074=1},
                [5]={troops_a10083=1},
                [6]={troops_a10094=1},
                [7]={troops_a10114=1},
                [8]={troops_a10124=1},
            },
        },
        
        --商店
        --limit:限购次数   无limit字段，物品没有限制次数
        --bn:显示折扣比例，有的物品为0  为0时不显示折扣比例
        --p：显示最初价格  g:打折后价格  商店都是用积分兑换  所有扣取都以（g:打折后价格）为准
        shop={
            i1={limit=1,bn=0,p=3200,g=5000,isflick=1,notice=1,reward={p={p230=1}},serverreward={props_p230=1}},
            i2={limit=1,bn=0,p=2816,g=2800,isflick=1,notice=1,reward={p={p588=1}},serverreward={props_p588=1}},
            i3={limit=2,bn=0,p=2304,g=2300,isflick=1,notice=1,reward={p={p587=1}},serverreward={props_p587=1}},
            i4={limit=3,bn=0,p=1920,g=1300,reward={p={p586=1}},serverreward={props_p586=1}},
            i5={limit=3,bn=0,p=1536,g=1200,reward={p={p585=1}},serverreward={props_p585=1}},
            i6={limit=50,bn=0,p=100,g=100,reward={p={p448=1}},serverreward={props_p448=1}},
            i7={limit=50,bn=0,p=50,g=50,reward={p={p819=1}},serverreward={props_p819=1}},
            i8={limit=50,bn=0,p=100,g=35,reward={p={p20=1}},serverreward={props_p20=1}},
            i9={limit=50,bn=0,p=10,g=10,reward={p={p601=1}},serverreward={props_p601=1}},
            i10={limit=1,bn=0,p=2000,g=2200,isflick=1,notice=1,reward={p={p4007=1}},serverreward={props_p4007=1}},
            i11={limit=2,bn=0,p=800,g=900,isflick=1,notice=1,reward={p={p4002=1}},serverreward={props_p4002=1}},
            i12={limit=2,bn=0,p=998,g=1100,isflick=1,notice=1,reward={p={p4006=1}},serverreward={props_p4006=1}},
            i13={limit=10,bn=0,p=498,g=550,reward={p={p4005=1}},serverreward={props_p4005=1}},
            i14={limit=20,bn=0,p=28,g=30,reward={p={p959=1}},serverreward={props_p959=1}},
            i15={limit=20,bn=0,p=18,g=20,reward={p={p958=1}},serverreward={props_p958=1}},
        },
    },
}
return wdyo
