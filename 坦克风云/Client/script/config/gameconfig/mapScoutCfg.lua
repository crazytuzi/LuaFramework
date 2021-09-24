mapScoutCfg={
    --vip普通搜索次数限制，对应v0至v12
    vipScout={3,6,10,15,20,25,30,35,40,45,50,55,60},
    
    --普通搜索
    --type:1.铁矿 2.石油 3.铅矿 4.钛矿 5.水晶
    common={
        {type=1,icon="tie_kuang_building_1.png",name="world_island_1"},
        {type=2,icon="shi_you_building_1.png",name="world_island_2"},
        {type=3,icon="qian_kuang_building.png",name="world_island_3"},
        {type=4,icon="tai_kuang_building.png",name="world_island_4"},
        {type=5,icon="shui_jing_world_building_1.png",name="world_island_5"},
    },
    
    --特殊搜索等级限制
    scoutLv=20,
    
    --特殊搜索
    --type:1.叛军（消耗军团里的个人贡献） 2.金矿（消耗军功商店的货币，军功币） 3.玩家基地 4.玩家部队 5.保护矿 6.欧米伽小队（消耗飞艇原料）
    --switch:开关限制
    --need1:搜索金币消耗
    --need2:搜索道具消耗
    special={
        {type=1,icon="world_rebel.png",name="world_rebel",switch="isRebelOpen",need1={100,500,2000,6000,12500}},
        {type=2,icon="world_gold.png",name="world_goldmine",switch="goldmine",need1={500000,2500000,10000000,25000000,50000000}},
        {type=3,icon="player_home.png",name="world_player_base",need2={p={p3304=1}}},
        {type=4,icon="player_fleet.png",name="world_player_fleet",need2={p={p3305=1}}},
        {type=5,icon="privateMineicon.png",name="privateMineName",notNeed=true,},
        {type=6,icon="world_omg.png",name="world_airshipboss",switch="airShipSwitch",need1={200,300}},

    },
    
}



