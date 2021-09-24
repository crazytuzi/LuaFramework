--[[
    区域战，立即复活
        
    检测：
        用户是否参加了当前的区域战
        用户复活时间是否还需要额外购买
        用户的金币是否足够
    
    消息推送：TODO
]]
function api_areawar_revive(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver = {},
        },
    }

    local uid = tonumber(request.uid)
    local aid = request.params.aid

    if aid == nil or uid == nil then
        response.ret = -102
        return response
    end

    local weets = getWeeTs()
    local ts = getClientTs()

    local mAreaWar = require "model.areawar"
    mAreaWar.construct()
    local bid = mAreaWar.getAreaWarId()

    -- 如果游戏结束，将结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then    
        response.data.areaWarserver.over = {winner=overFlag}
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 军团已被消灭
    if mAreaWar.getAllianceDieFlag(bid,aid) then
        response.ret = -4202
        return response
    end

    local userActionInfo  = mAreaWar.getUserActionInfo(bid,uid,aid)
    if not userActionInfo then
        return response
    end

    local sevbattleCfg = getConfig('areaWarCfg')
    local gemCost =  sevbattleCfg.reviveCost

    -- 参数无效
    if not gemCost or gemCost < 1 then
        response.ret = -102
        return response
    end

    local userActionInfo  = mAreaWar.getUserActionInfo(bid,uid,aid)
    if not userActionInfo then
        return response
    end

    local reviveTime = (userActionInfo.revive or 0) - ts

    -- 每秒消耗1金币
    -- TODO 这里要不要加一个redis watch 防止用户行为数据被复写
    if reviveTime > 0 then
        gemCost = gemCost + reviveTime
        userActionInfo.revive = ts
        userActionInfo.lastRevive = (userActionInfo.lastRevive or 0) + reviveTime

        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        if not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=104,item="",value=gemCost,params={bid=bid, aid=aid}})

        if uobjs.save() then
            -- 记录复活的金币日志,方便查询
            writeLog(tostring(uid)..'|'..tostring(gemCost),'areawargems')

            -- 用户行动数据需要立即保存
            local setret,setdata = mAreaWar.setUserActionInfo(bid,userActionInfo,true)
            local tmpUserAction = mAreaWar.formatUsersActionDataForClient{setdata}

            -- 挨个推送吧
            local members = mAreaWar.getAllianceMemUids(bid)
            for k,v in pairs(members) do
                local mid = tonumber(v)
                if mid then
                    regSendMsg(mid,'areawarserver.battle.push',{areaWarserver={usersActionInfo=tmpUserAction}})
                end
            end

            response.data.userinfo = mUserinfo.toArray(true)
            response.data.areaWarserver.usersActionInfo = tmpUserAction
            response.ret = 0
            response.msg = 'Success'
        end
    else
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end