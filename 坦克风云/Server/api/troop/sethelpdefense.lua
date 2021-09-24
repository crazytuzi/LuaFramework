function api_troop_sethelpdefense(request)
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
    local ts = getClientTs()   

    local fleetInfo = arrayGet(mTroop.helpdefense,'list>'..cronId)

    if not fleetInfo then
        response.ret = -5012 
        return response 
    end

    if fleetInfo.status == 0 and (fleetInfo.ts or 0) < ts then
        response.ret = -5014
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

    local currStatus = fleetInfo.status == 1 and 2 or 1

    local currHuobjs,currHMtroops,currCid

    if currStatus == 2 then
        if mTroop.helpdefense.c and mTroop.helpdefense.list[mTroop.helpdefense.c] then
            currCid = mTroop.helpdefense.c
            currHuobjs = getUserObjs(mTroop.helpdefense.list[currCid].uid)
            currHMtroops = currHuobjs.getModel('troops')
            currHMtroops.setTroopsStatus(currCid,4)
        end

        -- 驻防状态
        hMtroops.setTroopsStatus(cronId,5)
        mTroop.setHDefenceStatus(cronId,currStatus)        
    else
        -- 驻防状态
        hMtroops.setTroopsStatus(cronId,4)
        mTroop.setHDefenceStatus(cronId,currStatus)   
    end
    
    local mTask = uobjs.getModel('task')
    mTask.check()    
    

    processEventsBeforeSave()

    if uobjs.save() then

        if currHuobjs then
            currHMtroops.sendAttackTroopsMsgByUid(currCid)
        end

        if hUobjs.save() then
            hMtroops.sendAttackTroopsMsgByUid(cronId)
        end

        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
    end
    
    return response
end	