acCjyxVo=activityVo:new()

function acCjyxVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acCjyxVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if data.free then --已使用的免费次数
            self.free=data.free
        end
        if data.free then --当前分数
            self.free=data.free
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        if data.r1 then--是否已经领取过排行榜奖励(记录的是名次,可以查这个值来确定领奖时的名次)
            self.rankRewardFlag=data.r1
        end
        if data.score then
            self.score=data.score
        end
    end
end

-- local cijiuyingxin={
--     multiSelectType=true,  --支持多版本
--     [1]={
--         _activeCfg=true,
--         type=1,
--         sortId=200,
        
--         --点燃1次
--         cost1=58,
--         --点燃10次
--         cost2=580,
    
--     --前台展示  对应4种鞭炮  最上面的显示列表，展示第4个奖池内容
--     reward={
--             [1]={w={{c1=1,index=1},{c2=1,index=2},{c3=1,index=3}}},
--             [2]={w={{c1=1,index=1},{c2=1,index=2},{c3=1,index=3}}},
--             [3]={w={{c1=1,index=1},{c2=1,index=2},{c3=1,index=3}}},
--         [4]={w={{c1=1,index=1},{c2=1,index=2},{c3=1,index=3}}},
--         },
    
--     --排行榜上榜积分限制
--     rankLimit=200,
        
--     rankReward={  --前台排行榜奖励
--         {{1,1},{p={{p988=30,index=1},{p267=5,index=2},{p230=2,index=3}}}},
--         {{2,2},{p={{p988=15,index=1},{p267=3,index=2},{p230=1,index=3}}}},
--         {{3,3},{e={{p6=5,index=3}},p={{p988=10,index=1},{p267=2,index=2}}}},
--         {{4,5},{e={{p6=3,index=3}},p={{p988=5,index=1},{p266=5,index=2}}}},
--         {{6,10},{e={{p6=2,index=3}},p={{p988=5,index=1},{p266=3,index=2}}}},
--         },

--     serverreward={
    
--     --4种鞭炮的随机权重
--     randomWeight={50,30,20,10},
    
--     --4种鞭炮对应的积分随机范围  其中挂鞭炮奖池比较特殊
--     --挂鞭炮积分获得：例：先从randomWeight中随机权重为【挂鞭炮】，然后从scoreList中的{5,10}中随机出一个【积分】，然后用【积分 * randomNum】 
--     scoreList={{10,20},{15,25},{5,10},{25,35}},

--     --穿天猴奖池：pool1随一次
--     pool1={
--         {100},
--                 {3,3,3},
--         {{"weapon_c1",1},{"weapon_c2",1},{"weapon_c3",1}},
--     },
    
--     --pool2和pool3为二踢脚奖池
--     --二踢脚规则：先在pool2中随一次，再在pool3中随一次
--     pool2={
--         {100},
--                 {3,3,3},
--         {{"weapon_c1",1},{"weapon_c2",1},{"weapon_c3",1}},
--     },
--     pool3={
--         {100},
--                 {3,3,3},
--         {{"weapon_c1",1},{"weapon_c2",1},{"weapon_c3",1}},
--     },
        
--     --pool4为挂鞭炮奖池
--     --挂鞭炮规则：先从randomNum中随机出一个【倍数】，再从pool4中随机出一个【奖励】，然后【奖励的数量 * 倍数】
--     randomNum={3,5},
--     pool4={
--         {100},
--                 {3,3,3},
--         {{"weapon_c1",1},{"weapon_c2",1},{"weapon_c3",1}},
--     },
    
--     --pool5为礼花弹奖池：pool5随一次
--     pool5={
--         {100},
--                 {3,3,3},
--         {{"weapon_c1",1},{"weapon_c2",1},{"weapon_c3",1}},
--     },


--     rankReward={  --后台排行榜奖励
--                 {{1,1},{props_p988=30,props_p267=5,props_p230=2}},
--                 {{2,2},{props_p988=15,props_p267=3,props_p230=1}},
--                 {{3,3},{props_p988=10,props_p267=2,accessory_p6=5}},
--                 {{4,5},{props_p988=5,props_p266=5,accessory_p6=3}},
--                 {{6,10},{props_p988=5,props_p266=3,accessory_p6=2}},
--        },
--     },

--     },
-- }

-- return cijiuyingxin
