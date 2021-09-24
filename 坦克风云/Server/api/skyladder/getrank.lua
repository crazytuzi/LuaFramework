function api_skyladder_getrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled('ladder') == 0 then
        response.ret = -19000
        return response
    end
    
    local ts = getClientTs()
    local uid = request.uid
    local action = request.params.action
    local page = tonumber(request.params.page) or 1
    -- local rankList = {
        -- {1000001,1000,'aa',1000000,1},
        -- {2000002,1000,'bb',1000000,2},
        -- {2000003,1000,'cc',1000000,2},
    -- }
    
    if action == 1 then
        id = request.uid
    else
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo"})
        local mUserinfo = uobjs.getModel('userinfo')  
        id = mUserinfo.alliance
    end
    
    require "model.skyladder"
    local skyladder = model_skyladder()
    local rankList = skyladder.getRankInfo(action)
    --ptb:p(rankList)
    local myRank = 0
    local score = 0
    local detail = {}

    if id and tonumber(id) > 0 then
        uMyRank,uDetail = skyladder.getMyRank(action,id)
        if uMyRank then
            myRank = uMyRank
        end
        
        if uDetail and type(uDetail) == 'table' then
            for i,v in pairs(uDetail) do
                score = score + tonumber(v)
            end
            detail = uDetail
        end

        -- 保证积分详情和排行榜上的分数一致
        --[[
        for i,v in pairs(rankList) do
            if tonumber(v[1]) == tonumber(id) then
                if tonumber(v[2]) < score then -- 排行榜上的数据小于详情 单独更新服内排行榜
                    local redis = getRedis()
                    local base = skyladder.getBase()
                    
                    rankList[i][2] = score
                    
                    if base and type(base) == 'table' and base.cubid then
                        local keys  = "z" .. getZoneId() ..".skyladder.rank"..base.cubid.."-"..action
                        redis:set(keys,json.encode(rankList))
                        redis:expire(keys,300)
                    end
                elseif tonumber(v[2]) > score then -- 积分详情不是最新 重新拉取积分详情并更新积分和排名
                    uMyRank,uDetail = skyladder.getMyRank(action,id,true)
                    if uMyRank then
                        myRank = uMyRank
                    end
                    
                    score = 0
                    if uDetail and type(uDetail) == 'table' then
                        for i,v in pairs(uDetail) do
                            score = score + tonumber(v)
                        end
                        detail = uDetail
                    end
                end
            end
        end
        ]]
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.ladder = {action=action,myrank = {rank=myRank,score=score,detail=detail},rankList = rankList}

    return response
end