--[[
    区域战，立即复活

    检测：
        用户是否参加了当前的区域战
        用户复活时间是否还需要额外购买
        用户的金币是否足够
    
    消息推送：TODO
]]
function api_areateamwarserver_revive(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver = {},
        },
    }

    local uid = tonumber(request.uid)
    local aid = request.params.aid
    local bid = request.params.bid
    local group = request.params.group
    local sn = request.params.sn

    if aid == nil or uid == nil or bid == nil or group == nil or sn == nil then
        response.ret = -102
        return response
    end

    local weets = getWeeTs()
    local ts = getClientTs()
    local zid = getZoneId()

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,bid)

    -- 游戏结束,结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then    
        response.data.areaWarserver.over = {
                winner=overFlag,
                battlePointInfo=mAreaWar.getWarPointInfo(bid),
            }
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local sevbattleCfg = getConfig('serverWarLocalCfg')
    local gemCost =  sevbattleCfg.reviveCost

    -- 参数无效
    if not gemCost or gemCost < 1 then
        response.ret = -102
        return response
    end

    local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
    if not userinfo then
        response.ret = -23201
        return response
    end

    -- 金币验证
    if tonumber(userinfo.gems) < gemCost then
        response.ret = -109
        return response
    end

    local userActionInfo  = mAreaWar.getUserTroopActionInfo(bid,uid,aid,zid,sn)
    if not userActionInfo then
        return response
    end

    local reviveTime = (userActionInfo.revive or 0) - ts

    -- 每秒消耗1金币
    -- TODO 这里要不要加一个redis watch 防止用户行为数据被复写
    if reviveTime > 0 then
        gemCost = gemCost + reviveTime
        userinfo.gems = userinfo.gems - gemCost

        userActionInfo.revive = ts
        userActionInfo.lastRevive = (userActionInfo.lastRevive or 0) + reviveTime

        if mAreaWar.updateUserBattleData(userinfo) then
            -- 用户行动数据需要立即保存
            local setret,setdata = mAreaWar.setUserActionInfo(bid,userActionInfo,true)
            local tmpUserAction = mAreaWar.formatUsersActionDataForClient{setdata}

            -- 挨个推送吧
            local members = mAreaWar.getAllianceMemUids(bid,nil,zid)
            local sendMessage = json.encode({
                data={areaWarserver={usersActionInfo=tmpUserAction}},
                ret=0,
                cmd='areateamwarserver.battle.push',
                ts = ts,
            })

            for k,v in pairs(members) do
                local mid = tonumber(v)
                if mid then
                    sendMsgByUid(mid,sendMessage)
                    -- regSendMsg(mid,'areateamwarserver.battle.push',{areaWarserver={usersActionInfo=tmpUserAction}})
                end
            end

            response.data.areaWarserver.userinfo = mAreaWar.formatUserDataForClient(userinfo)
            response.data.areaWarserver.usersActionInfo = tmpUserAction
            writeLog('uid='..uid..'--revive --'..gemCost,'gemsareacross'..zid)
        end
    end
    
    response.ret = 0
    response.msg = 'Success'
    return response
end