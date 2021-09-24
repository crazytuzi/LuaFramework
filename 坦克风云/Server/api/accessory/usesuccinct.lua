-- 使用洗练

function api_accessory_usesuccinct(request)
    local response = {
        ret=-1,
        msg='error',
        data = {accessory={}},
    }

    local uid = request.uid
    local use = tonumber(request.params.use) or 1
    if moduleIsEnabled('succinct') == 0 then
        response.ret = -9034
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    --local mProp = uobjs.getModel('props')
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo = uobjs.getModel('userinfo')
    if use~=1 then
        mAccessory.sinfo={}
    else
        
        if not next(mAccessory.sinfo)  then
            response.ret=-102
            return response
        end
        for k,v in pairs(mAccessory.sinfo) do
              for ak,av in pairs(v) do
                  local accessory = mAccessory.used[k][ak]
                  local old = {}
                  if accessory[4]~=nil then old=copyTab(accessory[4])  end
                  if accessory[1]~=av[1] or accessory[2]~=av[2] or accessory[3]~=av[3] then
                    response.ret=-102
                    return response
                  end
                  mAccessory.used[k][ak]=av
                  --  精炼

                  regKfkLogs(uid,'accessory',{
                        sub_type='succ',
                        addition={
                            old=old,
                            new=av
                        }
                    }
                    )
              end
        end
    end
    mAccessory.sinfo={}
    local oldfc = mUserinfo.fc
    processEventsBeforeSave()
    regEventBeforeSave(uid,'e1')
    if uobjs.save() then 
            processEventsAfterSave()
            response.data.report = report
            response.data.accessory.used = {}
            response.data.accessory.m_level=mAccessory.m_level
            response.data.accessory.m_exp=mAccessory.m_exp
            response.data.accessory.used = {}
            response.data.accessory.used = mAccessory.used
            response.data.oldfc =oldfc
            response.data.newfc=mUserinfo.fc
            response.ret = 0        
            response.msg = 'Success'
    end
    return response
end