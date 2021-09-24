--[[
    伟大航线玩家模块
]]
function model_ugreatroute(uid,data)
    local self = {
        uid = uid,
        bid=0,  -- 大战id
        score=0,   -- 分数
        feat=0,    -- 功绩
        actionpoint=0,    -- 行动点数
        buff=0,    -- buff 编号
        rewarded = 0, -- 结算奖励标识
        explored={},    -- 已探索过的据点
        shop={},    -- 商店已购信息
        day_buycnt=0, -- 每日购买次数
        ap_at=0,     -- 最近一次行动点恢复时间
        day_at=0, -- 当日时间戳,以此为依据跨天清数据
        updated_at=0,
    }

    -- 重置当天所有数据
    local function resetDailyData()
        self.day_buycnt=0
        self.shop={}
    end

    local bean = {}

    function bean.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            if data[k] == nil then return false end

            if type(v) == 'number' then
                self[k] = tonumber(data[k]) or data[k]
            else
                self[k] = data[k]
            end
        end

        -- 重置与天相关的数据
        local weeTs = getWeeTs()
        if self.day_at < weeTs then
            self.day_at = weeTs
            resetDailyData()
        end

        return true
    end

    function bean.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if k~= 'uid' and k~= 'updated_at' then
                data[k] = v
            end
        end

        return data
    end

    function bean.setBid(bid)
        if self.bid ~= bid then
            self.bid = bid
            self.score=0   -- 分数
            self.feat=0    -- 功绩
            self.actionpoint=getConfig("greatRoute").main.initialPoint    -- 行动点数
            self.buff=0    -- buff 编号
            self.rewarded = 0 -- 结算奖励标识
            self.explored={}    -- 已探索过的据点
            self.shop={}    -- 商店已购信息
            self.day_buycnt=0 -- 每日购买次数
            self.ap_at=0     -- 最近一次行动点恢复时间
            self.day_at=0 -- 当日时间戳,以此为依据跨天清数据

            return true
        end
    end

    -- 商店购买设置次数
    function bean.setShop(item,num)
        if num < 0 then return end
        self.shop[item] = (self.shop[item] or 0) + math.ceil(num)
        return self.shop[item]
    end

    -- 增加积分
    function bean.addScore(score)
        if score > 0 then
            self.score = self.score + math.floor(score)
            return self.score
        end
    end

    -- 减少积分
    function bean.reduceScore(score)
        if score>0 then
            if self.score<score then 
                return false 
            end
            self.score = self.score - score
            return true
        end
    end

    -- 设置积分值
    function bean.setScore(score)
        self.score = score
    end

    function bean.getScore()
        return self.score
    end

    function bean.addFeat(feat)
        if feat > 0 then
            self.feat = self.feat + math.floor(feat)
            local aid = getUserObjs(self.uid).getModel("userinfo").alliance
            if aid > 0 then
                getModelObjs("agreatroute",aid,true).setSyncData({1,self.uid,self.feat})
            end
        end
    end

    function bean.getFeat()
        return self.feat
    end

    function bean.buyAcPoint(point)
        bean.refreshAcPoint()
        self.day_buycnt = self.day_buycnt + 1
        bean.recoverAcPoint(point)
    end

    -- 获取行动点售卖信息
    function bean.getAPointSellInfo()
        local cfg = getConfig("greatRoute").main
        local price = cfg.buyPrice[self.day_buycnt+1] or cfg.buyPrice[#cfg.buyPrice]
        
        return price, cfg.buyGet
    end

    -- 刷新行动点数
    function bean.refreshAcPoint()
        if self.ap_at > 0 then
            local cfg = getConfig("greatRoute").main

            -- 做个兼容判断,如果行动点数超过上限,把恢复点置0
            if self.actionpoint >= cfg.initialPoint then
                self.ap_at = 0
                return
            end

            -- 自然恢复
            local n = math.floor( (getClientTs() - self.ap_at) / cfg.pointRegain )
            if n > 0 then
                self.actionpoint = self.actionpoint + n
                self.ap_at = self.ap_at + n * cfg.pointRegain

                -- 自然恢复有上限
                if self.actionpoint >= cfg.initialPoint then
                    self.actionpoint = cfg.initialPoint
                    self.ap_at = 0
                end                
            end
        end
    end

    -- 恢复行动点数
    function bean.recoverAcPoint(point)
        self.actionpoint = self.actionpoint + point
        if self.actionpoint >= getConfig("greatRoute").main.initialPoint then
            self.ap_at = 0
        end
    end

    function bean.reduceAcPoint(point)
        point = point or getConfig("greatRoute").main.pointCost
        bean.refreshAcPoint()
        self.actionpoint = self.actionpoint - point
        if self.actionpoint < 0 then
            return false
        end

        if self.ap_at == 0 and self.actionpoint < getConfig("greatRoute").main.initialPoint then
            self.ap_at = os.time()
        end

        return true
    end

    -- buffId = [b1,b2 ...]
    function bean.setBuff(buffId)
        if buffId then
            self.buff = tonumber(string.sub(buffId, 2))
        end
    end

    function bean.getBuff()
        if self.buff > 0 then
            local buff = "b" .. self.buff
            self.buff = 0
            return buff
        end
    end

    -- 判断该据点是否已探索
    function bean.wasExplored(fortId)
        return table.contains(self.explored,fortId)
    end

    -- 探索据点
    function bean.explore(fortId)
        if not bean.wasExplored(fortId) then
            table.insert(self.explored,fortId)
        end
    end

    -- 是否已领奖
    function bean.isRewarded()
        return self.rewarded > 0
    end

    -- 排名奖励
    function bean.rankingReward(ranking)
        if not bean.isRewarded() then
            local cfg = getConfig("greatRoute").rankScore
            local rScore
            for k,v in pairs(cfg) do
                if v.rank == ranking then
                    rScore = v.score
                    break
                elseif type(v.rank) == "table" then
                    if ranking >= v.rank[1] and ranking <= v.rank[2] then
                        rScore = v.score
                        break
                    end
                end
            end

            if rScore then
                bean.addScore(rScore)
            end

            -- 1仅仅是领奖标识
            self.rewarded = rScore or 1
        end
    end

    return bean
end
