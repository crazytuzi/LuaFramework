local rechargebag={
    multiSelectType=true,  --支持多版本
    
    [1]={
        
        type=1,
        sortID=200,
        
        limit=8400,
        need=1000,
        extra={p={{p3306=1}}},  --充值达到8400金币后，每充值1000金币获得一个红包
        
        point1=12, --每赠送一个中红包获得慷慨值点数
        point2=5, --每赠送一个小红包获得慷慨值点数
        point=25,  --每赠送一个红包获得慷慨值点数
        needPoint=100,  --达到限额，才能上榜
        
        rankReward={  --前台排行榜奖励
            {{1,1},{p={{p988=30,index=1},{p267=5,index=2},{p230=2,index=3}}}},
            {{2,2},{p={{p988=15,index=1},{p267=3,index=2},{p230=1,index=3}}}},
            {{3,3},{e={{p6=5,index=3}},p={{p988=10,index=1},{p267=2,index=2}}}},
            {{4,5},{e={{p6=3,index=3}},p={{p988=5,index=1},{p266=5,index=2}}}},
            {{6,10},{e={{p6=2,index=3}},p={{p988=5,index=1},{p266=3,index=2}}}},
        },
        
        reward={  --前台充值奖励，对应4个充值额度
            {p={{p3306=1,index=1},{p601=5,index=2}}},
            {p={{p3306=3,index=1},{p601=10,index=2}}},
            {p={{p3306=5,index=1},{p20=3,index=2},{p601=20,index=3}}},
            {p={{p3306=10,index=1},{p20=5,index=2},{p601=35,index=3}}},
        },
        
        cost={160,960,3420,8400},  --4个充值额度
        
        serverreward={
            extra={props_p3306=1},
            
            rankReward={  --后台排行榜奖励
                {{1,1},{props_p988=30,props_p267=5,props_p230=2}},
                {{2,2},{props_p988=15,props_p267=3,props_p230=1}},
                {{3,3},{props_p988=10,props_p267=2,accessory_p6=5}},
                {{4,5},{props_p988=5,props_p266=5,accessory_p6=3}},
                {{6,10},{props_p988=5,props_p266=3,accessory_p6=2}},
            },
            
            r={  --后台充值奖励，对应4个额度
                {props_p3306=1,props_p601=5},
                {props_p3306=3,props_p601=10},
                {props_p3306=5,props_p20=3,props_p601=20},
                {props_p3306=10,props_p20=5,props_p601=35},
            },
        },
    },
}

return rechargebag
