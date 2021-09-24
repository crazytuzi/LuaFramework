function api_skyladderserver_getpvplist(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local battleList = {}

    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local skyladderCfg = getConfig("skyladderCfg")
    local base = skyladderserver.getStatus()
    local db = getCrossDbo()
    db.conn:setautocommit(false)


    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    local result = db:getAllRows("SELECT bid,st,et FROM tank_kuafu.alliance WHERE st >=1458835200 and bid='b25831' GROUP BY bid")
    local sevbattleCfg = getConfig("serverWarTeamCfg")
ptb:p(result)
    for i,v in pairs(result) do
        if v.bid then
            print('bid',v.bid,v.st,v.et)
            local result = getDataAlliance(v.bid)
            if type(result) == 'table' and result.data and type(result.data) == 'table' then
                local userinfo = result.data.ainfo or {}
                local battleList = result.data.schedule or {}

                for round,rdata in pairs(battleList) do
                    print('round',round)
                    for sgroup,sgdata in pairs(rdata) do
                        local ts = getBattleTime(round,sgroup,v.st)
                        local uKey1 = sgdata[1] or 0
                        local uKey2 = sgdata[2] or 0
                        local winner = sgdata[3] and userinfo[sgdata[3]].aid or nil
                        local winnerzid = sgdata[3] and userinfo[sgdata[3]].zid or nil
                        local losser
                        local losserzid
                        if uKey1 == sgdata[3] then
                            if uKey2 and userinfo[uKey2] and type(userinfo[uKey2]) == 'table' then
                                losser = userinfo[uKey2].aid or 0
                                losserzid = userinfo[uKey2].zid or 0
                            else
                                losser = 0
                                losserzid = 0
                            end
                        else
                            if uKey1 and userinfo[uKey1] and type(userinfo[uKey1]) == 'table' then
                                losser = userinfo[uKey1].aid or 0
                                losserzid = userinfo[uKey1].zid or 0
                            else
                                losser = 0
                                losserzid = 0
                            end
                        end

                        print('winner',winner,'winnerzid',winnerzid)
                        print('losser',losser,'losserzid',losserzid)
                        

                        local params = {
                            s = 1,
                            r = 2,
                            t = ts,
                        }
                        params.win = winner
                        params.winzid = winnerzid
                        if uKey1 and userinfo[uKey1] and type(userinfo[uKey1]) == 'table' then
                            params.id1 = userinfo[uKey1].aid
                            params.n1 = userinfo[uKey1].name
                            params.z1 = userinfo[uKey1].zid
                            params.fc1 = userinfo[uKey1].fight
                        else
                            params.id1 = 0
                            params.n1 = ''
                            params.z1 = 0
                            params.fc1 = 0
                        end
                        
                        params.loss = losser
                        params.losszid = losserzid
                        if uKey2 and userinfo[uKey2] and type(userinfo[uKey2]) == 'table' then
                            params.id2 = userinfo[uKey2].aid
                            params.n2 = userinfo[uKey2].name
                            params.z2 = userinfo[uKey2].zid
                            params.fc2 = userinfo[uKey2].fight
                        else
                            params.id2 = 0
                            params.n2 = ''
                            params.z2 = 0
                            params.fc2 = 0
                        end
                        print('params')
                        ptb:p(params)
                    end
                end
            end
        end
    end
    db.conn:commit()
    print('fin')
    

    return response
end
