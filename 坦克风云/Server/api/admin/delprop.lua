function api_admin_delprop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local props = request.params.props

    if uid == nil or type(props) ~= "table" then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mProp = uobjs.getModel('props')    

    local slot
    for k,v in pairs(props) do
        slot = mProp.pidIsInUse(k)
        if slot then
            table.remove(mProp.info,slot)
        end
    end
    slot = nil

    if uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end