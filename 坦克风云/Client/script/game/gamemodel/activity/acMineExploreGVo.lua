acMineExploreGVo=activityVo:new()
function acMineExploreGVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acMineExploreGVo:updateSpecialData(data)
    if data~=nil then
        --活动配置数据
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        --活动玩家数据
        -- if data.mid then --当前地图id
        --     self.mid=data.mid
        -- end
        -- if data.rt then --地图的旋转方向
        --     self.rd=data.rt
        -- end
        -- if data.map then --已经探索过的地图块数据
        --     self.map=data.map
        -- end
        -- if data.base then --出生地点
        --     self.base=data.base
        -- end
        -- if data.entry then --本层通往下层的入口
        --     self.entry=data.entry
        -- end
        -- if data.emap then --可往周围扩展的地图块
        --     self.emap=data.emap
        -- end
        -- if data.box then --地图隐藏宝箱的块
        --     self.box=data.box
        -- end
        if data.free then --已用的免费次数
            self.free=data.free
        end
        if data.t then --上次挖掘的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end
        if data.score then --代币数量
            self.score=data.score
        end
        -- if data.l then --当前层数
        --     self.l=data.l
        -- end
        -- if data.rank then --第几名到达该层
        --     self.rank=data.rank
        -- end
        if data.shop then --商店数据
            self.shop=data.shop
        end
    end
end