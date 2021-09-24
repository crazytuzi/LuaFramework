local allianceshare ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        serverreward={
            --礼包价格
            cost={50,910,3420,7000},
            --分享礼包数
            shareNum={20,20,20,20},
            --礼包类型（1.通用  2.将领  3.方阵  4.配件）
            getType={1,2,3,4},
            --奖励1
            gift1={{"props_p20",1},{"props_p19",2}},
            --奖励2
            gift2={{"props_p4810",20},{"props_p601",30}},
            --奖励3
            gift3={{"props_p4604",1},{"armor_exp",6000}},
            --奖励4
            gift4={{"props_p816",1},{"accessory_p3",100},{"accessory_p4",10000}},
            --奖池1
            pool1={
                {100},
                {30,10,12,12,12,12,12},
                {{"props_p20",1},{"props_p19",1},{"props_p30",1},{"props_p26",1},{"props_p27",1},{"props_p28",1},{"props_p29",1}},
            },
            
            --奖池2
            pool2={
                {100},
                {5,10,10,10,20},
                {{"props_p4810",3},{"props_p470",2},{"props_p471",2},{"props_p469",2},{"props_p601",2}},
            },
            
            --奖池3
            pool3={
                {100},
                {20,20,20,20,20,20,20},
                {{"props_p4513",1},{"props_p4514",1},{"props_p4515",1},{"props_p4516",1},{"props_p4517",1},{"props_p4518",1},{"armor_exp",1000}},
            },
            
            --奖池4
            pool4={
                {100},
                {1,8,8,8,8,8,8,8,8,80,80},
                {{"props_p813",1},{"props_p188",1},{"props_p191",1},{"props_p200",1},{"props_p203",1},{"props_p212",1},{"props_p215",1},{"props_p224",1},{"props_p227",1},{"accessory_p3",30},{"accessory_p4",2000}},
            },
            
        },
        rewardTB={
            --奖池1
            {cost=50,shareNum=20,getType=1,gift={p={{p20=1,index=1},{p19=2,index=2}}},pool={p={{p20=1,index=2},{p19=1,index=1},{p30=1,index=3},{p26=1,index=4},{p27=1,index=5},{p28=1,index=6},{p29=1,index=7}}},specialIndex={p={{p20=1}}}},
            
            --奖池2
            {cost=910,shareNum=20,getType=2,gift={p={{p4810=20,index=1},{p601=30,index=2}}},pool={p={{p4810=3,index=5},{p470=2,index=2},{p471=2,index=3},{p469=2,index=1},{p601=2,index=4}}},specialIndex={p={{p4810=3}}}},
            
            --奖池3
            {cost=3420,shareNum=20,getType=3,gift={p={{p4604=1,index=1}},am={{exp=6000,index=2}}},pool={p={{p4513=1,index=1},{p4514=1,index=2},{p4515=1,index=3},{p4516=1,index=4},{p4517=1,index=5},{p4518=1,index=6}},am={{exp=1000,index=7}}},specialIndex={p={{p4516=1},{p4517=1}}}},
            
            --奖池4
            {cost=7000,shareNum=20,getType=4,gift={e={{p3=100,index=2},{p4=10000,index=3}},p={{p816=1,index=1}}},pool={e={{p3=30,index=10},{p4=2000,index=11}},p={{p813=1,index=1},{p188=1,index=2},{p191=1,index=3},{p200=1,index=4},{p203=1,index=5},{p212=1,index=6},{p215=1,index=7},{p224=1,index=8},{p227=1,index=9}}},specialIndex={p={{p813=1}}}},
            
        },
    },
}

return allianceshare 
