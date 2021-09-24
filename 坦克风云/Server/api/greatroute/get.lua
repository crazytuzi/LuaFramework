local function api_greatroute_get(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },
        }
    end

    function self.before(request) 
        local response = self.response
        local uid=request.uid
    
        if not uid then
            response.ret = -102
            return response
        end

        local matchInfo,code = loadFuncModel("serverbattle").getGreatRouteInfo()
        if not next(matchInfo) then
            response.ret = -180
            return response
        end

        self.matchInfo = matchInfo
    end

    --[[
        
    ]]
    function self.action_index(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUGreatRoute = uobjs.getModel("ugreatroute")
        local aid = uobjs.getModel("userinfo").alliance
        if aid == 0 then
            response.ret = -102
            return response
        end

        local bid = tonumber(self.matchInfo.bid)
        local mAGreatRoute = getModelObjs("agreatroute",aid,true)

        if mAGreatRoute.checkApplyOfWar() then
            if mUGreatRoute.setBid(mAGreatRoute.bid) then
                uobjs.save()
            end
        end

        response.data.greatRoute = {
            bid = bid,  -- 大战id
            servers = self.matchInfo.servers,   -- 本级大战的服信息
            ugreatroute = mUGreatRoute.toArray(true),   -- 用户模块数据
            agreatroute = {
                apply=mAGreatRoute.apply,   -- 军团报名标识
                score=mAGreatRoute.score,   -- 军团当前总积分
            },
            crossIp = getConfig("config.worldwarserver.worldwarserverurl"), -- 跨服地址(复用了世界大战的)
        }

        -- 客户端判定能否进入地图时，需要用到部队数据
        -- 伟大航线设兵无消耗,下一期(bid不一致时)后端没有做清除处理
        -- 不给客户端返回即可(下次设置会覆盖)
        local mTGreatRoute = getModelObjs("tgreatroute",uid,true)
        if mTGreatRoute.bid == bid then
            response.data.greatRoute.ugreatroute.troopInfo = mTGreatRoute.troops
        end
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    
    --[[
        商店信息
        进行领奖期后，商店才可购买，客户端需要在商店界面显示自己的军团排名和积分(只有这一个地方有积分显示)
        排名会奖励积分，客户端调用时在此接口做检测，并发放
    ]]
    function self.action_shop(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local aid = uobjs.getModel("userinfo").alliance

        -- 无军团时，客户端不应该调用
        if aid < 0 then
            response.ret = -102
            return response
        end

        -- 不是领奖期
        local mAGreatRoute = getModelObjs("agreatroute",aid)
        if not mAGreatRoute.isRewardStage() then
            response.ret = -102
            return response
        end

        -- 没有报名，客户端不应该调用
        if not mAGreatRoute.checkApplyOfWar() then
            response.ret = -8483
            return response
        end

        -- 与客户端约定，如果该军团未上榜(前100)，给一个默认的排名
        local defaultRanking = 1001

        -- 军团排名，若未从服务器同步过，为默认值0
        local ranking = mAGreatRoute.ranking

        -- 同步并设置军团排名
        if ranking == 0 then
            local rankingList = mAGreatRoute.getRankingList()
            local key = getZoneId() .. "-" .. aid
            ranking = tonumber(rankingList[key]) or defaultRanking
            mAGreatRoute.setRanking(ranking)
            if not mAGreatRoute.save() then
                return response
            end
        end
        
        local mUGreatRoute = uobjs.getModel("ugreatroute")

        -- 按排名发放奖励
        if ranking < defaultRanking then
            if not mUGreatRoute.isRewarded() then
                mUGreatRoute.rankingReward(ranking)
                if not uobjs.save() then
                    return response
                end
            end
        end

        response.data.score = mUGreatRoute.getScore()
        response.data.ranking = ranking
        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- function self.after() end

    return self
end

return api_greatroute_get