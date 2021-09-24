function api_admin_setskill(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname)
    local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0

    if uid < 1 or type(request.params) ~= 'table' then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    mSkills = uobjs.getModel('skills')

    local skillCfg = getConfig('skill.skillList')

    for k,v in pairs(request.params) do
        v = tonumber(v) or 0
        if skillCfg[k] and v > 0 and v <= tonumber(skillCfg[k].maxLevel) then
            mSkills[k] = v
        end
    end
    
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
            
    if uobjs.save() then
        processEventsAfterSave()

        response.ret = 0
        response.msg = 'Success'
    end

    return response

end