-- 贸易返航
function api_alienweapon_back(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.params.uid
    local slot = request.params.slot -- 任务索引
    if uid == nil or slot == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "alienweapon"})
    local mAweapon = uobjs.getModel('alienweapon')
    local mUserinfo = uobjs.getModel('userinfo')

    local ts = getClientTs()
    if not mAweapon.checkTaskOver(slot) then
        response.ret = -405
        return response
    end

    -- 更新标记
    mAweapon.updateRobInfo(slot, true)
 

    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end
    
    return response
end	