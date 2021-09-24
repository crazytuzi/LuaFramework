-- 移除使用中的配件
function  api_accessory_removeaccessory(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid

    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    if uid == nil  then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('ec') == 0 then
        response.ret = -9000
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')

    local access=mAccessory.getUsedAccessory(t,p)
    


    if  not next(access) then
        response.ret = -9005
        return response
    end

    if access[5]==1 then
        response.ret = -9042
        return response
    end

    local aid,info = mAccessory.removeUsedAccessory(t,p)


    if  next(info) and aid~=0 then

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
    
        if uobjs.save() then 
            processEventsAfterSave()
            response.data.accessory={}
            response.data.accessory.info={}
            response.data.accessory.info[aid]=info
            response.ret = 0    
            response.msg = 'Success'
            return response
        else
            response.ret = -1
            response.msg = "save failed"
        end

    end


  
    return response

end