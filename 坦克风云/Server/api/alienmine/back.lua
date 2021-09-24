function api_alienmine_back(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local cid = request.params.cid

    if uid == nil or cid == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    cid = 'c'.. cid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')

    local ret = mTroop.fleetBack(cid,true)
    if not ret then
        response.ret = -1989
        return response
    end

    -- 岛屿被释放   
    if type(mTroop.attack[cid]) == 'table' then
        if mTroop.attack[cid].type ~= 6 then
            local mid = getAlienMineMidByPos(mTroop.attack[cid].targetid[1],mTroop.attack[cid].targetid[2])
            local mMap = require "lib.alienmap"
            mMap:changeAlienMapOwner(mid,0)

            -- 解除舰队来袭
            mTroop.clearAlarm(0,mTroop.attack[cid].targetid[1],mTroop.attack[cid].targetid[2])
        end
    end

    mTroop.updateAttack()

    processEventsBeforeSave()

    if ret and uobjs.save() then
        processEventsAfterSave()

        local mUserinfo = uobjs.getModel('userinfo')
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	
