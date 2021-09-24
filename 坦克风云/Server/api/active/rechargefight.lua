-- 前线军需活动
function api_active_rechargefight(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid

    local action = tonumber(request.params.action) or 2 -- 1是获取信息，2是领取

     if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')

    -- 活动名称，战备军需
    local activeName = 'rechargeFight'

    -- 状态检测
    local status = mUseractive.getActiveStatus(activeName)
    if status ~= 1 then
        response.ret = status
        return response
    end

    if action == 1 then
        response.data.useractive = {}
        response.data.useractive[activeName] = mUseractive.info[activeName]
        response.ret = 0        
        response.msg = 'Success'

        return response
    end
    
    --print(mUseractive.info[activeName].v, mUseractive.info[activeName].c, math.floor(tonumber(mUseractive.info[activeName].c) - tonumber(mUseractive.info[activeName].v)))
    local addGems = math.floor(tonumber(mUseractive.info[activeName].c) - tonumber(mUseractive.info[activeName].v))
    local cfg = mUseractive.getActiveConfig(activeName)
    if addGems <= 0 or addGems > cfg.rechargeUppLimit then
        response.ret = -1981
        return response
    end

    if not mUserinfo.addResource({gems=addGems}) then
        response.ret = -1991
        return response
    end

    mUseractive.info[activeName].v = mUseractive.info[activeName].c

    local log = {parmas=request.params,gems=addGems}
    writeLog(log,activeName)
    
    if uobjs.save() then
        response.data.addgems = addGems
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response
end
