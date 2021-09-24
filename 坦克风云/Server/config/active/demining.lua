local demining ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        --单次价格
        cost1=98,
        --五连价格
        cost2=466,
        --分区数量
        partNum=3,
        --格子数量
        cellNum=19,
        --分区格子编号（只区分区域，分区编号与格子类型和颜色无关）
        partCell={
            {1,2,9,10,13,14},
            {5,6,7,16,17,18},
            {3,4,8,11,12,15,19},
        },
        --分区信息（1-其他，2-将领，3-配件，4-异星武器，5-船……编号对应奖池，每次随机与分区号匹配）
        partName={2,3,5},
        --炸弹数量
        bombNum=3,
        --保底次数
        luckyNum=2,
        --显示概率
        showRate={0,16,17,18,20,21,23,25,27,30,33,37,42,50,60,75,100,100,100},
        serverreward={
            --奖池1
            pool2={
                {100},
                {10,10,10,10,10,10,10},
                {{"props_p601",5},{"props_p956",1},{"props_p957",3},{"props_p958",2},{"props_p959",1},{"props_p447",2},{"props_p4810",1}},
            },
            
            --奖池2
            pool3={
                {100},
                {10,10,10,10,10},
                {{"accessory_p1",1},{"accessory_p2",1},{"accessory_p3",10},{"accessory_p4",300},{"accessory_p6",2}},
            },
            
            --奖池3
            pool5={
                {100},
                {15,25,30,40,12,20,24,32},
                {{"troops_a10082",1},{"troops_a10093",1},{"troops_a10043",1},{"troops_a10113",1},{"props_p414",2},{"props_p835",2},{"props_p410",2},{"props_p836",2}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --超过M轮获得至少翻N个牌
                {type="sl1",num={1,6},index=1,serverreward={{"userinfo_gold",2000000}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={5,6},index=2,serverreward={{"props_p279",10},{"props_p278",1}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={20,6},index=3,serverreward={{"props_p275",10},{"props_p276",20}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={1,9},index=4,serverreward={{"hero_s106",10}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={1,12},index=5,serverreward={{"props_p4810",20},{"props_p4852",5}}},
                --累计扫描N次
                {type="sl2",num={500},index=6,serverreward={{"props_p414",20},{"props_p835",20},{"props_p410",20},{"props_p836",20}}},
                --累计扫描N次
                {type="sl2",num={1000},index=7,serverreward={{"troops_a10082",20},{"troops_a10093",20},{"troops_a10043",20},{"troops_a10113",20}}},
            },
        },
        --前端展示
        showList1={p={{p601=5,index=1},{p956=1,index=2},{p957=3,index=3},{p958=2,index=4},{p959=1,index=5},{p447=2,index=6},{p4810=1,index=7}}},
        flash1={0,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --前端展示
        showList2={e={{p1=1,index=1},{p2=1,index=2},{p3=10,index=3},{p4=300,index=4},{p6=2,index=5}}},
        flash2={0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --前端展示
        showList3={o={{a10082=1,index=1},{a10093=1,index=2},{a10043=1,index=3},{a10113=1,index=4}},p={{p414=2,index=5},{p835=2,index=6},{p410=2,index=7},{p836=2,index=8}}},
        flash3={0,0,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        
        --任务（标识，参数，奖励）
        taskList={
            {type="sl1",num={1,6},index=1,reward={u={{gold=2000000,index=1}}}},
            {type="sl1",num={5,6},index=2,reward={p={{p279=10,index=1},{p278=1,index=2}}}},
            {type="sl1",num={20,6},index=3,reward={p={{p275=10,index=1},{p276=20,index=2}}}},
            {type="sl1",num={1,9},index=4,reward={h={{s106=10,index=1}}}},
            {type="sl1",num={1,12},index=5,reward={p={{p4810=20,index=1},{p4852=5,index=2}}}},
            {type="sl2",num={500},index=6,reward={p={{p414=20,index=1},{p835=20,index=2},{p410=20,index=3},{p836=20,index=4}}}},
            {type="sl2",num={1000},index=7,reward={o={{a10082=20,index=1},{a10093=20,index=2},{a10043=20,index=3},{a10113=20,index=4}}}},
        },
    },
    [2]={
        sortid=223,
        type=1,
        --单次价格
        cost1=98,
        --五连价格
        cost2=466,
        --分区数量
        partNum=3,
        --格子数量
        cellNum=19,
        --分区格子编号（只区分区域，分区编号与格子类型和颜色无关）
        partCell={
            {1,2,9,10,13,14},
            {5,6,7,16,17,18},
            {3,4,8,11,12,15,19},
        },
        --分区信息（1-其他，2-将领，3-配件，4-异星武器，5-船……编号对应奖池，每次随机与分区号匹配）
        partName={3,4,5},
        --炸弹数量
        bombNum=3,
        --保底次数
        luckyNum=2,
        --显示概率
        showRate={0,16,17,18,20,21,23,25,27,30,33,37,42,50,60,75,100,100,100},
        serverreward={
            --奖池1
            pool3={
                {100},
                {10,10,10,10,10},
                {{"accessory_p1",1},{"accessory_p2",1},{"accessory_p3",10},{"accessory_p4",300},{"accessory_p6",2}},
            },
            
            --奖池2
            pool4={
                {100},
                {10,10,10,10,30,30,30,30,30,30,30,30,30,30},
                {{"aweapon_af13",1},{"aweapon_af14",1},{"aweapon_af15",1},{"aweapon_af16",1},{"aweapon_af7",1},{"aweapon_af8",1},{"aweapon_af9",1},{"aweapon_af10",1},{"aweapon_ap1",3},{"aweapon_ap2",3},{"aweapon_ap3",3},{"aweapon_ap4",3},{"aweapon_ap5",3},{"aweapon_exp",500}},
            },
            
            --奖池3
            pool5={
                {100},
                {15,25,30,40,12,20,24,32},
                {{"troops_a10082",1},{"troops_a10093",1},{"troops_a10043",1},{"troops_a10113",1},{"props_p414",2},{"props_p835",2},{"props_p410",2},{"props_p836",2}},
            },
            
            --任务（标识，参数，奖励）
            taskList={
                --超过M轮获得至少翻N个牌
                {type="sl1",num={1,6},index=1,serverreward={{"props_p448",2}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={5,6},index=2,serverreward={{"equip_e2",2000},{"equip_e3",2000}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={20,6},index=3,serverreward={{"equip_e1",10000}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={1,9},index=4,serverreward={{"props_p410",15},{"props_p836",15}}},
                --超过M轮获得至少翻N个牌
                {type="sl1",num={1,12},index=5,serverreward={{"troops_a10043",15},{"troops_a10113",15}}},
                --累计扫描N次
                {type="sl2",num={500},index=6,serverreward={{"aweapon_ap5",50},{"aweapon_exp",10000}}},
                --累计扫描N次
                {type="sl2",num={1000},index=7,serverreward={{"props_p4023",20}}},
            },
        },
        --前端展示
        showList1={e={{p1=1,index=1},{p2=1,index=2},{p3=10,index=3},{p4=300,index=4},{p6=2,index=5}}},
        flash1={0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --前端展示
        showList2={aw={{af13=1,index=1},{af14=1,index=2},{af15=1,index=3},{af16=1,index=4},{af7=1,index=5},{af8=1,index=6},{af9=1,index=7},{af10=1,index=8},{ap1=3,index=9},{ap2=3,index=10},{ap3=3,index=11},{ap4=3,index=12},{ap5=3,index=13},{exp=500,index=14}}},
        flash2={0,0,0,0,0,0,0,0,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        --前端展示
        showList3={o={{a10082=1,index=1},{a10093=1,index=2},{a10043=1,index=3},{a10113=1,index=4}},p={{p414=2,index=5},{p835=2,index=6},{p410=2,index=7},{p836=2,index=8}}},
        flash3={0,0,0,0,0,0,0,0},    --闪光（1-橙，2-紫，3-蓝）
        
        --任务（标识，参数，奖励）
        taskList={
            {type="sl1",num={1,6},index=1,reward={p={{p448=2,index=1}}}},
            {type="sl1",num={5,6},index=2,reward={f={{e2=2000,index=1},{e3=2000,index=2}}}},
            {type="sl1",num={20,6},index=3,reward={f={{e1=10000,index=1}}}},
            {type="sl1",num={1,9},index=4,reward={p={{p410=15,index=1},{p836=15,index=2}}}},
            {type="sl1",num={1,12},index=5,reward={o={{a10043=15,index=1},{a10113=15,index=2}}}},
            {type="sl2",num={500},index=6,reward={aw={{ap5=50,index=1},{exp=10000,index=2}}}},
            {type="sl2",num={1000},index=7,reward={p={{p4023=20,index=1}}}},
        },
    },
}

return demining 
