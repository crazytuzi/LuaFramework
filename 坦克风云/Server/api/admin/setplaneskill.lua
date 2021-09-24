--管理工具加减飞机技能
function api_admin_setplaneskill(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local slist = request.params.slist 

    if uid == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "plane"})
    local mPlane= uobjs.getModel('plane')

    -- 加减飞机技能
    if type(slist) == 'table' and next(slist) then
        for k, v in pairs(slist) do
            local num =  v - (mPlane.sinfo[k] or 0)
            if num > 0 then
                mPlane.addPlaneSkill(k, num) 
            elseif num < 0 then
                mPlane.consumeSkill(k, -num)
            end
        end
    end 
    
    if uobjs.save()  then 
        response.data.plane = mPlane.toArray()
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end