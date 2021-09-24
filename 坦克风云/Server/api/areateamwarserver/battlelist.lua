-- 获取跨服区域战的对阵列表
function api_areateamwarserver_battlelist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            ainfo = {},
            schedule = {},
        },
    }

    -- 战斗标识
    local bid = request.params.bid

    if bid == nil then
        response.ret = -102
        return response
    end

    local battlelist = {}

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct()
    mAreaWar.setRedis(bid)

    local bidData = mAreaWar.getBidDataByBid(bid)
    if type(bidData) ~= 'table' then
        -- 加锁判断
        if not mAreaWar.lock(bid,"areateamwarserver_createbid_lock") then
            return response
        end

        local applyData = mAreaWar.getApplyDataFromDb(bid)
        if type(applyData) ~= 'table' or not applyData[1] then
            return response
        end

        bidData = {
            bid=bid,
            st=applyData[1].st,
            et=applyData[1].et,
            servers=applyData[1].servers,
            logo=applyData[1].logo,
        }

         -- 按服存放的数据
        local serverData = {}
        local servers = json.decode(applyData[1].servers) or {}
        local serversCount = table.length(servers)
        assert(serversCount > 0,"serversCount error")

        -- 临时数据,服内报名不足时,会从其它服取
        local tmpData = {}
        local allianceNum = 8

        for k,v in pairs(applyData) do
            local zid = tonumber(v.zid)
            if not serverData[zid] then
                serverData[zid] = {}
            end
            
            if #serverData[zid] < (allianceNum/serversCount) then
                table.insert(serverData[zid],v)
            else
                table.insert(tmpData,v)
            end
        end

        table.sort(servers,function (a,b) return tonumber(a) < tonumber(b) end)
        table.sort(tmpData,function (a,b) return tonumber(a.fight) > tonumber(b.fight) end)
        
        for _,zid in pairs(servers) do
            local zid = tonumber(zid)
            if not serverData[zid] then
                serverData[zid] = {}
            end

            local n = #serverData[zid]
            local m = allianceNum/serversCount

            if n < m then
                for i=m-1,n,-1 do
                    table.insert(serverData[zid],tmpData[1])
                    table.remove(tmpData,1)
                end
            end
        end

        local setDatas = {}
        for k,v in pairs(serverData) do
            if type(v) == 'table' then
                for m,n in pairs(v) do
                    table.insert(setDatas,n)
                end
            end
        end

        mAreaWar.setautocommit(false)
        mAreaWar.addAllinaceDataToDb(bid,setDatas)
        bidData.logo = nil
        mAreaWar.addBidData(bidData)
        mAreaWar.commit()

        -- 解锁
        mAreaWar.unlock(bid,"areateamwarserver_createbid_lock")

        bidData = mAreaWar.getBidDataByBid(bid)
        if type(bidData) ~= 'table' then
            response.errMsg = "bidData is nil "
            return response
        end
    end

    local round_a = tonumber(bidData.round_a) or 0
    local round_b = tonumber(bidData.round_b) or 0

    local allianceBattleInfo = mAreaWar.getAlliancesDataFromDb(bid)
    local currRound = mAreaWar.getCurrentRound(tonumber(bidData.st))
    mAreaWar.checkRoundData(bid,currRound,allianceBattleInfo,bidData)

    local nextBattleList = mAreaWar.mkMatchList(allianceBattleInfo)

    if type(allianceBattleInfo) == 'table' then
        -- 按得分排个序
         table.sort(allianceBattleInfo,function ( a,b ) 
            if tonumber(a.point) == tonumber(b.point) then
                if tonumber(a.ladderpoint) == tonumber(b.ladderpoint) then
                    return (tonumber(a.fight) or 0) > (tonumber(b.fight) or 0)
                else
                    return (tonumber(a.ladderpoint) or 0) > (tonumber(b.ladderpoint) or 0)
                end
            else
                return tonumber(a.point) > tonumber(b.point) 
            end
        end)

        -- 将数据格式化成前端需要的格式
        for k,v in pairs(allianceBattleInfo) do
            local log = type(v.log) ~= 'table' and json.decode(v.log) or v.log

            -- 不同的服的aid可能一样的情况，需要拼上zid
            local aidFlag = mAreaWar.mkKey(v.zid,v.aid)
            response.data.ainfo[aidFlag] = {
                v.name or '',
                (v.battle_at or 0),
                k or 0,
                v.fight or 0,
                v.point or 0,
                v.commander or '',
                v.logo or '[]',
            }            
            
            if type(log) == 'table' then
                for _,logv in pairs(log) do
                    if next(logv) then
                        local round = tonumber(logv[1])
                        local gpname = logv[2]
                        local list = battlelist

                        if not list[round] then list[round] = {} end
                        if not list[round][gpname] then list[round][gpname] = {} end

                        table.insert(list[round][gpname],{aidFlag,(logv[3] or 0)})
                    end
                end
            end
        end
    end

    --如果比赛还没结束(一共2场),或者最后一场的分组小于2(a,b组组数是2),需要处理对阵列表
    if #battlelist < 2 or table.length(battlelist[#battlelist]) < 2 then
        -- 格式化下一场对阵列表数据
        for k,v in pairs(nextBattleList) do   
            -- end取4是因为每个组是8/2=4个军团
            for i=1,4 do   
                if nextBattleList[k][i] then 
                    nextBattleList[k][i] = {v[i] and mAreaWar.mkKey(v[i].zid,v[i].aid)}
                end
            end
        end

        -- 当前轮的对阵列表结果没有的时候用nextBattleList
        -- 如果有了,可能只是其中一个组的数据有了,没有结果的组的对阵列表接着用nextBattleList
        if #battlelist < currRound then
            table.insert(battlelist,nextBattleList)
        else
            for k,v in pairs(nextBattleList) do
                if not battlelist[currRound][k] then
                    battlelist[currRound][k] = v
                end
            end
        end
    end

    if battlelist[1] then
        for _,g in ipairs({'a','b'}) do
            if not battlelist[1][g] then battlelist[1][g] = {{},{}} end
        end
    end

    if round_a ==1 and round_b == 1 then
        if #battlelist == 1 then
            table.insert(battlelist,nextBattleList)
        end
    end

    -- 两组都打完后,返回结束标识
    if round_a >= 2 and round_b >= 2 then
        response.data.over = 1
    end

   for k,v in pairs(battlelist) do
       if type(v) == 'table' then
           for m,n in pairs(v) do
               if n and n[1] and n[1][2] then
                   table.sort(n,function(a,b) return (tonumber(a[2]) or 0) > (tonumber(b[2]) or 0) end ) 
               end
           end
       end
   end

    response.data.schedule = battlelist

    response.ret = 0
    response.msg = 'Success'
    return response
end