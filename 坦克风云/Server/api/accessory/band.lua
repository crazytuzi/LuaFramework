--   配件绑定

function api_accessory_band(request)
     local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local t = tostring(request.params.type) or ''
    local p = tostring(request.params.ptype) or ''
    
    if uid == nil or p ==nil or t==nil then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('ab') == 0 then
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
    local aCfg=getConfig("accessory.aCfg")
    local accessoryconfig=aCfg[access[1]]
    if type(accessoryconfig.btype)~='table' then
        response.ret = -9040
        return response
    end
    local gems=getConfig("accessory.bandGems")
    if  not mUserinfo.useGem(gems) then
        response.ret = -109
        return response
    end

    if access[5]==1 then
        response.ret = -9040
        return response
    end
    if  mAccessory.checkaccessory(accessoryconfig,aCfg,access[2],access[3]) then
        response.ret =-9041
        return response
    end

    if access[4]==nil then
        access[4]={}
    end
    regActionLogs(uid,1,{action=113,item="",value=gems,params={access,p,t}})
    access[5]=1
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.accessory={}
        response.data.accessory.used = {}
        response.data.accessory.used = mAccessory.used
        response.ret = 0        
        response.msg = 'Success'                
    end    
    return response     
    
end
