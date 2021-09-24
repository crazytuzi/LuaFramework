-- 设置自己协防部队的状态  
-- 直接接受
-- 接受战力高
-- 旧方试 

function api_troop_setdefensestatus(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid   = request.uid
    local stats = request.params.stats
    if uid == nil or  stats == nil then
        response.ret = -102
        return response
    end


    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')

   
    mUserinfo.flags.sadf = stats

    if uobjs.save() then
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0
        response.msg = "success"
    else
        response.ret = -106
        response.msg = "bind failed"        
    end
    
    return response



end