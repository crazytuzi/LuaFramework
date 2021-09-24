local openyear={
    multiSelectType=true,  --支持多版本
    [1]={
        _activeCfg=true,
        type=1,
        sortId=200,
        
        --第一页签
        --每日免费领取1个福袋
        dayGet=1,
        --使用福袋获得福气值
        getLuck={10,12},
        
        --领奖所需福气值
        needLuck={70,110,170,250,},
        --前台福气奖励
        luckReward={
            {e={{p2=2,index=1},{p6=1,index=2}}},
            {e={{p1=2,index=1},{p4=500,index=2}}},
            {e={{p5=2,index=1},{p3=20,index=2},{p4=1000,index=3}}},
            {e={{p6=2,index=2},{p2=2,index=3}},p={{p587=1,index=1}}},
        },
        
        bagReward={
            --军舰福袋
            {o={{a10044=2,index=1},{a10054=2,index=2},{a10064=2,index=3},{a10074=2,index=4},{a10094=2,index=5},{a10114=2,index=6},{a10124=2,index=7}}},
            --将领福袋
            {p={{p641=1,index=1},{p642=1,index=2},{p643=1,index=3},{p644=1,index=4},{p645=1,index=5},{p646=1,index=6},{p647=1,index=7},{p631=1,index=8},{p632=1,index=9},{p633=1,index=10},{p634=1,index=11},{p635=1,index=12},{p636=1,index=13},{p637=1,index=14}}},
            --超级武器福袋
            {e={{p1=1,index=1},{p2=2,index=2},{p3=10,index=3},{p4=500,index=4},{p5=1,index=5},{p6=2,index=6}}},
            --资源福袋
            {p={{p3=1,index=2},{p32=1,index=3},{p33=1,index=4},{p34=1,index=5},{p35=1,index=6},{p36=1,index=7},{p37=1,index=8},{p38=1,index=9},{p39=1,index=10},{p40=1,index=11},{p41=1,index=12}}},
        },
        
        --第二页签
        --领奖所需充值额度
        needMoney={50,268,910,1950,},
        --前台充值奖励
        recharge={
            {e={{p6=5,index=1}},p={{p3334=1,index=2}}},
            {e={{p2=3,index=1}},p={{p3334=4,index=2}}},
            {e={{p5=1,index=1},{p4=200,index=2}},p={{p3334=6,index=3}}},
            {e={{p5=1,index=1},{p6=2,index=2}},p={{p3334=8,index=3}}},
        },
        
        --第三页签
        --每日任务
        --新增key=fb:抽取军徽X次（金币和水晶抽取都计入次数）
        --index:前台排序
        --luckBag:后台增加福袋
        dailyTask={
            {key="fa",index=1,needNum=1,reward={p={{p20=1,index=1},{p3334=1,index=2}}},serverreward={props_p20=1,},luckbag=1},
            {key="rb",index=2,needNum=1,reward={p={{p29=1,index=1},{p3334=1,index=2}}},serverreward={props_p29=1,},luckbag=1},
            {key="pp",index=3,needNum=5,reward={p={{p601=2,index=1},{p3334=1,index=2}}},serverreward={props_p601=2,},luckbag=1},
            {key="mw",index=4,needNum=2,reward={p={{p19=5,index=1},{p3334=1,index=2}}},serverreward={props_p19=5,},luckbag=1},
            {key="fb",index=5,needNum=5,reward={p={{p30=1,index=1},{p3334=1,index=2}}},serverreward={props_p30=1,},luckbag=1},
        },
        
        serverreward={
            --福气奖励
            luckReward={
                {accessory_p2=2,accessory_p6=1},
                {accessory_p1=2,accessory_p4=500},
                {accessory_p5=2,accessory_p3=20,accessory_p4=1000},
                {props_p587=1,accessory_p6=2,accessory_p2=2},
            },
            
            --福袋随机类型的权重
            typeRatio={4,3,2,2},
            
            --军舰福袋
            pool1={
                {100},
                {1,1,1,1,1,1,1},
                {{"troops_a10044",2},{"troops_a10054",2},{"troops_a10064",2},{"troops_a10074",2},{"troops_a10094",2},{"troops_a10114",2},{"troops_a10124",2}},
            },
            
            --将领福袋
            pool2={
                {100},
                {1,1,1,1,1,1,1,2,2,2,2,2,2,2},
                {{"props_p641",1},{"props_p642",1},{"props_p643",1},{"props_p644",1},{"props_p645",1},{"props_p646",1},{"props_p647",1},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p634",1},{"props_p635",1},{"props_p636",1},{"props_p637",1}},
            },
            
            --配件福袋
            pool3={
                {100},
                {1,1,1,1,1,1},
                {{"accessory_p1",1},{"accessory_p2",2},{"accessory_p3",10},{"accessory_p4",500},{"accessory_p5",1},{"accessory_p6",2}},
            },
            
            --资源福袋
            pool4={
                {100},
                {3,3,3,3,3,3,3,3,3,3,3},
                {{"props_p3",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1},{"props_p37",1},{"props_p38",1},{"props_p39",1},{"props_p40",1},{"props_p41",1}},
            },
            
            --充值奖励
            --{{},num}: {}中是道具奖励 num是奖励福袋数量
            recharge={
                {{accessory_p6=5,},1},
                {{accessory_p2=3,},4},
                {{accessory_p5=1,accessory_p4=200,},6},
                {{accessory_p5=1,accessory_p6=2,},8},
            },
        },
    },
}

return openyear
