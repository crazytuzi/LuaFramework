 acRoulette5Vo=activityVo:new()
function acRoulette5Vo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acRoulette5Vo:updateSpecialData(data)
  --   {
  -- "zhenqinghuikui": {
  --   "v": 212, 剩余的抽奖次数
  --   "q": 1417536000, 黑夜十二点的时间戳  是否需要重置次数和已经抽取的次数
  --   "m": [   免费次数的刷新标识
  --     1417536000,  第一个时间段  该时间 < 当前黑夜十二点的时间戳时候需要增加免费次数
  --     0 第二个时间段
  --   ],
  --   "p": 11, 活动期间兑换完次数后剩余的金币数量
  --   "k": 11,  已经抽取的次数
  -- }

   --飞流_真情反馈
        -- zhenqinghuikui={
        --     type=1,
        --     sortId=477,
        --     --f1={11:30-12:00, 18:30-19:00} 每天可以获取免费次数的俩个时间段
        --     startTime={
        --         {{11,30},{12,0}},
        --         {{18,30},{19,0}},
        --     },
        --     --mm实物奖励
        --     showlist={
        --         o={{a10113=0.5,index=1},{a10123=0.5,index=2},},
        --         p={{p32=1,index=3},{p19=1,index=7},{p20=1,index=8},{p5=1,index=9},{p292=1,index=10},{p393=1,index=11},{p267=1,index=12},},
        --         mm={{m1=1,index=4},{m2=1,index=5},{m3=1,index=6}},
        --     },
        --     --goldNum 获取一次抽奖机会的条件
        --     goldNum = 400,
        --     --自定义道具名称
        --     rewardtype={"iphone6","小王子","小公主"},
        --     serverreward={
        --         --抽到实物奖励的概率 20
        --         vate=20,
        --         --共12个  这里配9个虚拟道具 其他自定义配置
        --         pool={
        --             {100},
        --             {9,9,9,9,13,1,},
        --             {{"props_p32",1},{"props_p32",1},{"props_p19",1},{"props_p20",1},{"props_p5",1},{"props_p393",1},},
        --         },
        --     },
        -- },
    if data.version then
        self.version = data.version
    end
    if data.activeTitle then
        self.acName =data.activeTitle
    end
    if data.gamename then
        self.gameName =data.gamename
    end
    if self.acCfg==nil then
        self.acCfg={}
        self.acCfg.startTime={}
        self.acCfg.durationTime={}
    end
    if data.startTime and data.startTime[1][1] then  --1 免时
        self.acCfg.startTime[1]=data.startTime[1][1]
    end
    if data.startTime and data.startTime[2][1] then  --2 免时
        self.acCfg.startTime[2]=data.startTime[2][1]
    end

    if data.goldNum then                     --获取抽奖机会的金币数额
        self.acCfg.lotteryConsume=data.goldNum or {}
    end

    if data.startTime and data.startTime[1][2] then
        self.acCfg.durationTime[1]=data.startTime[1][2]
    end
    if data.startTime and data.startTime[2][2] then
        self.acCfg.durationTime[2]=data.startTime[2][2]
    end

    if data.showlist then               --抽奖物品列表
        self.acCfg.pool=data.showlist or {}
    end    

    if data.rewardtype then     -------------实物道具名称
        self.acCfg.rewardtype=data.rewardtype
    end


    if data.m ~=nil then  --拿到两次免费时间戳

        self.freeTime=data.m
    end
    --今日已经抽奖次数(总次数)
    if self.leftNum==nil then
    	self.leftNum=0
    end
    if data.v then
        self.leftNum=data.v
    end
    if data.k then
    	self.hasUsedNum=tonumber(data.k) or 0
    end
    if data.p then
        self.rechargeNum = data.p
    end

    --上次抽奖、充值时间的凌晨时间戳
    if self.lastTime==nil then
    	self.lastTime=0
    end
    if data.q then
    	self.lastTime=tonumber(data.q) or 0
    end


    if self.lastTime and G_isToday(self.lastTime)==false then
        -- self.consume=0
        self.hasUsedNum=0

       self.leftNum=0
        --self.hasUsedFreeNum={}
       self.rechargeNum=0
    end


end


