--管理工具加装备

function api_admin_sequip(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local elist = request.params.elist 

    if uid == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "sequip"})
    local mSequip= uobjs.getModel('sequip')

    -- 加减装备
    if type(elist) == 'table' and next(elist) then
        for k, v in pairs( elist) do
            local num =  v[1] - (mSequip.sequip[k] and mSequip.sequip[k][1] or 0)
            if num > 0 then
                  mSequip.addEquip(k, num) 
            elseif num < 0 then
                mSequip.consumeEquip(k, -num)
            end
        end
    end 
    
    if uobjs.save()  then 
        response.data.sequip = mSequip.toArray()
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
end