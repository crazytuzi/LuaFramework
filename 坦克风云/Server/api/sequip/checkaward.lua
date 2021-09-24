-- 装备进阶 advance
function api_sequip_checkaward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('sequip') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "sequip", "bag"})
    local mSequip = uobjs.getModel('sequip')

    mSequip.update()

    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        -- response.data.sequip = mSequip.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end

    return response

end