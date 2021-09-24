function api_admin_settech(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname)
    local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0

    if uid < 1 or type(request.params.techs) ~= 'table' then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    local mTechs = uobjs.getModel('techs')

    local techCfg = getConfig('tech')
    
    for k,v in pairs(request.params.techs) do
        v = tonumber(v) or 0

        if k and mTechs[k] and techCfg[k] and v > 0 and v <= tonumber(techCfg[k].maxLevel) then
            mTechs[k] = v
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