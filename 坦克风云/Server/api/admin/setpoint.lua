-- 添加各种积分
function api_admin_setpoint(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    

    local uid = tonumber(request.uid)
    local data_name = request.params.data_name
    local point = tonumber(request.params.point)

    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"}) 
    

    if uid < 1 or data_name == nil then
        response.ret = -102
        return response
    end

    local model = uobjs.getModel(data_name)
    model.point=point
    if  uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end