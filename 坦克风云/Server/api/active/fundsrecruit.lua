--
--资金招募
-- User: luoning
-- Date: 14-8-4
-- Time: 下午4:39
--
function api_active_fundsrecruit(request)

    local aname = 'fundsRecruit'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    --默认配置
    local defaultData = {
        lg = {0, 0, 0},
        gm = {0, 0, 0},
        gd = {0, 0, 0},
    }

    local uid = request.uid
    --领取奖励类型 login,gems,goods,updateTime
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward
    local weelTs = getWeeTs()
    local nowTime = getClientTs()


    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    if tonumber(mUserinfo.alliance) <= 0 then
        response.ret = -102
        return response
    end

    if mUseractive.info[aname].ls then
        defaultData = mUseractive.info[aname].ls
    end

    local checkLogin = function(loginTime, nowTime, weelTs, cfgTime, getRewardTime)

        if loginTime < weelTs then
            return -1981
        end

        if nowTime - loginTime < cfgTime then
            return -1981
        end

        if getRewardTime >= weelTs then
            return -401
        end
        return 0
    end

    local checkTask = function(totalOptions, getRewardTimes, cfgOptions, weelTs, refreshTime)

        if totalOptions < cfgOptions then
            return -1981
        end

        if getRewardTimes >= weelTs then
            return -401
        end

        if refreshTime < weelTs then
            return -1981
        end

        return 0
    end

    -- -1981条件不符合 -402已经领取过奖励
    local activeAllCfg =  getConfig("active." .. aname )
    local activeCfg = activeAllCfg.reward
    --登录时长
    if action == 'login' then

        local configTime = activeCfg[1][2]
        local code = checkLogin(defaultData.lg[1], nowTime, weelTs, configTime, defaultData.lg[2])
        if code < 0 then
            response.ret = code
            return response
        end
        --添加奖励
        local execRet,code = M_alliance.addacpoint{uid=uid,aid=mUserinfo.alliance,point=activeCfg[1][1]['point']  }

        if not execRet then
            response.ret = code
            return response
        end
        defaultData.lg[2] = weelTs

    --金币贡献次数
    elseif action == 'gems' then

        local GemsCfgOptions = activeCfg[3][2]
        local code = checkTask(defaultData.gm[1], defaultData.gm[2], GemsCfgOptions, weelTs, defaultData.gm[3])
        if code < 0 then
            response.ret = code
            return response
        end

        --添加奖励
        local execRet,code = M_alliance.addacpoint{uid=uid,aid=mUserinfo.alliance,point=activeCfg[3][1]['point'] }

        if not execRet then
            response.ret = code
            return response
        end
        defaultData.gm[2] = weelTs

    --其他物品贡献次数
    elseif action == 'goods' then

        local goodsCfgOptions = activeCfg[2][2]
        local code = checkTask(defaultData.gd[1], defaultData.gd[2], goodsCfgOptions, weelTs, defaultData.gd[3])
        if code < 0 then
            response.ret = code
            return response
        end
        --添加奖励
        local execRet,code = M_alliance.addacpoint{uid=uid,aid=mUserinfo.alliance,point=activeCfg[2][1]['point'] }

        if not execRet then
            response.ret = code
            return response
        end
        defaultData.gd[2] = weelTs

    --更新登录时间
    elseif action == 'updateTime' then
        if defaultData.lg[3] < weelTs then
            defaultData.lg[1] = getClientTs()
            defaultData.lg[3] = weelTs
        end
    end

    mUseractive.info[aname].ls = defaultData

    if uobjs.save()then
        processEventsAfterSave()
        response.ret = 0
        response.data = defaultData
        response.msg = 'Success'
    end

    return response
end

