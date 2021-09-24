-- 返回所有异星矿场的部队
-- 因为异星矿场开放有时间限制，时间到了后，所有玩家的所有部队都要拉回去
function api_alienmine_backall(request)
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

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')

    if type(mTroop.attack) == 'table' then
        local mMap = require "lib.alienmap"

        for cid,cinfo in pairs(mTroop.attack) do
            if type(cinfo) == 'table' and cinfo.alienMine == 1 then
                local ret = mTroop.fleetBack(cid,true)
                if ret then
                    mMap:changeAlienMapOwner(cinfo.mid,0)
                end
            end
        end
    end

    mTroop.updateAttack()

    processEventsBeforeSave()
    
    if uobjs.save() then
        processEventsAfterSave()

        response.data.troops = mTroop.toArray(true)
        
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	
