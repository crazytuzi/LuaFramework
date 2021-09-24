-- 精英军团关卡列表
-- 只有一个板子，一次性显示全部
function api_echallenge_list(request)
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

    -- 开关检测
    if moduleIsEnabled('ec') == 0 then
        response.ret = -6004
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load{"echallenge","accessory"}
    local mChallenge = uobjs.getModel("echallenge")
    local mAccessory = uobjs.getModel("accessory")

    local weeTs = getWeeTs()
    if (mChallenge.reset_at or 0) < weeTs then
        mChallenge.reset(weeTs)
    end

    response.data.echallenge = mChallenge.toArray(true)
    response.data.space = {mAccessory.getAandFCount()}
    response.ret = 0
    response.msg = 'Success'    

    return response
end
