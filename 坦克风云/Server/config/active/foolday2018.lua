local foolday2018 ={
    _isAllianceActivity = true,
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --积分需求
        supportNeed={5520,6300,21000},
        --任务刷新消耗（超出次数限制按照最后一个价格消耗）
        refreshCost={0,20,20,20,20,20,20},
        --排行榜上榜限制
        rLimit=32820,
        --分数说明,依次为面具/礼帽/红鼻头
        point={2,5,25},
        --排名区间
        section={{1,1},{2,2},{3,3},{4,5},{6,10}},
        --排行榜排名上限
        rNumLimit=10,
        --任务数量限制
        taskLimit=10,
        --礼包价格
        cost=260,
        --充值额度
        rechargeNum=600,
        --军团任务奖励领取限制
        aTaskLimit=40,
        --排行榜奖励领取限制
        rGetLimit=40,
        --排行榜奖励1
        rank1={props_p4002=8,props_p4877=1,props_p3416=2,props_p3417=2,props_p3418=2},
        --排行榜奖励2
        rank2={props_p4002=5,props_p4876=1,props_p3416=2,props_p3417=2,props_p3418=2},
        --排行榜奖励3
        rank3={props_p4002=3,props_p4875=1,props_p3416=1,props_p3417=1,props_p3418=1},
        --排行榜奖励4
        rank4={props_p4002=2,props_p4874=1,props_p3405=1,props_p3410=1,props_p3415=1},
        --排行榜奖励5
        rank5={props_p4002=2,props_p4874=1,props_p3404=2,props_p3409=2,props_p3414=2},
        --积分奖励1
        gift1={props_p3436=15,props_p481=1,props_p447=15},
        --积分奖励2
        gift2={accessory_p1=12,accessory_p2=20,accessory_p3=40,accessory_p4=4000},
        --积分奖励3
        gift3={props_p4028=10,props_p4027=15,props_p4037=20,props_p4038=20,props_p4039=20,props_p4040=20},
        --大奖奖励
        gift4={props_p4875=2,props_p4874=4,props_p4873=6},
        --礼包内容
        recharge1={foolday_a3=4,foolday_a2=2,foolday_a1=10},
        --累计充值达到X钻时奖励（循环）
        recharge2={foolday_a3=4,foolday_a2=2,foolday_a1=5},
        --兑换奖池1
        pool1={
            {100},
            {10,10,15,15,15,15,15,15,15},
            {{"armor_exp",400},{"props_p19",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p624",1},{"props_p625",1},{"props_p626",1},{"props_p627",1}},
        },
        --兑换奖池2
        pool2={
            {100},
            {30,30,30,30,30,30,30,30},
            {{"equip_e1",400},{"equip_e2",400},{"equip_e3",400},{"props_p26",3},{"props_p26",3},{"props_p26",3},{"props_p26",3},{"props_p26",3}},
        },
        --兑换奖池3
        pool3={
            {100},
            {30,30,30,30,30,30,30,30,30,30,30,30},
            {{"props_p4873",1},{"props_p4872",1},{"props_p4871",1},{"troops_a10044",1},{"troops_a10054",1},{"troops_a10064",1},{"troops_a10074",1},{"troops_a10083",1},{"troops_a10094",1},{"troops_a10114",1},{"troops_a10124",1},{"troops_a20154",1}},
        },
        --任务列表
        randompool={
            {100},
            {20,20,20,20,10,20,15,15,15,15,20,20,10,10,20,10},
            {"pe","pp","au","mb","ad","gb","jq","fa","cn","tl","jz","rs","ez","rb","fb","ab"},
        },
        randtaskpool={
            --攻打X次世界资源点
            pe={1},
            --世界地图其他玩家--攻打X次
            pp={2},
            --进行X次配件强化
            au={3},
            --军事演习进行X次战斗
            mb={4},
            --进行X次军团捐献
            ad={5},
            --充值金币
            gb={6},
            --攻打X次剧情战役
            jq={7},
            --攻打X次海盗
            fa={8},
            --攻打X次关卡
            cn={9},
            --购买X次体力
            tl={10},
            --招募x次将领
            jz={11},
            --异星商店中购买X件货物
            rs={12},
            --攻打X次远征
            ez={13},
            --攻打X次富矿
            rb={14},
            --抽取超级装备X次（金币与水晶抽取都算）
            fb={15},
            --攻打X次补给线
            ab={16},
        },
        taskList={
            --攻打X次世界资源点
            [1]={num=10,serverreward={{foolday_a1=5}}},
            --世界地图其他玩家--攻打X次
            [2]={num=5,serverreward={{foolday_a2=2,foolday_a1=3}}},
            --进行X次配件强化
            [3]={num=5,serverreward={{foolday_a1=2}}},
            --军事演习进行X次战斗
            [4]={num=5,serverreward={{foolday_a2=4,foolday_a1=3}}},
            --进行X次军团捐献
            [5]={num=8,serverreward={{foolday_a2=5,foolday_a1=1}}},
            --充值金币
            [6]={num=200,serverreward={{foolday_a3=3}}},
            --攻打X次剧情战役
            [7]={num=5,serverreward={{foolday_a1=5}}},
            --攻打X次海盗
            [8]={num=3,serverreward={{foolday_a2=4,foolday_a1=2}}},
            --攻打X次关卡
            [9]={num=10,serverreward={{foolday_a1=5}}},
            --购买X次体力
            [10]={num=3,serverreward={{foolday_a3=2,foolday_a2=3,foolday_a1=3}}},
            --招募x次将领
            [11]={num=5,serverreward={{foolday_a2=2,foolday_a1=4}}},
            --异星商店中购买X件货物
            [12]={num=3,serverreward={{foolday_a3=2,foolday_a2=2,foolday_a1=3}}},
            --攻打X次远征
            [13]={num=3,serverreward={{foolday_a2=4,foolday_a1=3}}},
            --攻打X次富矿
            [14]={num=4,serverreward={{foolday_a2=5}}},
            --抽取超级装备X次（金币与水晶抽取都算）
            [15]={num=5,serverreward={{foolday_a2=3,foolday_a1=3}}},
            --攻打X次补给线
            [16]={num=5,serverreward={{foolday_a1=5}}},
        },
        --军团任务
        allianceTask={
            ----攻打X次关卡
            {type="cn",num=1350,index=1,serverreward={{foolday_a3=4,foolday_a2=10,foolday_a1=12}}},
            ----购买X次体力
            {type="tl",num=100,index=2,serverreward={{foolday_a3=4,foolday_a2=10,foolday_a1=12}}},
            ----攻打X次剧情战役
            {type="jq",num=50,index=3,serverreward={{foolday_a3=4,foolday_a2=10,foolday_a1=12}}},
            ----抽取超级装备X次（金币与水晶抽取都算）
            {type="fb",num=200,index=4,serverreward={{foolday_a3=4,foolday_a2=10,foolday_a1=12}}},
            ----进行X次军团捐献
            {type="ad",num=300,index=5,serverreward={{foolday_a3=4,foolday_a2=10,foolday_a1=12}}},
            ----军事演习进行X次战斗
            {type="mb",num=240,index=6,serverreward={{foolday_a3=4,foolday_a2=10,foolday_a1=12}}},
        },
    },
}

return foolday2018 
