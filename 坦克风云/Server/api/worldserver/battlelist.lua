-- status 1胜利，2是淘汰
function api_worldserver_battlelist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            info = {},
            schedule = {},
        },
    }

    -- 战斗标识
    local bid = request.params.bid

    -- 比赛类型,1是大师，2是精英
    local matchType = request.params.jointype

    if bid == nil or not matchType then
        response.ret = -102
        return response
    end

    local battlelist = {}

    local crossserver = require "model.worldserver"
    local cross = crossserver.new()

    local sevbattleCfg = getConfig("worldWarCfg")

    local bidInfo = cross:getBidDataById(bid,matchType)
    if not bidInfo then 
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local tround = tonumber(bidInfo.tround) or 1
    
    local maxRound = 6
    local datas = cross:getAllEliminateBattleDataByBid(bid,tround,matchType)

    local battlelist = {}
    local nextBattleList = {}   -- 下一轮的战斗列表

    if datas then     
        -- repair 如果有数据修复的操作，需要client重新推送一次数据
        -- datas,response.data.repair = cross.checkBattleData(datas,sevbattleCfg)
        if tround <= maxRound then 
            nextBattleList = cross.mkMatchList(tround,datas,sevbattleCfg.matchList) 
        end

        -- 将数据格式化成前端需要的格式
        for k,v in pairs(datas) do 
            local log = json.decode(v.log)

            -- 不同的服的aid可能一样的情况，需要拼上zid
            local uidFlag = cross.mkBattleUidKey(v.uid,v.zid)

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
                            table.insert(list[round][gpname],'')
                        else
                            list[round][gpname][2] = uidFlag
                        end

                        -- 在胜利组胜利或者在失败组不淘汰标识置为胜利
                        if status == cross.WIN then
                            list[round][gpname][3] = uidFlag
                        end

                        -- 设置每一场胜利者的标识
                        if type(logv[4]) == 'table' then
                            if not list[round][gpname][4] then list[round][gpname][4] = {"","",""} end
                            for _,winn in pairs(logv[4]) do
                                list[round][gpname][4][winn] = uidFlag
                            end
                        end

                        if logv[5] then
                           list[round][gpname][5] = logv[5]
                        end

                        if logv[6] then 
                            if not list[round][gpname][5] then list[round][gpname][5] = {} end
                            if not list[round][gpname][6] then list[round][gpname][6] = {} end
                            table.insert(list[round][gpname][6],logv[6])
                        end
                    end
                end
            end

            -- if v.npc ~= 1 then
            --     -- response.data.ainfo[uidFlag] = cross.formatAllianceDataForClient(v)
            -- end

            table.insert(response.data.info,{
                v.zid,
                v.uid,
                v.fc,
                v.nickname,
                v.level,
                v.pic,
                v.aname or '',
                v.ranking,
                v.rank,
                v.bpic,
                v.apic,
            })
        end                
    end

    if nextBattleList then
        local tmpNextList = {}
        for k,v in pairs(nextBattleList) do
            for m,n in pairs(v) do
                tmpNextList[k] = tmpNextList[k] or {}
                tmpNextList[k][m] = cross.mkBattleUidKey(n.uid,n.zid)
            end
        end

        table.insert(battlelist,tmpNextList)
    end
    
    response.data.landform = json.decode(bidInfo.landform)
    response.data.round = tround
    response.data.schedule = battlelist
    response.ret = 0
    response.msg = 'Success'

    -- ptb:e(response.data)
    return response
end