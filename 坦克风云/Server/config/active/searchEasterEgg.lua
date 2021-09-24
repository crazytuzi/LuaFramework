local searchEasterEgg ={ -- 复活节彩蛋大搜寻活动
    multiSelectType=true,
    [1]={
        type=1,
        sortId=100,
        version=0,
        floaterWeight=70, -- 城内漂浮物出现权重，1至100之间，值越大，越容易出现，原值是33
        egg1Probability=1, -- 幸运彩蛋获得概率
        egg2Probability=0.34, -- 勇气彩蛋获得概率
        egg3Probability=0.34, -- 丰收彩蛋获得概率
        serverreward={
             -- 服务端数据
             -- [档次]={r={奖励道具=数量},egg={egg1=幸运彩蛋数量，egg2=勇气彩蛋数量，egg3=丰收彩蛋数量}}
            [1]={r={props_p417=1,props_p19=1,props_p47=1},egg={egg1=1,egg2=1}}, -- 配件补充包
            [2]={r={props_p447=2,props_p19=1,props_p47=1},egg={egg1=1,egg3=1}},-- 中级将领经验书
            [3]={r={props_p988=2,props_p19=2,props_p47=2},egg={egg1=1,egg2=1,egg3=1}},-- 高级战舰宝箱
        },
        reward={
             -- 客户端数据
             -- [档次]={r={p={奖励道具=数量,index=排序}},egg={egg1=幸运彩蛋数量，egg2=勇气彩蛋数量，egg3=丰收彩蛋数量}}
            [1]={r={p={{p417=1,index=1},{p19=1,index=2},{p47=1,index=3}}},egg={egg1=1,egg2=1}},
            [2]={r={p={{p447=2,index=1},{p19=1,index=2},{p47=1,index=3}}},egg={egg1=1,egg3=1}},
            [3]={r={p={{p988=2,index=1},{p19=2,index=2},{p47=2,index=3}}},egg={egg1=1,egg2=1,egg3=1}},
        },
    },

}
return searchEasterEgg
