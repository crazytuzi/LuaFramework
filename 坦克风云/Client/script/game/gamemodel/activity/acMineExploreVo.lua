acMineExploreVo=activityVo:new()
function acMineExploreVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acMineExploreVo:updateSpecialData(data)
    if data~=nil then
        --活动配置数据
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        --活动玩家数据
        if data.mid then --当前地图id
            self.mid=data.mid
        end
        if data.rt then --地图的旋转方向
            self.rd=data.rt
        end
        if data.map then --已经探索过的地图块数据
            self.map=data.map
        end
        if data.base then --出生地点
            self.base=data.base
        end
        if data.entry then --本层通往下层的入口
            self.entry=data.entry
        end
        if data.emap then --可往周围扩展的地图块
            self.emap=data.emap
        end
        if data.box then --地图隐藏宝箱的块
            self.box=data.box
        end
        if data.free then --已用的免费次数
            self.free=data.free
        end
        if data.t then --上次挖掘的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        if data.score then --代币数量
            self.score=data.score
        end
        if data.l then --当前层数
            self.l=data.l
        end
        if data.rank then --第几名到达该层
            self.rank=data.rank
        end
        if data.shop then --商店数据
            self.shop=data.shop
        end
    end
end

--以下是活动配置数据注释
-- local mineExplore={
--     multiSelectType=true,  --支持多版本
--     [1]={
--         _activeCfg=true,
--         type=1,
--         sortId=200,     
--         --抽1次
--         cost1=50,
--         --抽5次
--         cost2=250,
            -- reward={    --每层两个大宝箱，前台点击后的显示
            -- [1]={p={{p3324=200,index=1}}},
            -- [2]={e={{p1=15,index=2},{p2=15,index=3}},p={{p3335=1,index=1}}},
            -- },

--         shop={  --商店  
--                 --bn:显示折扣比例，有的物品为0  为0时不显示折扣比例
--                 --p：显示最初价格  g:打折后价格
--                 --reward:前台
--                 i1={bn=5,p=480,g=48,reward={p={p1=1}},serverreward={props_p1=1}},
--                 i2={bn=0,p=560,g=560,reward={p={p49=1}},serverreward={props_p49=1}},
--                 i3={bn=5,p=400,g=40,reward={p={p3302=1}},serverreward={props_p3302=1}},
--                 i4={bn=5,p=210,g=21,reward={p={p5=1}},serverreward={props_p5=1}},
--                 i5={bn=5,p=140,g=14,reward={p={p15=5}},serverreward={props_p15=5}},
--                 i6={bn=5,p=98,g=10,reward={p={p16=1}},serverreward={props_p16=1}},
--                 i7={bn=5,p=150,g=15,reward={p={p47=10}},serverreward={props_p47=10}},               
--             },
--         layerLimit=10,  --从10层后开始有层数奖励
--         rank={      --每层根据到达该层的排名，会获得一个赠送积分
--             {{1,1},score=50},
--             {{2,5},score=30},
--             {{6,10},score=20},
--             {{10,50},score=10},
--         },
--     },
-- }
-- return mineExplore
