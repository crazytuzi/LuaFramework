-- 道具兑换

function api_accessory_change(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    

    local uid   = tonumber(request.uid)
    local count = request.params.count or 1
    if moduleIsEnabled('ec') == 0 then
        response.ret = -9000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')


    if uid ==nil  or count<=0 then
        response.ret=-102
        return response
    end

    local change=copyTab(getConfig("accessory.change"))

    if count>1 then
        for k,v in pairs (change.use) do
            change.use[k]=v*count
        end
        for k,v in pairs (change.get) do
            change.get[k]=v*count
        end
    end
    if not mAccessory.useProps(change.use)  then
        response.ret=-1996
        return response
    end

    if not mAccessory.addProps(change.get)  then
        response.ret = -403
        return response
    end

    if uobjs.save() then
            response.data.accessory={}
            response.data.accessory.props =mAccessory.props
            response.ret = 0        
            response.msg = 'Success'
    end

    return response
end