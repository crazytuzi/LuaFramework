function api_troop_gethelpdefense(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local cronId = request.params.cronid

    if uid == nil or cronId == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')    
    
    local fleetInfo = arrayGet(mTroop.helpdefense,'list>'..cronId)

    if not fleetInfo then
        response.ret = -5012 
        return response 
    end

    local hUobjs = getUserObjs(fleetInfo.uid)
    hUobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local hMtroops = hUobjs.getModel('troops') 

    local hFleetInfo = hMtroops.getFleetByCron(cronId)
    if not hFleetInfo then
        mTroop.clearHelpDefence(cronId)
        if uobjs.save() then
            mTroop.sendHelpDefenseMsgByUid()        
        end

        response.ret = -5012
        return response 
    end
    
    local mTask = uobjs.getModel('task')
    mTask.check()    

    processEventsBeforeSave()

    if uobjs.save() then

        response.data.helpDefenseInfo = hFleetInfo

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    
    end
    
    return response
end	