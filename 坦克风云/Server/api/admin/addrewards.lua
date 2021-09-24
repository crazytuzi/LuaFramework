function api_admin_addrewards(request)
    local response = {
        data       				= {},
        config    		 		= {},
        ret        				= 0,
        msg        				= 'Success'
    }
    local uid      				= request.uid
    local rewards      			= tostring(request.params.rewards)
    local title      			= tostring(request.params.title)
    local content      			= tostring(request.params.content)

    if uid == nil or rewards == nil then
        response.ret = -1
        response.msg = 'params invalid'
        return response
    end

    local uobjs     			= getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo 			= uobjs.getModel('userinfo')
    local addFlag = false
    local load_model = {}

    local ts = getClientTs()
    addFlag = addGameReward(uid,8,rewards,'',title,content,ts)

    if addFlag and uobjs.save() then
        if next(load_model) then
            for k,v in pairs(load_model) do
                local tmpModel    = uobjs.getModel(k)
                response.data[k]  = tmpModel.toArray(true)
            end
        end
        response.data.userinfo  = mUserinfo.toArray(true)
        response.ret 			= 0
        response.msg 			= 'Success'
    else
        response.ret 			= -1
        response.msg 			= "save failed"
    end

    return response
end