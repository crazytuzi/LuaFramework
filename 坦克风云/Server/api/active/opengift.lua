-- 开服献礼活动
-- 凌晨清数据
-- 每天领取一次免费水晶
function api_active_opengift(request)
    -- 活动名称，水晶丰收
    local aname = 'openGift'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {}
        },
    }

    local uid = request.uid
    local action = request.params.action -- 1是获取配置，2是领奖

     if uid == nil then
        response.ret = -102
        return response
    end
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)    
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    if action == 1 then
        local shop = mUseractive.openGift(aname,{getshop=1})
        response.data[aname].shop = shop
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active." .. aname)
    local lastTs = mUseractive.info[aname].t or 0

    local ret 
    if weeTs > lastTs then
        local goldNum = activeCfg.baseGoldNum * mUserinfo.level
        if goldNum > 0 then
            ret = mUserinfo.addResource{gold=goldNum}
        end

        local log = {
            uid=uid,
            parmas=request.params,
            reward={gold=goldNum},
        }
        writeLog(log,aname)

    else
        response.ret = -1976
        return response
    end

    -- 统计
    -- mUseractive.setStats(aname,{reward=currentGetNum,weeTs=weeTs})

    -- 更新最后一次抽奖时间
    mUseractive.info[aname].t = weeTs
        
    processEventsBeforeSave()

    if ret and uobjs.save() then        
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
