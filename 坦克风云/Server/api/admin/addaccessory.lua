function api_admin_addaccessory(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local nickname = tostring(request.nickname) 
    local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0

    local add =request.params.addaccessory
    local info =request.params.info
    local used =request.params.used
    local props =request.params.props
    local fragment =request.params.fragment
    local addfrmt =request.params.addfrmt
    local delinfoaccessory =request.params.delinfoaccessory
    local delusedaccessory =request.params.delusedaccessory
    local mlevel  = tonumber(request.params.mlevel) or 0


   

    if uid < 1  then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    --ptb:p(mAccessory)

    --mAccessory.fragment={}
    local tishi = ''

    if add~=nil then 
        local ret=mAccessory.addAccessory({add,0,0})
        if not ret then
            tishi=tishi..'addaccessoryerror'
        end
    end


     if addfrmt~=nil  then 
        if type(addfrmt)=='table' and next(addfrmt) then
            for k,v in pairs(addfrmt) do
                local ret=mAccessory.addFragment(k,v)
                if not ret then
                    tishi=tishi..'addfragmenterror'
                end
            end
        end
    end

    if type(info)=='table'  and next(info)then
        for key,val in pairs(info) do
           -- ptb:p(val)
            local ret=mAccessory.updateAccessory(key,val)
        end
    end

    if type(used)=='table'  and next(used)then
        for tkey,tval in pairs(used) do

            for  tk,tv in pairs(tval) do
                --ptb:p(tv)
                local ret=mAccessory.updateUsedAccessoryLevel(tkey,tk,tv[2],tv[3],tv[4],tv[5])
            end
           -- local ret=mAccessory.updateAccessory(key,val)
        end
    end
    if type(props)=='table'  and next(props)then
        for pkey,pval in pairs(props) do
            local ret=mAccessory.setProp(pkey,tonumber(pval))
        end
    end

    if type(fragment)=='table' and next(fragment)then 

        for fkey,fval in pairs(fragment) do
            local ret=mAccessory.setFragment(fkey,fval)
        end

    end




    if type(delusedaccessory)=='table' then
        
        for delu,delv in pairs(delusedaccessory)do
            local ret=mAccessory.delUsedAccessory(delv[1],delv[2])
        end

    end 

    if type(delinfoaccessory) =='table' then

         for deli,deli in pairs(delinfoaccessory)do
            local ret=mAccessory.delAccessory(deli)
        end
    end

    if mlevel>1 then
        mAccessory.m_level=mlevel
        local succinctcfg=getConfig("succinctCfg")
        mAccessory.m_exp=succinctcfg.engineerExp[mlevel]+1
    end
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()



    --ptb:e(mAccessory)
    if uobjs.save() then 
        processEventsAfterSave()
        response.data['accessory'] = mAccessory.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
        response.tishi=tishi
    end


    return response
end