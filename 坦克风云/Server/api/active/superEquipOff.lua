-- 抽装折扣活动
-- 凌晨清数据
function api_active_superEquipOff(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，每日充值
    local aname = 'superEquipOff'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local lastTs = mUseractive.info[aname].t or 0

    if weeTs > lastTs then
        mUseractive.info[aname].rnum  = 0
        mUseractive.info[aname].rv    = 0
        mUseractive.info[aname].gnum  = 0
        mUseractive.info[aname].gv    = 0
    end

    -- 更新最后一次抽奖时间
    mUseractive.info[aname].t = weeTs
    local data = {[aname] = mUseractive.info[aname]}
    regSendMsg(uid,'active.change',data)

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
