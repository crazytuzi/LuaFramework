acYswjVo=activityVo:new()
function acYswjVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acYswjVo:updateSpecialData(data)
    if data~=nil then
    	--活动配置数据
     	if data._activeCfg then
     		self.activeCfg=data._activeCfg
     	end
     	--活动数据
     	if data.p then --当前陨石列表
     		self.stoneList=data.p
     	end
        if data.d then --已经抽到的陨石列表
            self.rewardFlagTb={}
            for k,v in pairs(data.d) do
               self.rewardFlagTb[v]=1 
            end
        end
     	if data.t then --上一次抽奖的时间（跨天免费使用）
     		self.lastTime=data.t
     	end
        if data.v then --单次抽奖的次数
            self.gatherNum=data.v
        end
        if data.task then --任务进度数据
            self.task=data.task
        end
        if data.tr then --任务奖励是否领取的标记
            self.tr={}
            for k,v in pairs(data.tr) do
                self.tr[v]=1
            end
        end
        if data.c then --免费次数
            self.free=data.c
        end
    end
end

--[[local yswj={
    multiSelectType=true,
    [1]={
        _activeCfg=true,
        sortId=200,
        type=1,
        version=1,
        
        --挖一次所需金币
        cost1=48,
        --全部挖掘所需金币
        cost2=432,
        
        --每轮刷新的矿石数量
        aeroliteNum=8,
        --每抽 X 次后刷新
        playNum=4,
        
        --每轮刷新必然出现的{小石头、中石头、大石头、神秘袋子}的数量
        mustHave={2,2,1,0},
        --刷新{小石头、中石头、大石头、神秘袋子}的权重
        renovateRatio={45,35,15,5},
        --瞄准{小石头、中石头、大石头、神秘袋子}的权重
        aimRatio={40,40,15,5},
        
        --异星资源提炼（前台）
        --get：提炼获得  cost：提炼消耗
        resource={
            [1]={
                get={r={r2=1000}},
                cost={r={r1=100000},p={p879=10}},
            },
            [2]={
                get={r={r3=100}},
                cost={r={r2=10000},p={p879=10}},
            },
        },
        
        --前台奖励显示
        showList={
            [1]={p={{p879=1,index=1}}},
            [2]={p={{p879=3,index=4}},r={{r3=10,index=1},{r2=50,index=2},{r1=300,index=3}}},
            [3]={p={{p879=5,index=4}},r={{r3=30,index=1},{r2=100,index=2},{r1=1000,index=3}}},
            [4]={r={{r3=10,index=1},{r2=100,index=2},{r1=1000,index=3}}},
        },
        serverreward={
            --异星资源提炼（后台）
            resource={
                [1]={
                    get={alien_r2=1000},
                    cost={alien_r1=100000,props_p879=10},
                },
                [2]={
                    get={alien_r3=100},
                    cost={alien_r2=10000,props_p879=10},
                },
            },
            
            --小石头奖池
            randomPool1={
                {100},
                {1},
                {{"props_p879",1}},
            },
            --中石头奖池
            randomPool2={
                {100},
                {10,20,35,35},
                {{"alien_r3",10},{"alien_r2",50},{"alien_r1",300},{"props_p879",3}},
            },
            --大石头奖池
            randomPool3={
                {100},
                {10,20,35,35},
                {{"alien_r3",30},{"alien_r2",100},{"alien_r1",1000},{"props_p879",5}},
            },
            --神秘袋子奖励
            randomPool4={alien_r3=10,alien_r2=100,alien_r1=1000},
        },
        
        --type:任务类型  1：在活动中抽奖获得X异星晶尘  2：在活动中抽奖获得X异星晶岩  3：在活动中抽奖获得X异星晶核  4：在活动中改造获得X异星晶岩  5：在活动中改造获得X异星晶岩  6：全面挖掘X次
        --index:排序
        --needNum:完成条件
        --任务是整个活动期间的，每日不重置
        task={
            {type=1,index=1,needNum=3000,reward={r={{r4=100,index=1},{r5=100,index=2},{r6=100,index=3}}},serverreward={alien_r4=100,alien_r5=100,alien_r6=100}},
            {type=2,index=2,needNum=500,reward={r={{r4=100,index=1},{r5=100,index=2},{r6=100,index=3}}},serverreward={alien_r4=100,alien_r5=100,alien_r6=100}},
            {type=3,index=3,needNum=200,reward={r={{r4=200,index=1},{r5=200,index=2},{r6=200,index=3}}},serverreward={alien_r4=200,alien_r5=200,alien_r6=200}},
            {type=4,index=4,needNum=5000,reward={r={{r4=100,index=1},{r5=100,index=2},{r6=100,index=3}}},serverreward={alien_r4=100,alien_r5=100,alien_r6=100}},
            {type=5,index=5,needNum=500,reward={r={{r4=100,index=1},{r5=100,index=2},{r6=100,index=3}}},serverreward={alien_r4=100,alien_r5=100,alien_r6=100}},
            {type=6,index=6,needNum=5,reward={r={{r4=400,index=1},{r5=400,index=2},{r6=400,index=3}}},serverreward={alien_r4=400,alien_r5=400,alien_r6=400}},
        },
    },
}

return yswj ]]
