local easterGift ={ -- 复活节彩蛋大搜寻活动
    multiSelectType=true,
   [1]={
        type=1,
        sortId=101,
        version=1,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}
            [1]={r={props_p5=1,props_p2=1,props_p19=5,props_p47=3},rechange=0},-- 登陆礼包
            [2]={r={props_p572=10,props_p573=10,props_p574=10,props_p575=10},rechange=1},-- 充值礼包
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}
            [1]={r={p={{p5=1,index=1},{p2=1,index=2},{p19=5,index=3},{p47=3,index=4}}},rechange=0},
            [2]={r={p={{p572=10,index=1},{p573=10,index=2},{p574=10,index=3},{p575=10,index=4}}},rechange=1},
        },
    },
    [2]={ -- 日本充值礼包大派送
        type=1,
        sortId=101,
        version=2,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}
            [1]={r={props_p247=10,props_p252=10,props_p257=10,props_p262=10},rechange=1},
            [2]={r={props_p247=100,props_p252=100,props_p257=100,props_p262=100},rechange=8000},
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}
            [1]={r={p={{p247=10,index=1},{p252=10,index=2},{p257=10,index=3},{p262=10,index=4}}},rechange=1},
            [2]={r={p={{p247=100,index=1},{p252=100,index=2},{p257=100,index=3},{p262=100,index=4}}},rechange=8000},
        },
    },

	[3]={ 
        type=1,
        sortId=101,
        version=3,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}
            [1]={r={props_p572=8,props_p573=8,props_p574=8,props_p575=8},rechange=1},
            [2]={r={props_p572=80,props_p573=80,props_p574=80,props_p575=80},rechange=10000},
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}
            [1]={r={p={{p572=8,index=1},{p573=8,index=2},{p574=8,index=3},{p575=8,index=4}}},rechange=1},
            [2]={r={p={{p572=80,index=1},{p573=80,index=2},{p574=80,index=3},{p575=80,index=4}}},rechange=10000},
        },
    },
	
	[4]={ 
        type=1,
        sortId=101,
        version=4,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}
            [1]={r={props_p242=8,props_p864=8,props_p241=8,props_p576=8},rechange=1},
            [2]={r={props_p242=80,props_p864=80,props_p241=80,props_p576=80},rechange=10000},
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}
            [1]={r={p={{p242=8,index=1},{p864=8,index=2},{p241=8,index=3},{p576=8,index=4}}},rechange=1},
            [2]={r={p={{p242=80,index=1},{p864=80,index=2},{p241=80,index=3},{p576=80,index=4}}},rechange=10000},
        },
    },
	
	[5]={ 
        type=1,
        sortId=101,
        version=5,
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}
            [1]={r={props_p823=6,props_p826=6,props_p822=6,props_p824=6},rechange=1},
            [2]={r={props_p823=60,props_p826=60,props_p822=60,props_p824=60},rechange=12000},
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}
            [1]={r={p={{p823=6,index=1},{p826=6,index=2},{p822=6,index=3},{p824=6,index=4}}},rechange=1},
            [2]={r={p={{p823=60,index=1},{p826=60,index=2},{p822=60,index=3},{p824=60,index=4}}},rechange=12000},
        },
    },
	[6]={ 					
        type=1,						
        sortId=101,						
        version=6,						
        serverreward={						
             -- 服务端数据						
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}						
            [1]={r={props_p1409=5,props_p1410=5,props_p1411=5,props_p1412=5},rechange=1},						
            [2]={r={props_p1409=50,props_p1410=50,props_p1411=50,props_p1412=50},rechange=12000},						
        },						
        reward={						
             -- 客户端数据						
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}						
            [1]={r={p={{p1409=5,index=1},{p1410=5,index=2},{p1411=5,index=3},{p1412=5,index=4}}},rechange=1},						
            [2]={r={p={{p1409=50,index=1},{p1410=50,index=2},{p1411=50,index=3},{p1412=50,index=4}}},rechange=12000},						
        },						
    },						

	[7]={ 					
        type=1,						
        sortId=101,						
        version=7,						
        serverreward={						
             -- 服务端数据						
             -- [档次]={r={奖励道具=数量},rechange=最低充值钻石数}						
            [1]={r={props_p1403=5,props_p1406=5,props_p1402=5,props_p1404=5},rechange=1},						
            [2]={r={props_p1403=50,props_p1406=50,props_p1402=50,props_p1404=50},rechange=16000},						
        },						
        reward={						
             -- 客户端数据						
             -- [档次]={r={p={奖励道具=数量,index=排序}},rechange=最低充值钻石数}}						
            [1]={r={p={{p1403=5,index=1},{p1406=5,index=2},{p1402=5,index=3},{p1404=5,index=4}}},rechange=1},						
            [2]={r={p={{p1403=50,index=1},{p1406=50,index=2},{p1402=50,index=3},{p1404=50,index=4}}},rechange=16000},						
        },						
    },						
								
}
return easterGift
