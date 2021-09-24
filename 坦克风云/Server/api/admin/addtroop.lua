function api_admin_addtroop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local troops = request.params.troops

    if uid == nil or type(troops) ~= "table" then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')

    local olds = {}
    local news = {}

    for k,v in pairs(troops) do
        if not olds[k] then
            olds[k] = mTroop.troops[k] or 0
        end

        v = tonumber(v) or 0
        if v > 0 then
            mTroop.incrTanks(k,v)
        elseif v < 0 then
            mTroop.consumeTanks(k,-v)
        end

        news[k] = mTroop.troops[k] or 0
    end

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()

    if uobjs.save() then 
        processEventsAfterSave()
        response.detail = {old=olds,new=news}
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end
