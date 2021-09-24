function api_admin_setbuilding(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname)
    local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
    if uid < 1 or type(request.params.buildings) ~= 'table' then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    local mBuildings = uobjs.getModel('buildings')
    local buildingCfg = getConfig('building')
    for k,v in pairs(request.params.buildings) do
        v = tonumber(v) or 0

        if k and mBuildings[k] and next(mBuildings[k]) and buildingCfg[mBuildings[k][1]] and v > 0 and v <= tonumber(buildingCfg[mBuildings[k][1]].maxLevel)  then
            mBuildings[k][2] = v
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