local ghost ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        --单次价格
        cost1=20,
        --分奖池次数（即从第X次开始启用奖池2）
        changeNum=4,
        --格子数量
        cellNum=7,
        --炸弹数量
        bombNum=1,
        --保底次数
        luckyNum=1,
        --显示概率
        showRate={0,16,20,25,33,50,100},
        serverreward={
            --鬼牌道具
            ghostItem={props_p279=1},
            --奖池1
            pool1={
                {100},
                {20,10,20,10,10,10,10,20,5,5,5,5,5,5,5,5,5,20,20,20},
                {{"props_p601",1},{"props_p956",1},{"props_p957",1},{"props_p958",1},{"props_p959",1},{"props_p447",1},{"props_p4810",1},{"props_p446",1},{"troops_a10043",1},{"troops_a10053",1},{"troops_a10063",1},{"troops_a10073",1},{"troops_a10082",1},{"troops_a10093",1},{"troops_a10113",1},{"troops_a10123",1},{"troops_a20153",1},{"equip_e1",50},{"equip_e2",50},{"equip_e3",50}},
            },
            
            --奖池2
            pool2={
                {100},
                {20,20,20,30,20,20,15,20,30,20,15},
                {{"props_p4852",1},{"props_p4811",2},{"troops_a10044",1},{"troops_a10054",1},{"troops_a10064",1},{"troops_a10074",1},{"troops_a10083",1},{"troops_a10094",1},{"troops_a10114",1},{"troops_a10124",1},{"troops_a20154",1}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --超过M轮获得至少N个道具
                {type="sl1",num={1,4},index=1,serverreward={{"props_p601",20}}},
                --超过M轮获得至少N个道具
                {type="sl1",num={5,4},index=2,serverreward={{"troops_a10053",5},{"troops_a10082",5}}},
                --超过M轮获得至少N个道具
                {type="sl1",num={20,4},index=3,serverreward={{"troops_a10044",5},{"troops_a10074",5}}},
                --超过M轮获得至少N个道具
                {type="sl1",num={1,5},index=4,serverreward={{"equip_e1",3000}}},
                --超过M轮获得至少N个道具
                {type="sl1",num={1,6},index=5,serverreward={{"props_p4852",10}}},
                --累计扫描N次
                {type="sl2",num={500},index=6,serverreward={{"troops_a10043",5},{"troops_a10073",5}}},
                --累计扫描N次
                {type="sl2",num={1000},index=7,serverreward={{"troops_a10054",10},{"troops_a10083",10}}},
            },
        },
        ghostItem={p={p279=1}},
        --任务（标识，参数，奖励）
        taskList={
            {type="sl1",num={1,4},index=1,reward={p={{p601=20,index=1}}}},
            {type="sl1",num={5,4},index=2,reward={o={{a10053=5,index=1},{a10082=5,index=2}}}},
            {type="sl1",num={20,4},index=3,reward={o={{a10044=5,index=1},{a10074=5,index=2}}}},
            {type="sl1",num={1,5},index=4,reward={f={{e1=3000,index=1}}}},
            {type="sl1",num={1,6},index=5,reward={p={{p4852=10,index=1}}}},
            {type="sl2",num={500},index=6,reward={o={{a10043=5,index=1},{a10073=5,index=2}}}},
            {type="sl2",num={1000},index=7,reward={o={{a10054=10,index=1},{a10083=10,index=2}}}},
        },
    },
}

return ghost 
