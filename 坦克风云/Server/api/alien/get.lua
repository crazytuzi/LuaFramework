-- 获取异星科技
function api_alien_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if (uid ==nil ) then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alien') == 0 then
        response.ret = -16000
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien= uobjs.getModel('alien')
    if uobjs.save() then 
       
        response.data.alien = mAlien.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response

end
