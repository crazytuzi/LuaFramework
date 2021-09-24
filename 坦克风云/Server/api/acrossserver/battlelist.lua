-- status 1胜利，2是淘汰
function api_acrossserver_battlelist(request)
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

    local acrossserver = require "model.acrossserver"
    local cross = acrossserver.new()
    cross:setRedis(bid)

    local sevbattleCfg = getConfig("serverWarTeamCfg")
    local roundEvents = cross.getRoundEvents(sevbattleCfg.sevbattleAlliance)

    local datas = cross:getAllianceFromDbByBid(bid)

    local matchList2= sevbattleCfg.matchList2
    local nextBattleList
    local currRound

    if datas then
        local warSt = tonumber(datas[1].st)
        currRound = cross.getCurrentRound(warSt)
        
        datas = cross.checkBattleData(datas,sevbattleCfg)
        cross:checkRoundData(datas,currRound,matchList2,true)

        nextBattleList = cross.mkMatchList(datas,matchList2,currRound)

        -- 将数据格式化成前端需要的格式
        for k,v in pairs(datas) do
            local log = type(v.log) ~= 'table' and json.decode(v.log) or v.log

            -- 不同的服的aid可能一样的情况，需要拼上zid
            local uidFlag = cross.mkKey(v.zid,v.aid)
            
            if type(log) == 'table' then
                for _,logv in pairs(log) do
                    if next(logv) then
                        local round = tonumber(logv[1])
                        local gpname = logv[2]
                        local status = logv[3]
                        local list = battlelist

                        if not list[round] then list[round] = {} end
                        if not list[round][gpname] then list[round][gpname] = {} end

                        if not list[round][gpname][1] then
                            table.insert(list[round][gpname],uidFlag)
                            table.insert(list[round][gpname],'')
                        else
                            list[round][gpname][2] = uidFlag
                        end

                        -- 在胜利组胜利或者在失败组不淘汰标识置为胜利
                        if status == cross.WIN then
                            list[round][gpname][3] = uidFlag
                        end
                    end
                end
            end

            if v.npc ~= 1 then
                response.data.ainfo[uidFlag] = cross.formatAllianceDataForClient(v)
            end
        end
    end

    -- 如果比赛还没结束
    if #battlelist < roundEvents[2] then
        for k,v in pairs(nextBattleList) do            
            if nextBattleList[k][1] then nextBattleList[k][1] = v[1] and cross.mkKey(v[1].zid,v[1].aid) end
            if nextBattleList[k][2] then nextBattleList[k][2] = v[2] and cross.mkKey(v[2].zid,v[2].aid) end
        end

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
        for _,g in ipairs({'a','b','c','d'}) do
            if not battlelist[1][g] then battlelist[1][g] = {{},{}} end
        end
    end

    -- ptb:e(battlelist)
    response.data.schedule = battlelist
    response.ret = 0
    response.msg = 'Success'

    return response
end