function api_admin_addprop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    local props = request.params.props
    local userres=request.params.userinfo

    if uid == nil  then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mBag = uobjs.getModel('bag')  
    local mUserinfo = uobjs.getModel('userinfo') 

    local oldProps = copyTab(mBag.toArray(true))
    if type(props)=='table' then
        for k,v in pairs(props) do
            v = tonumber(v) or 0
            if v > 0 then
                local ret = mBag.add(k,v)
                if not ret then 
                    writeLog('--------------------','addprops')
                    writeLog(uid .. (v or 0 ),'addprops')
                    writeLog("\r\n",'addprops')
                end
            elseif v < 0 then
                mBag.use(k,-v)
            end
        end
    end
    if userres~=nil and type(userres)=='table' then
        mUserinfo.addResource(userres)
    end

    if uobjs.save() then 
        response.data.oldProps = oldProps
        response.data.currProps = mBag.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end