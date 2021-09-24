local hothero ={
    multiSelectType = true,
    [1]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h26","hero_h15",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s26",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p612",1},{"props_p615",1},{"props_p613",1},{"props_p614",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p624",1},{"props_p626",1},{"props_p631",1},{"props_p634",1},{"props_p636",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {85,54,24,200,58,4,4,4,4,10,10,30,30,30,30,30,30,30,30},
                {{"hero_s15",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p611",1},{"props_p617",1},{"props_p615",1},{"props_p613",1},{"props_p606",1},{"props_p607",1},{"props_p627",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p637",1},{"props_p631",1},{"props_p632",1},{"props_p633",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s26=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p612=1,index=6},{p615=1,index=7},{p613=1,index=8},{p614=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p624=1,index=13},{p626=1,index=14},{p631=1,index=15},{p634=1,index=16},{p636=1,index=17}}},
        
        --对应奖池2
        showList2={h={{s15=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p611=1,index=6},{p617=1,index=7},{p615=1,index=8},{p613=1,index=9},{p606=1,index=10},{p607=1,index=11},{p627=1,index=12},{p621=1,index=13},{p622=1,index=14},{p623=1,index=15},{p637=1,index=16},{p631=1,index=17},{p632=1,index=18},{p633=1,index=19}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3370=4},{p20=3}}},serverreward={{"props_p3370",4},{"props_p20",3}},},
            {reward={p={{p3370=8},{p956=5}}},serverreward={{"props_p3370",8},{"props_p956",5}},},
            {reward={p={{p3370=12},{p959=5},{p956=5}}},serverreward={{"props_p3370",12},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [2]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h2","hero_h13",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s2",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p612",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p623",1},{"props_p622",1},{"props_p631",1},{"props_p633",1},{"props_p632",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s13",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p612",1},{"props_p616",1},{"props_p613",1},{"props_p617",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p622",1},{"props_p625",1},{"props_p631",1},{"props_p632",1},{"props_p635",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s2=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p612=1,index=6},{p615=1,index=7},{p616=1,index=8},{p617=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p623=1,index=13},{p622=1,index=14},{p631=1,index=15},{p633=1,index=16},{p632=1,index=17}}},
        
        --对应奖池2
        showList2={h={{s13=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p612=1,index=6},{p616=1,index=7},{p613=1,index=8},{p617=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p622=1,index=13},{p625=1,index=14},{p631=1,index=15},{p632=1,index=16},{p635=1,index=17}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3371=4},{p20=3}}},serverreward={{"props_p3371",4},{"props_p20",3}},},
            {reward={p={{p3371=8},{p956=5}}},serverreward={{"props_p3371",8},{"props_p956",5}},},
            {reward={p={{p3371=12},{p959=5},{p956=5}}},serverreward={{"props_p3371",12},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [3]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h4","hero_h32",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s4",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p612",1},{"props_p617",1},{"props_p614",1},{"props_p613",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p624",1},{"props_p622",1},{"props_p631",1},{"props_p634",1},{"props_p632",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {82,51,21,200,60,6,6,6,6,10,10,60,60,60,60},
                {{"hero_s32",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p611",1},{"props_p613",1},{"props_p616",1},{"props_p614",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p624",1},{"props_p631",1},{"props_p634",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s4=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p612=1,index=6},{p617=1,index=7},{p614=1,index=8},{p613=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p624=1,index=13},{p622=1,index=14},{p631=1,index=15},{p634=1,index=16},{p632=1,index=17}}},
        
        --对应奖池2
        showList2={h={{s32=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p611=1,index=6},{p613=1,index=7},{p616=1,index=8},{p614=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p624=1,index=13},{p631=1,index=14},{p634=1,index=15}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3372=4},{p20=3}}},serverreward={{"props_p3372",4},{"props_p20",3}},},
            {reward={p={{p3372=8},{p956=5}}},serverreward={{"props_p3372",8},{"props_p956",5}},},
            {reward={p={{p3372=12},{p959=5},{p956=5}}},serverreward={{"props_p3372",12},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [4]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h24","hero_h30",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s24",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p612",1},{"props_p615",1},{"props_p616",1},{"props_p614",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p624",1},{"props_p622",1},{"props_p631",1},{"props_p634",1},{"props_p632",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s30",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p611",1},{"props_p616",1},{"props_p613",1},{"props_p614",1},{"props_p606",1},{"props_p607",1},{"props_p622",1},{"props_p621",1},{"props_p623",1},{"props_p632",1},{"props_p631",1},{"props_p633",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s24=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p612=1,index=6},{p615=1,index=7},{p616=1,index=8},{p614=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p624=1,index=13},{p622=1,index=14},{p631=1,index=15},{p634=1,index=16},{p632=1,index=17}}},
        
        --对应奖池2
        showList2={h={{s30=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p611=1,index=6},{p616=1,index=7},{p613=1,index=8},{p614=1,index=9},{p606=1,index=10},{p607=1,index=11},{p622=1,index=12},{p621=1,index=13},{p623=1,index=14},{p632=1,index=15},{p631=1,index=16},{p633=1,index=17}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3373=4},{p20=3}}},serverreward={{"props_p3373",4},{"props_p20",3}},},
            {reward={p={{p3373=8},{p956=5}}},serverreward={{"props_p3373",8},{"props_p956",5}},},
            {reward={p={{p3373=12},{p959=5},{p956=5}}},serverreward={{"props_p3373",12},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [5]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h25","hero_h14",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {80,50,20,200,50,6,6,6,6,10,10,60,30,30,60,30,30},
                {{"hero_s25",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p612",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p606",1},{"props_p607",1},{"props_p621",1},{"props_p623",1},{"props_p622",1},{"props_p631",1},{"props_p633",1},{"props_p632",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {85,54,24,200,58,4,4,4,4,10,10,30,30,30,30,30,30,30,30},
                {{"hero_s14",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p611",1},{"props_p617",1},{"props_p615",1},{"props_p616",1},{"props_p606",1},{"props_p607",1},{"props_p627",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p637",1},{"props_p631",1},{"props_p632",1},{"props_p633",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s25=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p612=1,index=6},{p615=1,index=7},{p616=1,index=8},{p617=1,index=9},{p606=1,index=10},{p607=1,index=11},{p621=1,index=12},{p623=1,index=13},{p622=1,index=14},{p631=1,index=15},{p633=1,index=16},{p632=1,index=17}}},
        
        --对应奖池2
        showList2={h={{s14=1,index=1}},p={{p446=3,index=2},{p447=1,index=3},{p601=1,index=4},{p19=1,index=5},{p611=1,index=6},{p617=1,index=7},{p615=1,index=8},{p616=1,index=9},{p606=1,index=10},{p607=1,index=11},{p627=1,index=12},{p621=1,index=13},{p622=1,index=14},{p623=1,index=15},{p637=1,index=16},{p631=1,index=17},{p632=1,index=18},{p633=1,index=19}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3374=4},{p20=3}}},serverreward={{"props_p3374",4},{"props_p20",3}},},
            {reward={p={{p3374=8},{p956=5}}},serverreward={{"props_p3374",8},{"props_p956",5}},},
            {reward={p={{p3374=12},{p959=5},{p956=5}}},serverreward={{"props_p3374",12},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [6]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h39","hero_h7",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {5,5,20,30,100,500,60,60,60,60,70,35,35,70,35,35,100,20,200,200,200,200},
                {{"hero_s39",10},{"hero_s39",5},{"hero_s39",4},{"hero_s39",3},{"hero_s39",2},{"hero_s39",1},{"props_p611",1},{"props_p618",1},{"props_p613",1},{"props_p614",1},{"props_p622",1},{"props_p621",1},{"props_p624",1},{"props_p632",1},{"props_p631",1},{"props_p634",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {5,5,20,30,100,500,60,60,60,60,40,40,40,40,40,40,40,40,100,100,200,200,200,200},
                {{"hero_s7",10},{"hero_s7",5},{"hero_s7",4},{"hero_s7",3},{"hero_s7",2},{"hero_s7",1},{"props_p611",1},{"props_p614",1},{"props_p615",1},{"props_p617",1},{"props_p627",1},{"props_p621",1},{"props_p623",1},{"props_p622",1},{"props_p637",1},{"props_p631",1},{"props_p633",1},{"props_p632",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s39=10,index=1},{s39=5,index=2},{s39=4,index=3},{s39=3,index=4},{s39=2,index=5},{s39=1,index=6}},p={{p611=1,index=7},{p618=1,index=8},{p613=1,index=9},{p614=1,index=10},{p622=1,index=11},{p621=1,index=12},{p624=1,index=13},{p632=1,index=14},{p631=1,index=15},{p634=1,index=16},{p446=3,index=17},{p447=1,index=18},{p601=1,index=19},{p19=1,index=20},{p606=1,index=21},{p607=1,index=22}}},
        
        --对应奖池2
        showList2={h={{s7=10,index=1},{s7=5,index=2},{s7=4,index=3},{s7=3,index=4},{s7=2,index=5},{s7=1,index=6}},p={{p611=1,index=7},{p614=1,index=8},{p615=1,index=9},{p617=1,index=10},{p627=1,index=11},{p621=1,index=12},{p623=1,index=13},{p622=1,index=14},{p637=1,index=15},{p631=1,index=16},{p633=1,index=17},{p632=1,index=18},{p446=3,index=19},{p447=1,index=20},{p601=1,index=21},{p19=1,index=22},{p606=1,index=23},{p607=1,index=24}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3375=5},{p20=3}}},serverreward={{"props_p3375",5},{"props_p20",3}},},
            {reward={p={{p3375=15},{p956=5}}},serverreward={{"props_p3375",15},{"props_p956",5}},},
            {reward={p={{p3375=30},{p959=5},{p956=5}}},serverreward={{"props_p3375",30},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [7]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h9","hero_h10",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {5,20,50,100,150,300,50,50,50,50,40,40,40,40,40,40,40,40,100,100,150,150,150,150},
                {{"hero_s9",20},{"hero_s9",15},{"hero_s9",10},{"hero_s9",5},{"hero_s9",3},{"hero_s9",1},{"props_p611",1},{"props_p616",1},{"props_p614",1},{"props_p618",1},{"props_p627",1},{"props_p621",1},{"props_p623",1},{"props_p625",1},{"props_p637",1},{"props_p631",1},{"props_p633",1},{"props_p635",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {5,20,50,100,150,300,50,50,50,50,80,40,40,80,40,40,100,100,150,150,150,150},
                {{"hero_s10",20},{"hero_s10",15},{"hero_s10",10},{"hero_s10",5},{"hero_s10",3},{"hero_s10",1},{"props_p611",1},{"props_p616",1},{"props_p615",1},{"props_p614",1},{"props_p625",1},{"props_p621",1},{"props_p622",1},{"props_p635",1},{"props_p631",1},{"props_p632",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s9=20,index=1},{s9=15,index=2},{s9=10,index=3},{s9=5,index=4},{s9=3,index=5},{s9=1,index=6}},p={{p611=1,index=7},{p616=1,index=8},{p614=1,index=9},{p618=1,index=10},{p627=1,index=11},{p621=1,index=12},{p623=1,index=13},{p625=1,index=14},{p637=1,index=15},{p631=1,index=16},{p633=1,index=17},{p635=1,index=18},{p446=3,index=19},{p447=1,index=20},{p601=1,index=21},{p19=1,index=22},{p606=1,index=23},{p607=1,index=24}}},
        
        --对应奖池2
        showList2={h={{s10=20,index=1},{s10=15,index=2},{s10=10,index=3},{s10=5,index=4},{s10=3,index=5},{s10=1,index=6}},p={{p611=1,index=7},{p616=1,index=8},{p615=1,index=9},{p614=1,index=10},{p625=1,index=11},{p621=1,index=12},{p622=1,index=13},{p635=1,index=14},{p631=1,index=15},{p632=1,index=16},{p446=3,index=17},{p447=1,index=18},{p601=1,index=19},{p19=1,index=20},{p606=1,index=21},{p607=1,index=22}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3376=10},{p20=3}}},serverreward={{"props_p3376",10},{"props_p20",3}},},
            {reward={p={{p3376=30},{p956=5}}},serverreward={{"props_p3376",30},{"props_p956",5}},},
            {reward={p={{p3376=60},{p959=5},{p956=5}}},serverreward={{"props_p3376",60},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [8]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h21","hero_h27",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {5,20,50,100,150,300,50,50,50,50,80,40,40,80,40,40,100,100,150,150,150,150},
                {{"hero_s21",20},{"hero_s21",15},{"hero_s21",10},{"hero_s21",5},{"hero_s21",3},{"hero_s21",1},{"props_p611",1},{"props_p613",1},{"props_p618",1},{"props_p616",1},{"props_p623",1},{"props_p621",1},{"props_p622",1},{"props_p633",1},{"props_p631",1},{"props_p632",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {5,20,50,100,150,300,50,50,50,50,40,40,40,40,40,40,40,40,100,100,150,150,150,150},
                {{"hero_s27",20},{"hero_s27",15},{"hero_s27",10},{"hero_s27",5},{"hero_s27",3},{"hero_s27",1},{"props_p611",1},{"props_p613",1},{"props_p615",1},{"props_p614",1},{"props_p627",1},{"props_p621",1},{"props_p624",1},{"props_p625",1},{"props_p637",1},{"props_p631",1},{"props_p634",1},{"props_p635",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s21=20,index=1},{s21=15,index=2},{s21=10,index=3},{s21=5,index=4},{s21=3,index=5},{s21=1,index=6}},p={{p611=1,index=7},{p613=1,index=8},{p618=1,index=9},{p616=1,index=10},{p623=1,index=11},{p621=1,index=12},{p622=1,index=13},{p633=1,index=14},{p631=1,index=15},{p632=1,index=16},{p446=3,index=17},{p447=1,index=18},{p601=1,index=19},{p19=1,index=20},{p606=1,index=21},{p607=1,index=22}}},
        
        --对应奖池2
        showList2={h={{s27=20,index=1},{s27=15,index=2},{s27=10,index=3},{s27=5,index=4},{s27=3,index=5},{s27=1,index=6}},p={{p611=1,index=7},{p613=1,index=8},{p615=1,index=9},{p614=1,index=10},{p627=1,index=11},{p621=1,index=12},{p624=1,index=13},{p625=1,index=14},{p637=1,index=15},{p631=1,index=16},{p634=1,index=17},{p635=1,index=18},{p446=3,index=19},{p447=1,index=20},{p601=1,index=21},{p19=1,index=22},{p606=1,index=23},{p607=1,index=24}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3377=10},{p20=3}}},serverreward={{"props_p3377",10},{"props_p20",3}},},
            {reward={p={{p3377=30},{p956=5}}},serverreward={{"props_p3377",30},{"props_p956",5}},},
            {reward={p={{p3377=60},{p959=5},{p956=5}}},serverreward={{"props_p3377",60},{"props_p959",5},{"props_p956",5}},},
        },
    },
    [9]={
        sortid=201,
        type=1,
        --每次抽奖
        cost1=58,
        --十连抽价格
        cost2=522,
        --领取宝箱需要达到的积分
        scorelimit={100,300,600,},
        --将领选择
        heroalter={"hero_h19","hero_h22",},
        serverreward ={
            --奖池1
            pool1={
                {0,100},
                {5,20,50,100,150,300,50,50,50,50,40,40,40,40,40,40,40,40,100,100,150,150,150,150},
                {{"hero_s19",20},{"hero_s19",15},{"hero_s19",10},{"hero_s19",5},{"hero_s19",3},{"hero_s19",1},{"props_p611",1},{"props_p614",1},{"props_p613",1},{"props_p617",1},{"props_p627",1},{"props_p621",1},{"props_p622",1},{"props_p623",1},{"props_p637",1},{"props_p631",1},{"props_p632",1},{"props_p633",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
            
            --奖池2
            pool2={
                {0,100},
                {5,20,50,100,150,300,50,50,50,50,40,40,40,40,40,40,40,40,100,100,150,150,150,150},
                {{"hero_s22",20},{"hero_s22",15},{"hero_s22",10},{"hero_s22",5},{"hero_s22",3},{"hero_s22",1},{"props_p611",1},{"props_p613",1},{"props_p617",1},{"props_p614",1},{"props_p623",1},{"props_p621",1},{"props_p622",1},{"props_p625",1},{"props_p633",1},{"props_p631",1},{"props_p632",1},{"props_p635",1},{"props_p446",3},{"props_p447",1},{"props_p601",1},{"props_p19",1},{"props_p606",1},{"props_p607",1}},
                score={2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
            },
        },
        
        --对应奖池1
        showList1={h={{s19=20,index=1},{s19=15,index=2},{s19=10,index=3},{s19=5,index=4},{s19=3,index=5},{s19=1,index=6}},p={{p611=1,index=7},{p614=1,index=8},{p613=1,index=9},{p617=1,index=10},{p627=1,index=11},{p621=1,index=12},{p622=1,index=13},{p623=1,index=14},{p637=1,index=15},{p631=1,index=16},{p632=1,index=17},{p633=1,index=18},{p446=3,index=19},{p447=1,index=20},{p601=1,index=21},{p19=1,index=22},{p606=1,index=23},{p607=1,index=24}}},
        
        --对应奖池2
        showList2={h={{s22=20,index=1},{s22=15,index=2},{s22=10,index=3},{s22=5,index=4},{s22=3,index=5},{s22=1,index=6}},p={{p611=1,index=7},{p613=1,index=8},{p617=1,index=9},{p614=1,index=10},{p623=1,index=11},{p621=1,index=12},{p622=1,index=13},{p625=1,index=14},{p633=1,index=15},{p631=1,index=16},{p632=1,index=17},{p635=1,index=18},{p446=3,index=19},{p447=1,index=20},{p601=1,index=21},{p19=1,index=22},{p606=1,index=23},{p607=1,index=24}}},
        
        --指定宝箱1
        boxinfo={
            {reward={p={{p3378=10},{p20=3}}},serverreward={{"props_p3378",10},{"props_p20",3}},},
            {reward={p={{p3378=30},{p956=5}}},serverreward={{"props_p3378",30},{"props_p956",5}},},
            {reward={p={{p3378=60},{p959=5},{p956=5}}},serverreward={{"props_p3378",60},{"props_p959",5},{"props_p956",5}},},
        },
    },
}

return hothero 
