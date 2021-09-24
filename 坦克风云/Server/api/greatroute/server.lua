local function api_greatroute_server(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    self._cronApi = {
        ["*"] = true,
    }

    -- 设置军团信息
    function self.action_apply( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zid)
        local aid = tonumber(request.params.aid)

        if not aid or not bid then
            response.ret = -102
            return response
        end

        local GreatRoute = loadModel("model.greatrouteserver")
        local ret, err = GreatRoute:addAllianceDataToDb(bid,request.params)
        
        if not ret then
            if not GreatRoute:getAllianceDataFromDb(bid,zid,aid) then
                response.err = err
                response.ret = -27502
                return response
            end
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 设置用户信息
    function self.action_setMember( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zid)
        local member = request.params
        local uid = member.uid

        if not uid or not bid then
            response.ret = -102
            return response
        end

        local GreatRoute = loadModel("model.greatrouteserver")
        
        local ret, err
        ret, err = GreatRoute:addMemberDataToDb(bid,member)
        if not ret then
            if GreatRoute:getMemberDataFromDb(bid,uid) then 
                ret,err = GreatRoute:updateMemberData(bid,uid,member)
            end
        end

        GreatRoute:setAidToCache(bid,zid,member.aid)

        if not ret then
            response.err = err
            response.ret = -27502
            return response
        end

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
        获取单个入侵者信息
    ]]
    function self.action_getInvader(request)
        local response = self.response
        local bid = request.params.bid
        local zid = request.params.zid
        local uid = tonumber(request.params.uid)

        if not bid or not uid or not zid then
            response.ret = -102
            return response 
        end

        local GreatRoute = loadModel("model.greatrouteserver")
        local invader = GreatRoute:getInvader(bid,uid)

        response.data = {
            invader = invader, 
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 获取入侵者列表
    function self.action_getInvaderList(request)
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zid)
        local aid = tonumber(request.params.aid)

        if not aid or not bid or not zid then
            response.ret = -102
            return response 
        end

        local GreatRoute = loadModel("model.greatrouteserver")
        local invaders, invaderKeys = GreatRoute:genInvaders(bid,zid,aid)

        response.data = {
            invaders = invaders, 
            invaderKeys= invaderKeys
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 同步积分
    function self.action_syncScore( request )
        local response = self.response
        local bid = request.params.bid
        local zid = tonumber(request.params.zid)

        if not zid or not bid then
            response.ret = -102
            return response
        end

        local data = request.params.data

        local GreatRoute = loadModel("model.greatrouteserver")
        local result = GreatRoute:syncScore(bid,zid,data)

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 获取军团排行榜
    function self.action_getAllianceRankingList(request)
        local response = self.response
        local bid = request.params.bid

        if not bid then
            response.ret = -102
            return response
        end

        local rankingList = loadModel("model.greatrouteserver"):getAllianceRankingList(bid)

        response.data = rankingList
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    return self
end

return api_greatroute_server
