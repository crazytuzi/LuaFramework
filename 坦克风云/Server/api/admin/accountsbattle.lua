function api_admin_accountsbattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
    }

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local nextWeeTs = weeTs + 86400
    local battleType = request.params.battleType
    local cfg = getConfig("skyladderCfg")
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local base = skyladderserver.getStatus() or {}
    local rUserList = {}
    
    if tonumber(base.status) == 0 then
        response.ret = -19000
        response.msg = "error"
    end
    
    skyladderserver.setautocommit(false)
    writeLog('\n |' .. json.encode({ts=ts,battleType=battleType}) .. '\n','accountsbattleRun')
    
    function getSelectNum(battleType,cfg,stype)
        if not cfg then
            cfg = getConfig("skyladderCfg")
        end
        
        local num = 0
        local rankScoreCfg = cfg.battleRankScore['b'..battleType] or {}
        if battleType == 3 and stype then
            rankScoreCfg = rankScoreCfg[stype] or {}
        end
        for i,v in pairs(rankScoreCfg) do
            if v.range and type(v.range) == 'table' then
                if v.range[1] and v.range[2] and v.range[1] == v.range[2] then
                    num = num + 1
                elseif v.range[2] > v.range[1] then
                    num = num + (v.range[2] - v.range[1] + 1)
                end
            end
        end
        
        return num
    end
    
    function getAddScore(battleType,rank,cfg,stype)
        if not cfg then
            cfg = getConfig("skyladderCfg")
        end
        rank = tonumber(rank)
        local point = 0
        local rankScoreCfg = cfg.battleRankScore['b'..battleType] or {}
        if battleType == 3 and stype then
            rankScoreCfg = rankScoreCfg[stype] or {}
        end

        for i,v in pairs(rankScoreCfg) do
            if rank >= v.range[1] and rank <= v.range[2] and v.point then
                point = v.point
                break
            end
        end
        
        return point
    end
    
    --SET @counter=0;SELECT @counter:=@counter+1 AS rank,uid,nickname,ranking FROM battle WHERE bid = '1143_1' ORDER BY ranking  LIMIT 3
    if base.cubid and tonumber(base.cubid) > 0 then
        if battleType == 1 then
            local db = getCrossDbo("crossserver")
            local sevbattleCfg = getConfig("serverWarPersonalCfg")
            local hour = sevbattleCfg.startBattleTs[1][1] * 3600 + sevbattleCfg.startBattleTs[1][2] * 60 +sevbattleCfg.battleTime * 3
            local allBids = db:getAllRows("select bid from battle where et - 86400*4 + "..hour.." <= :ts and et - 86400*3 > :ts group by bid",{weeTs=weeTs,nextWeeTs=nextWeeTs,ts=ts})
            local save = false
            print('bid')
            ptb:p(allBids)
            if allBids and type(allBids) == 'table' then
                local rankLimit = getSelectNum(battleType,cfg)

                for i,v in pairs(allBids) do
                    local have = skyladderserver.getUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    if not have then
                        local allUser = db:getAllRows("select * from battle where bid = :bid and ranking > 0 ORDER BY ranking LIMIT :rankLimit",{bid=v.bid,rankLimit=rankLimit})
                        if allUser and type(allUser) == 'table' then
                            for _,uinfo in pairs(allUser) do
                                local addScore = getAddScore(battleType,uinfo.ranking,cfg)

                                if addScore > 0 then
                                    save = true
                                    -- local params = {
                                        -- s = 2, -- 类型1 类型2
                                        -- t = ts, --时间戳
                                        -- id1 = uinfo.uid, -- 自己id
                                        -- n1 = uinfo.nickname, -- 自己名字
                                        -- z1 = uinfo.zid, -- 自己区id
                                        -- pic1 = uinfo.pic, -- 自己pic
                                        -- add1 = addScore, -- 本次增加的分数
                                    -- }
                                    -- skyladderserver.saveRankData(base.cubid,'person',battleType,uinfo.zid,uinfo.uid,uinfo.nickname,addScore,uinfo.fc,uinfo.pic,params)

                                    if uinfo.aid and tonumber(uinfo.aid) > 0 then
                                        local params = {
                                            s = 2, -- 类型1 类型2
                                            r = battleType,
                                            t = ts, --时间戳
                                            id1 = uinfo.aid, -- 自己id
                                            n1 = uinfo.nickname, -- 自己名字
                                            z1 = uinfo.zid, -- 自己区id
                                            add1 = addScore, -- 本次增加的分数
                                            r1 = uinfo.ranking -- 排行
                                        }
                                        skyladderserver.saveRankData(base.cubid,'alliance',battleType,uinfo.zid,uinfo.aid,uinfo.aname,addScore,nil,nil,params,uinfo.bpic,uinfo.apic,uinfo.logo)
                                        table.insert(rUserList,{base.cubid,'alliance',battleType,uinfo.zid,uinfo.aid,uinfo.aname,addScore,'-','-',params})
                                    end
                                else
                                    writeLog('\n |' .. json.encode({battleType=battleType,bid=v.bid,uid=uinfo.uid,rank=uinfo.ranking}) .. '\n','skyladder_cron')
                                end
                            end
                            
                            skyladderserver.setUpdataStatus('account.'..battleType,base.cubid,v.bid)
                        end
                    end
                end
                if save then
                    print('save')
                    skyladderserver.commit()
                end
            end
        elseif battleType == 2 then
            local db = getCrossDbo("acrossserver")
            local sevbattleCfg = getConfig("serverWarTeamCfg")
            local hour = sevbattleCfg.startBattleTs[1][1] * 3600 + sevbattleCfg.startBattleTs[1][2] * 60 + sevbattleCfg.warTime + 300
            local allBids = db:getAllRows("select bid from alliance where et - 86400*4 + "..hour.." <= :ts and et  - 86400*3 >= :ts group by bid",{weeTs=weeTs,nextWeeTs=nextWeeTs,ts=ts})
            --local allBids = db:getAllRows("select bid from alliance group by bid",{weeTs=weeTs,nextWeeTs=nextWeeTs}) 
            local save = false
            print('bid')
            ptb:p(allBids)
            if allBids and type(allBids) == 'table' then
                local rankLimit = getSelectNum(battleType,cfg)
                for i,v in pairs(allBids) do
                    local have = skyladderserver.getUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    if not have then
                        local allUser = db:getAllRows("select * from alliance where bid = :bid and ranking > 0 ORDER BY ranking LIMIT :rankLimit",{bid=v.bid,rankLimit=rankLimit})

                        if allUser and type(allUser) == 'table' then
                            for _,ainfo in pairs(allUser) do
                                local addScore = getAddScore(battleType,ainfo.ranking,cfg)
                                
                                if addScore > 0 then
                                    save = true
                                    -- local params = {
                                        -- s = 2, -- 类型1 类型2
                                        -- t = ts, --时间戳
                                        -- id1 = ainfo.aid, -- 自己id
                                        -- n1 = ainfo.name, -- 自己名字
                                        -- z1 = ainfo.zid, -- 自己区id
                                        -- add1 = addScore, -- 本次增加的分数
                                    -- }
                                    -- skyladderserver.saveRankData(base.cubid,'alliance',battleType,ainfo.zid,ainfo.aid,ainfo.nickname,addScore,ainfo.fc,ainfo.pic,params)
                                    
                                    local memberList = skyladderserver.getAllianceMemberList(base.cubid,2,ainfo.zid,ainfo.aid) or {}

                                    if memberList and type(memberList) == 'table' then
                                        for uid,uinfo in pairs(memberList) do
                                            local params = {
                                                s = 2, -- 类型1 类型2
                                                r = battleType,
                                                t = ts, --时间戳
                                                id1 = uid, -- 自己id
                                                n1 = uinfo.n, -- 自己名字
                                                z1 = uinfo.z, -- 自己区id
                                                pic1 = uinfo.p, -- 自己pic
                                                r1 = ainfo.ranking,
                                                add1 = addScore,
                                            }

                                            skyladderserver.saveRankData(base.cubid,'person',battleType,uinfo.z,uid,uinfo.n,addScore,nil,uinfo.p,params)
                                            table.insert(rUserList,{base.cubid,'person',battleType,uinfo.z,uid,uinfo.n,addScore,nil,uinfo.p,params})
                                        end
                                    end
                                else
                                    writeLog('\n |' .. json.encode({bid=v.bid,aid=ainfo.aid,rank=ainfo.ranking}) .. '\n','skyladder_cron')
                                end
                            end
                        end
                        skyladderserver.setUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    end
                end
                if save then
                    skyladderserver.commit()
                end
            end
        elseif battleType == 3 then
            local db = getCrossDbo("worldwarserver")
            local sevbattleCfg = getConfig("worldWarCfg")
            local hour = sevbattleCfg.tmatch2starttime1[1] * 3600 + sevbattleCfg.tmatch2starttime1[2] * 60 + sevbattleCfg.battleTime * 3
            local allBids = db:getAllRows("select bid from worldwar_bid where et - 86400*4 + "..hour.." <= :ts and et - 86400*3 > :ts group by bid",{weeTs=weeTs,nextWeeTs=nextWeeTs,ts=ts})
            --local allBids = db:getAllRows("select bid from worldwar_bid where bid in ('b2773','b2774') group by bid")
            local save = false
            print('bid')
            ptb:p(allBids)
            if allBids and type(allBids) == 'table' then
                for i,v in pairs(allBids) do
                    local have = skyladderserver.getUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    if not have then
                        local rankLimit1 = getSelectNum(battleType,cfg,1)
                        local allUser = db:getAllRows("select * from worldwar_elite where bid = :bid and ranking > 0 ORDER BY ranking LIMIT :rankLimit",{bid=v.bid,rankLimit=rankLimit1})
                        if allUser and type(allUser) == 'table' then
                            for _,uinfo in pairs(allUser) do
                                local addScore = getAddScore(battleType,uinfo.ranking,cfg,1)

                                if addScore > 0 then
                                    save = true
                                    -- local params = {
                                        -- s = 2, -- 类型1 类型2
                                        -- t = ts, --时间戳
                                        -- id1 = uinfo.uid, -- 自己id
                                        -- n1 = uinfo.nickname, -- 自己名字
                                        -- z1 = uinfo.zid, -- 自己区id
                                        -- pic1 = uinfo.pic, -- 自己pic
                                        -- add1 = addScore, -- 本次增加的分数
                                    -- }
                                    -- skyladderserver.saveRankData(base.cubid,'person',battleType,uinfo.zid,uinfo.uid,uinfo.nickname,addScore,uinfo.fc,uinfo.pic,params)
                                    
                                    if uinfo.aid and tonumber(uinfo.aid) > 0 then
                                        local params = {
                                            s = 2, -- 类型1 类型2
                                            r = battleType,
                                            t = ts, --时间戳
                                            id1 = uinfo.aid, -- 自己id
                                            n1 = uinfo.nickname, -- 自己名字
                                            z1 = uinfo.zid, -- 自己区id
                                            add1 = addScore, -- 本次增加的分数
                                            r1 = uinfo.ranking -- 排行
                                        }
                                        skyladderserver.saveRankData(base.cubid,'alliance',battleType,uinfo.zid,uinfo.aid,uinfo.aname,addScore,nil,nil,params)
                                        table.insert(rUserList,{base.cubid,'alliance',battleType,uinfo.zid,uinfo.aid,uinfo.aname,addScore,nil,nil,params})
                                    end
                                else
                                    writeLog('\n |' .. json.encode({bid=v.bid,uid=uinfo.uid,rank=uinfo.ranking}) .. '\n','skyladder_cron')
                                end
                            end
                        end
                        
                        local rankLimit2 = getSelectNum(battleType,cfg,2)

                        local allUser = db:getAllRows("select * from worldwar_master where bid = :bid and ranking > 0 ORDER BY ranking LIMIT :rankLimit",{bid=v.bid,rankLimit=rankLimit2})
                        if allUser and type(allUser) == 'table' then
                            for _,uinfo in pairs(allUser) do
                                local addScore = getAddScore(battleType,uinfo.ranking,cfg,2)

                                if addScore > 0 then
                                    save = true
                                    -- local params = {
                                        -- s = 2, -- 类型1 类型2
                                        -- t = ts, --时间戳
                                        -- id1 = uinfo.uid, -- 自己id
                                        -- n1 = uinfo.nickname, -- 自己名字
                                        -- z1 = uinfo.zid, -- 自己区id
                                        -- pic1 = uinfo.pic, -- 自己pic
                                        -- add1 = addScore, -- 本次增加的分数
                                    -- }
                                    -- skyladderserver.saveRankData(base.cubid,'person',battleType,uinfo.zid,uinfo.uid,uinfo.nickname,addScore,uinfo.fc,uinfo.pic,params)
                                    
                                    if uinfo.aid and tonumber(uinfo.aid) > 0 then
                                        local params = {
                                            s = 2, -- 类型1 类型2
                                            r = battleType,
                                            t = ts, --时间戳
                                            id1 = uinfo.aid, -- 自己id
                                            n1 = uinfo.nickname, -- 自己名字
                                            z1 = uinfo.zid, -- 自己区id
                                            add1 = addScore, -- 本次增加的分数
                                            r1 = uinfo.ranking -- 排行
                                        }
                                        skyladderserver.saveRankData(base.cubid,'alliance',battleType,uinfo.zid,uinfo.aid,uinfo.aname,addScore,nil,nil,params)
                                        table.insert(rUserList,{base.cubid,'alliance',battleType,uinfo.zid,uinfo.aid,uinfo.aname,addScore,nil,nil,params})
                                    end
                                else
                                    writeLog('\n |' .. json.encode({bid=v.bid,uid=uinfo.uid,rank=uinfo.ranking}) .. '\n','skyladder_cron')
                                end
                            end
                        end
                        skyladderserver.setUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    end
                end
                if save then
                    skyladderserver.commit()
                end
            end
        elseif battleType == 5 then
            local db = getCrossDbo("areacrossserver")
            local sevbattleCfg = getConfig("serverWarLocalCfg")
            local hour = sevbattleCfg.startWarTime.a[1] * 3600 + sevbattleCfg.startWarTime.a[2] * 60 +sevbattleCfg.maxBattleTime * 2
            local allBids = db:getAllRows("select bid from areawar_bid where et - 86400 + "..hour.." <= :ts and et > :ts group by bid",{weeTs=weeTs,nextWeeTs=nextWeeTs,ts=ts})
            --local allBids = db:getAllRows("select bid from areawar_bid group by bid",{weeTs=weeTs,nextWeeTs=nextWeeTs})
            local save = false
            print('bid')
            ptb:p(allBids)
            if allBids and type(allBids) == 'table' then
                local rankLimit = getSelectNum(battleType,cfg)
                for i,v in pairs(allBids) do
                    local have = skyladderserver.getUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    if not have then
                        local allUser = db:getAllRows("select * from areawar_alliance where bid = :bid ORDER BY point desc,ladderpoint desc,fight desc,zid,aid LIMIT :rankLimit",{bid=v.bid,rankLimit=rankLimit})
                        if allUser and type(allUser) == 'table' then
                            local rank = 1
                            for _,ainfo in pairs(allUser) do
                            
                                local addScore = getAddScore(battleType,rank,cfg)

                                if addScore > 0 then
                                    save = true
                                    -- local params = {
                                        -- s = 2, -- 类型1 类型2
                                        -- t = ts, --时间戳
                                        -- id1 = ainfo.aid, -- 自己id
                                        -- n1 = ainfo.name, -- 自己名字
                                        -- z1 = ainfo.zid, -- 自己区id
                                        -- add1 = addScore, -- 本次增加的分数
                                    -- }
                                    -- skyladderserver.saveRankData(base.cubid,'alliance',battleType,ainfo.zid,ainfo.aid,ainfo.nickname,addScore,ainfo.fc,ainfo.pic,params)

                                    local memberList = skyladderserver.getAllianceMemberList(base.cubid,5,ainfo.zid,ainfo.aid) or {}

                                    if memberList and type(memberList) == 'table' then
                                        local addScore = getAddScore(battleType,rank,cfg)

                                        for uid,uinfo in pairs(memberList) do
                                            local params = {
                                                s = 2, -- 类型1 类型2
                                                r = battleType,
                                                t = ts, --时间戳
                                                id1 = uid, -- 自己id
                                                n1 = uinfo.n, -- 自己名字
                                                z1 = uinfo.z, -- 自己区id
                                                pic1 = uinfo.p, -- 自己pic
                                                add1 = addScore,
                                                r1 = rank
                                            }

                                            local ret = skyladderserver.saveRankData(base.cubid,'person',battleType,uinfo.z,uid,uinfo.n,addScore,nil,uinfo.p,params)
                                            table.insert(rUserList,{base.cubid,'person',battleType,uinfo.z,uid,uinfo.n,addScore,nil,uinfo.p,params})
                                        end
                                    end
                                else
                                    writeLog('\n |' .. json.encode({bid=v.bid,aid=ainfo.uid,rank=rank}) .. '\n','skyladder_cron')
                                end
                                
                                rank = rank + 1
                            end
                        end
                        skyladderserver.setUpdataStatus('account.'..battleType,base.cubid,v.bid)
                    end
                end
                if save then
                    skyladderserver.commit()
                end
            end
        end
    end
    
    response.ret = 0
    response.msg = 'Success'
    response.data.rUserList = rUserList
    return response
end