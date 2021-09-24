acChristmasFightVo=activityVo:new()
function acChristmasFightVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

    --配置数据
    self.pointRewardCfg={}  --达到指定贡献获得奖励
    self.bpIncrease=0       --军功提高配置
    self.resIncrease=0      --采集速度提高配置
    self.addRes=0           --玩家进行采集x资源，进度条增加1点；向下取证
    self.addBp=0            --玩家获得x军功，进度条增加1点；
    self.cost=nil           --花费金币配置
    self.tenCost=nil        --十连抽花费金币配置
    self.addMin=0           --每秒钟雪人上方进度条增加n点配置
    self.lotNum=0           --抽奖增加和减少的点数配置
    self.maxPoint=0         --进度条点数配置
    self.bigRewardCfg={}    --进度条减少时大奖配置
    self.poolCfg={}         --奖池配置
    self.cRankLimit=0       --贡献大于多少点才可上榜配置
    self.aRankLimit=0       --活跃大于多少点才可上榜配置
    self.rankNum=0          --排行榜上榜人数配置
    self.cRankRewardCfg={}  --贡献榜奖励配置
    self.aRankRewardCfg={}  --活跃榜奖励配置
    self.pool={}            --抽奖奖励库

    --玩家活动数据
    self.cPoint=0           --贡献点数
    self.aPoint=0           --活跃点数
    self.lastTime=0         --上一次抽奖当天的0点时间戳
    self.hasReward={}       --排行榜是否领取获奖励{1,2}1是活跃，2是贡献
    self.hasPointReward={}  --贡献奖励获取了第几档
    self.freeNum=0          --今日使用免费抽奖次数

	return nc
end

function acChristmasFightVo:updateSpecialData(data)
    self.acEt=self.et-86400

    -- --达到指定贡献获得奖励
    -- pR={
    --     {p=100,r={p={p19=1},},
    --     {p=200,r={p={p20=1},},},
    --     {p=400,r={p={p1=1},},},
    -- },
    -- --军功提高
    -- bIncr=0.2,
    -- --采集速度提高
    -- rIncr=0.2,
    -- --每x秒钟雪人上方进度条增加n点；
    -- addMin=600,
    -- --玩家进行采集xM资源，进度条增加n点；向下取证
    -- addRes=100000,
    -- --玩家获得x军功，进度条增加n点；
    -- addBp=100000,
    -- --抽奖增加和减少的点数
    -- lotNum=1,
    -- --进度条点数
    -- maxPoint=500,
    -- --进度条减少时几个大奖
    -- bR={
    --     p301={p={p19=2}},
    --     p201={p={p19=2}},
    --     p101={p={p19=2}},
    --     p1={p={p19=2}},
    -- },
    -- --单抽金币
    -- oneCost=38,
    -- --十连抽金币
    -- tenCost=388,
    -- --抽奖奖池
    -- pool={
    --     angel={ -- 天使


    --     },
    --     demon={  -- 恶魔


    --     },
    -- },
    -- --贡献大于多少点才可上榜
    -- cRankp=1000,
    -- --活跃大于多少点才可上榜
    -- aRankp=1000,
    -- --排行榜上榜人数
    -- rankNum=10,

    --配置数据
    if data.dreward then
        self.pointRewardCfg=data.dreward
    end
    if data.bIncr then
        self.bpIncrease=tonumber(data.bIncr)
    end
    if data.rIncr then
        self.resIncrease=tonumber(data.rIncr)
    end
    if data.addRes then
        self.addRes=tonumber(data.addRes)
    end
    if data.addBp then
        self.addBp=tonumber(data.addBp)
    end
    if data.oneCost then
        self.cost=tonumber(data.oneCost)
    end
    if data.tenCost then
        self.tenCost=tonumber(data.tenCost)
    end
    if data.addMin then
        self.addMin=tonumber(data.addMin)
    end
    if data.lotNum then
        self.lotNum=tonumber(data.lotNum)
    end
    if data.maxPoint then
        self.maxPoint=tonumber(data.maxPoint)
    end
    if data.bR then
        self.bigRewardCfg={}
        for k,v in pairs(data.bR) do
            local pt=(tonumber(k) or tonumber(RemoveFirstChar(k)))
            table.insert(self.bigRewardCfg,{p=pt,r=v})
        end
        local function sortFunc(a,b)
            return a.p>b.p
        end
        table.sort(self.bigRewardCfg,sortFunc)
    end
    if data.pool then
        self.poolCfg=data.pool
    end
    if data.cRankp then
        self.cRankLimit=tonumber(data.cRankp)
    end
    if data.aRankp then
        self.aRankLimit=tonumber(data.aRankp)
    end
    if data.rankNum then
        self.rankNum=tonumber(data.rankNum)
    end
    if data.rankReward1 then
        self.cRankRewardCfg=data.rankReward1
    end
    if data.rankReward2 then
        self.aRankRewardCfg=data.rankReward2
    end

    if data.version then
        self.version=data.version
    end

    --活动数据
    if data.d then
        self.cPoint=data.d
    end
    if data.v then
        self.aPoint=data.v
    end
    if data.t then
        self.lastTime=data.t
    end
    if data.r then
        self.hasReward=data.r
    end
    if data.dr then
        self.hasPointReward=data.dr
    end
    if data.c then
        self.freeNum=data.c
    end

end
