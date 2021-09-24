local mingjiangpeiyang={
    multiSelectType=true,
    [1]={
        --麦克阿瑟
        sortId=200,
        type=1,
        freeNum=1,
        version=1,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h26=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h19",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h19=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [2]={
        --铁木辛哥
        sortId=200,
        type=1,
        freeNum=1,
        version=2,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h15=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h9",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h9=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [3]={
        --曼施坦因
        sortId=200,
        type=1,
        freeNum=1,
        version=3,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h3=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h18",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h18=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [4]={
        --巴顿
        sortId=200,
        type=1,
        freeNum=1,
        version=4,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h24=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h8",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h8=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [5]={
        --朱可夫
        sortId=200,
        type=1,
        freeNum=1,
        version=5,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h13=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h6",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h6=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [6]={
        --隆美尔
        sortId=200,
        type=1,
        freeNum=1,
        version=6,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h1=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h16",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h16=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [7]={
        --崔可夫
        sortId=200,
        type=1,
        freeNum=1,
        version=7,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h14=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h7",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h7=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },
    [8]={
        --古德里安
        sortId=200,
        type=1,
        freeNum=1,
        version=8,  --将领活动不同版本，对应描述
        
        cost1=98,  --单抽金币
        cost2=882,  --十连抽金币
        
        pointTimes=2,  --第一轮获得积分点数翻倍
        maxPoint=400,  --每个进度条的最大值
        randomItem={27,18,12,8},  --4个进度条的随机权重   每次抽奖，先随机增加哪一个进度条，然后随机奖励，根据奖励，随机增加点数
        mustGetHero={hero_h2=4},  --必给的四星将领
        
        serverreward={
            randomPool={     --每次抽奖的随机奖池
                {100},
                {3,3,3,3,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,100,80,80,10,10,10,10,10,10,10,10,60,30,20,20,20,20,20,20,20,10,10,10,10,10,10,10},
                {{"hero_h4",2},{"hero_h30",2},{"hero_h32",2},{"hero_h39",2},{"hero_h17",1},{"hero_h11",1},{"hero_h12",1},{"hero_h21",1},{"hero_h22",1},{"hero_h23",1},{"hero_h27",1},{"hero_h28",1},{"hero_h29",1},{"hero_h31",1},{"hero_h33",1},{"hero_h34",1},{"hero_h35",1},{"hero_h36",1},{"hero_h37",1},{"hero_h38",1},{"hero_h40",1},{"props_p447",3},{"props_p448",1},{"props_p601",10},{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p606",5},{"props_p607",3},{"props_p621",5},{"props_p622",5},{"props_p623",5},{"props_p624",5},{"props_p625",5},{"props_p626",5},{"props_p627",5},{"props_p631",2},{"props_p632",2},{"props_p633",2},{"props_p634",2},{"props_p635",2},{"props_p636",2},{"props_p637",2}},
            },
            
            pointType={   --奖励排序,后台对应奖励所能随机分数范围
                hero_h4=1,
                hero_h30=2,
                hero_h32=3,
                hero_h39=4,
                hero_h17=5,
                hero_h11=6,
                hero_h12=7,
                hero_h21=8,
                hero_h22=9,
                hero_h23=10,
                hero_h27=11,
                hero_h28=12,
                hero_h29=13,
                hero_h31=14,
                hero_h33=15,
                hero_h34=16,
                hero_h35=17,
                hero_h36=18,
                hero_h37=19,
                hero_h38=20,
                hero_h40=21,
                props_p447=22,
                props_p448=23,
                props_p601=24,
                props_p611=25,
                props_p612=26,
                props_p613=27,
                props_p614=28,
                props_p615=29,
                props_p616=30,
                props_p617=31,
                props_p618=32,
                props_p606=33,
                props_p607=34,
                props_p621=35,
                props_p622=36,
                props_p623=37,
                props_p624=38,
                props_p625=39,
                props_p626=40,
                props_p627=41,
                props_p631=42,
                props_p632=43,
                props_p633=44,
                props_p634=45,
                props_p635=46,
                props_p636=47,
                props_p637=48,
            },
            
            --对应pointTypr奖励增加的分数范围  例：排序1的物品，获得分数范围为{20,30}
            pointList={{60,90},{60,90},{60,90},{60,90},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{16,24},{8,16},{10,20},{4,8},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{8,15},{4,8},{5,10},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{4,8},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12},{6,12}},
            
            getReward={   --对应每个进度条达到最大值（maxPoint）时获得的奖励
                [1]={props_p607=20},
                [2]={props_p601=50},
                [3]={props_p20=20},
                [4]={props_p448=10},
            },
        },
        clientReward={  --对应每个进度条达到最大值获得奖励的前台显示
            [1]={p={{p607=20}}},
            [2]={p={{p601=50}}},
            [3]={p={{p20=20}}},
            [4]={p={{p448=10}}},
        },
    },

}

return mingjiangpeiyang