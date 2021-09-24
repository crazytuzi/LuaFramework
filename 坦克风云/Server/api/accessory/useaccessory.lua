function  api_accessory_useaccessory(request)
    -- body
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    local aid = tostring(request.params.eid) or ''
    if uid == nil or aid=='' then
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
    local accessid,access=mAccessory.getAccessoryId(aid)

    if  accessid==nil then
        response.ret=-9001
        return response
    end


    local aCfg = getConfig("accessory.aCfg."..accessid)

    if  type(aCfg) ~='table' then
        response.ret=-9002
        return response
    end
    local  config = aCfg       
       local part= tonumber(config.part)
    local partUnlockLv = getConfig("accessory.partUnlockLv")
    local unLockPart = tonumber(getConfig("accessory.unLockPart"))


    if(mUserinfo.level<partUnlockLv[part])then

        response.ret=-9003
        return response
    end

    if part>unLockPart then
        response.ret=-9004
        return response
    end
    local oldfc = mUserinfo.fc
    response.data.accessory={}
    local ret =mAccessory.useAccessory(aid)
    if ret then
        local ret,eid=mAccessory.addUsed(config.tankID,access,part)
        if not ret then
            response.ret = -9042
            return response
        end
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()

        if uobjs.save() then 
            processEventsAfterSave()
            
            if eid ~=0 then 
                response.data.accessory.info={}
                local accessid,access=mAccessory.getAccessoryId(eid)
                response.data.accessory.info[eid]=access
            end
            response.data.accessory.used = {}
            response.data.accessory.used = mAccessory.used
            response.data.oldfc =oldfc
            response.data.newfc=mUserinfo.fc
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