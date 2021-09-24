local function returnCfg(clientPlat)
    local commonCfg={
        minRegistrationFee=1000,        -- 报名 最少花费
        startWarTime={{20,0},{20,0},{22,0},{22,0},{20,0},{20,0},{22,0},{22,0}},  --开战时间
        numberOfBattle=15,          -- 最大 上阵人数
        cdTime=120,         -- 战斗 冷却时间 120秒 （2分钟）
        stronghold={
            h1={icon="CheckPointIcon1.png",winPoint=40,name="hold_name1",x=147,y=607},
            h2={icon="CheckPointIcon1.png",winPoint=40,name="hold_name2",x=525,y=406},
            h3={icon="CheckPointIcon1.png",winPoint=40,name="hold_name3",x=238,y=240},
            h4={icon="CheckPointIcon1.png",winPoint=40,name="hold_name4",x=133,y=365},
            h5={icon="CheckPointIcon3.png",winPoint=70,name="hold_name5",x=432,y=251},
            h6={icon="CheckPointIcon3.png",winPoint=70,name="hold_name6",x=85,y=500},
            h7={icon="CheckPointIcon3.png",winPoint=70,name="hold_name7",x=346,y=606},
            h8={icon="CheckPointIcon3.png",winPoint=70,name="hold_name8",x=565,y=588},
            h9={icon="CheckPointIcon6.png",winPoint=100,name="hold_name9",x=319,y=448},
        },
        winPointMax=500000,     --  胜利所需胜利点数 50 万
        warTime=1800,           --  战斗最大战斗时间 30 分钟
        buffSkill={
            b1={maxLv=10,cost=8,per=0.05,probability={100,95,90,85,80,75,70,65,60,55},donate=3,icon="WarBuffSmeltExpert.png",name="buff1Name"},
            b2={maxLv=10,cost=8,per=0.03,probability={100,95,90,85,80,75,70,65,60,55},donate=3,icon="WarBuffCommander.png",name="buff2Name"},
            b3={maxLv=5,cost=18,per=0.10,probability={100,90,80,70,60},donate=6,icon="WarBuffNetget.png",name="buff3Name"},
            b4={maxLv=5,cost=18,per=0.05,probability={100,90,80,70,60},donate=6,icon="WarBuffStatistician.png",name="buff4Name"},
        },
        mvpDonate=200,  -- MVP 贡献加成
        winDonate=150,      -- 胜利 贡献结算
        failDonate=50,      -- 失败 贡献结算
        occupiedRes=100,    -- 占领 资源加成
        resourceAddition={200,100,100,200,100,200,100,200},    --  占领 优化版资源加成

        winPointToDonate = 0.005, -- 积分换成贡献
        tankDonate={
            a10001=0.002,a10002=0.004,a10003=0.008,a10004=0.015,a10005=0.03,a10006=0.06,a10011=0.002,a10012=0.004,a10013=0.008,a10014=0.015,a10015=0.03,a10016=0.06,a10021=0.002,a10022=0.004,a10023=0.008,a10024=0.015,a10025=0.03,a10026=0.06,a10031=0.002,a10032=0.004,a10033=0.008,a10034=0.015,a10035=0.03,a10036=0.06,a10043=0.045,a10053=0.05,a10063=0.045,a10073=0.05,a10082=0.05,a10093=0.04,a10044=0.07,a10054=0.075,a10064=0.07,a10074=0.075,a10083=0.075,a10103=0.01,a10113=0.05,a10123=0.05
        },

        --报名时间
        signUpTime=
        {
            --报名的开始时间 {时,分}
            start={9,0},
            --报名的结束时间 {时,分}
            finish={14,0}
        },


    }

    --stronghold 据点配置表 h1:据点1 -据点9 icon:图片名称  x,y 为前台显示坐标 winPoint每秒胜利点数(后台用到)
    --startWarTime  g1战场 战争开始时间10点20 g1-g4 四个战场
    --buffSkill buff配置 b1-b4 maxLv:buff最大等级 cost:花费金币 per:每级增加的百分比 probability:升每一级的成功几率 donate:buff提供的每级的贡献


    -- winPointToDonate = 0.005,
    --1;莫斯科     大   8:00    pm
    --2, 斯大林格勒  小   8:00    pm
    --3, 哈尔科夫       小   10:00   pm
    --4, 库尔斯克       大   10:00   pm
    --5, 阿拉曼        小   8:00    pm
    --6, 诺曼底        大   8:00    pm
    --7,马奇诺防线   小   10:00   pm
    --8,阿登森林        大   10:00   pm

    local platCfg={

        kunlun_na = {
            startWarTime={{18,0},{18,0},{20,0},{20,0},{18,0},{18,0},{20,0},{20,0}},  --开战时间
        },

        ["1mobile"] = {
            startWarTime={{18,0},{18,0},{20,0},{20,0},{18,0},{18,0},{20,0},{20,0}},  --开战时间
        },

    }

    if clientPlat ~= 'def' then
        if platCfg and type(platCfg[clientPlat]) == 'table' then
            for k,v in pairs(platCfg[clientPlat]) do
                commonCfg[k] = v
            end
        end
    end

    return commonCfg
end

return returnCfg