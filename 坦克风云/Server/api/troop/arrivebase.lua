-- 部队返回到达主基地
function api_troop_arrivebase(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local cid = request.params.cid

    if uid == nil or cid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "hero","props","bag","skills","buildings","dailytask","task","boom"})
    local mTroop = uobjs.getModel('troops')

    if mTroop.attack[cid] and mTroop.attack[cid].bs then
       local ts = getClientTs()
        local sec = mTroop.attack[cid].bs - ts

        -- 作一个时间兼容(误差在15之内都认为正常)
        if math.abs(sec) <= 15 then
            mTroop.attack[cid].bs = ts
            mTroop.updateAttack()
        end
    end

    processEventsBeforeSave()
        
    if uobjs.save() then
        processEventsAfterSave()
        
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end