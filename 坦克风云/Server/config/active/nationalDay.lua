local nationalDay={
    multiSelectType=true,
    [1]={
        
        equipOpenLevel=20,
        
        --在同一奖池下抽奖X次也会自动刷新奖池
        ReNum=10,
        
        --刷新价格
        refreshCost=28,
        
        --抽奖消耗
        Cost1=68,
        
        --10连消耗
        Cost2=628,
        
        probability={30,25,40,40,40,45,40,30},
        
        serverreward={
            randomPool1={
                {100},
                {1,2,3,4,5,5,4,3,2,1},
                {{"userinfo_gems",5},{"userinfo_gems",10},{"userinfo_gems",15},{"userinfo_gems",20},{"userinfo_gems",25},{"userinfo_gems",30},{"userinfo_gems",35},{"userinfo_gems",40},{"userinfo_gems",45},{"userinfo_gems",50}},
            },
            
            randomPool2={
                {100},
                {5,5,5,5,5,5,5,6,5,7},
                {{"props_p275",10},{"props_p276",20},{"props_p277",100},{"accessory_p4",5000},{"props_p278",4},{"props_p279",20},{"props_p277",100},{"props_p88",10},{"props_p89",2},{"props_p89",1}},
            },
            
            randomPool3={
                {100},
                {10,9,8,7,6,5,4,3,2,1},
                {{"props_p3330",1},{"props_p3330",2},{"props_p3330",3},{"props_p3330",4},{"props_p3330",5},{"props_p3330",6},{"props_p3330",7},{"props_p3330",8},{"props_p3330",9},{"props_p3330",10}},
            },
            
            randomPool4={
                {100},
                {1,1,1,1,1,1,1,1,1,1},
                {{"props_p611",1},{"props_p612",1},{"props_p613",1},{"props_p614",1},{"props_p615",1},{"props_p616",1},{"props_p617",1},{"props_p618",1},{"props_p601",5},{"props_p19",5}},
            },
            
            randomPool5={
                {100},
                {10,10,10,10,10,2,2,2,2,2},
                {{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1},{"props_p30",1},{"props_p32",1},{"props_p33",1},{"props_p34",1},{"props_p35",1},{"props_p36",1}},
            },
            
            randomPool6={
                {100},
                {5,5,5,5,5,7,7,5,5,2},
                {{"props_p277",10},{"props_p276",2},{"props_p275",1},{"accessory_p4",500},{"props_p279",2},{"accessory_p4",300},{"accessory_p4",250},{"props_p279",1},{"props_p88",1},{"props_p276",1}},
            },
            
            randomPool7={
                {100},
                {10,9,8,7,6,5,4,3,2,1},
                {{"props_p3330",1},{"props_p3330",2},{"props_p3330",3},{"props_p3330",4},{"props_p3330",5},{"props_p3330",6},{"props_p3330",7},{"props_p3330",8},{"props_p3330",9},{"props_p3330",10}},
            },
            
            randomPool8={
                {100},
                {10,10,10,10,10,10,10,1,1,1},
                {{"hero_s37",3},{"hero_s21",3},{"hero_s40",3},{"hero_s10",3},{"hero_s20",3},{"hero_s22",3},{"hero_s28",3},{"hero_s30",1},{"hero_s32",1},{"hero_s4",1}},
            },
            
            drop={dropRate=0.2,dropReward={"props_p3330",1}}
        },
        showList={e={{p4=5000,index=5}},h={{s37=3,index=25},{s21=3,index=26},{s40=3,index=27},{s10=3,index=28},{s20=3,index=29},{s22=3,index=30},{s28=3,index=31},{s30=1,index=32},{s32=1,index=33},{s4=1,index=34}},p={{p275=10,index=2},{p276=20,index=3},{p277=100,index=4},{p278=4,index=6},{p279=20,index=7},{p88=10,index=8},{p89=2,index=9},{p611=1,index=10},{p612=1,index=11},{p613=1,index=12},{p614=1,index=13},{p615=1,index=14},{p616=1,index=15},{p617=1,index=16},{p618=1,index=17},{p601=5,index=18},{p19=5,index=19},{p32=1,index=20},{p33=1,index=21},{p34=1,index=22},{p35=1,index=23},{p36=1,index=24},{p3330=10,index=35}},u={{gems=50,index=1}}},    --前台展示列表
        
        
        task={ 
            {key="cn",needNum=5,reward={p={{p2=1,index=1},{p3330=1,index=2}}},serverReward={props_p2=1,props_p3330=1}},
            {key="pp",needNum=3,reward={p={{p15=1,index=1},{p3330=2,index=2}}},serverReward={props_p15=1,props_p3330=2}},
            {key="pe",needNum=5,reward={p={{p19=3,index=1},{p3330=1,index=2}}},serverReward={props_p19=3,props_p3330=1}},
            {key="au",needNum=5,reward={e={{p6=1,index=1}},p={{p3330=2,index=2}}},serverReward={accessory_p6=1,props_p3330=2}},
            {key="ab",needNum=5,reward={e={{p3=5,index=1}},p={{p3330=1,index=2}}},serverReward={accessory_p3=5,props_p3330=1}},
            {key="mb",needNum=5,reward={p={{p47=3,index=1},{p3330=1,index=2}}},serverReward={props_p47=3,props_p3330=1}},
            {key="mw",needNum=5,reward={p={{p292=1,index=1},{p3330=2,index=2}}},serverReward={props_p292=1,props_p3330=2}},
            {key="rb",needNum=5,reward={e={{p4=300,index=1}},p={{p3330=2,index=2}}},serverReward={accessory_p4=300,props_p3330=2}},
            {key="eb",needNum=5,reward={p={{p447=1,index=1},{p3330=1,index=2}}},serverReward={props_p447=1,props_p3330=1}},
            {key="eu",needNum=1,reward={p={{p819=1,index=1},{p3330=1,index=2}}},serverReward={props_p819=1,props_p3330=1}},
            {key="cj",needNum=5,reward={p={{p819=1,index=1},{p3330=1,index=2}}},serverReward={props_p819=1,props_p3330=1}},
        },
        exchange={
            {id=1,maxLimit = 1,price={p3330=400},reward={h={{h4=1}}},serverReward={hero_h4=1}},
            {id=2,maxLimit = 1,price={p3330=350},reward={h={{h30=1}}},serverReward={hero_h30=1}},
            {id=3,maxLimit = 1,price={p3330=350},reward={h={{h32=1}}},serverReward={hero_h32=1}},
            {id=4,maxLimit = 1,price={p3330=1200},reward={p={{p804=1}}},serverReward={props_p804=1}},
            {id=5,maxLimit = 1,price={p3330=400},reward={p={{p90=1}}},serverReward={props_p90=1}},
            {id=6,maxLimit = 5,price={p3330=50},reward={p={{p89=1}}},serverReward={props_p89=1}},
            {id=7,maxLimit = 10,price={p3330=15},reward={p={{p88=1}}},serverReward={props_p88=1}},
            {id=8,maxLimit = 500,price={p3330=10},reward={p={{p2=1}}},serverReward={props_p2=1}},
            {id=9,maxLimit = 2,price={p3330=100},reward={p={{p230=1}}},serverReward={props_p230=1}},
            {id=10,maxLimit = 10,price={p3330=15},reward={p={{p278=1}}},serverReward={props_p278=1}},
            {id=11,maxLimit = 100,price={p3330=10},reward={p={{p283=1}}},serverReward={props_p283=1}},
        },
    },
}

return nationalDay
