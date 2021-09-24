-- 修改装甲

function api_admin_setarmor(request)
     local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid  = request.uid
    local exp  = tonumber(request.params.exp)
    local del= request.params.del 
    local add  = request.params.add
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('armor') == 0 then
        response.ret = -11000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","armor"})
    local mArmor = uobjs.getModel('armor')
    if exp~=nil then
        mArmor.exp=exp
    end

    if type(del)=="table" then
        for k,v in pairs (del) do
            if mArmor.info[v]~=nil then
                mArmor.info[v]=nil
            end
        end
    end

    if add~=nil then
   
        mArmor.addArmor({add,1})
    
    end

    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor =mArmor.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response

end
