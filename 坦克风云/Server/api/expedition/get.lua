-- 获取远征信息

function api_expedition_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid

    if uid ==nil then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo = uobjs.getModel('userinfo')
    local fc = mUserinfo.fc

    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end


    local expeditionCfg=getConfig("expeditionCfg")
    if mUserinfo.level <expeditionCfg.openLevel then
        response.ret = -13001
        return response
    end
    local weets      = getWeeTs()
    if mUserExpedition.reset_at ~=weets then
        mUserExpedition.reset=0
        mUserExpedition.reset_at =weets
    end
    if mUserExpedition.info.grade==nil then
        local grade =getExpeditionGrade(fc) 
        if grade<=0 then
            grade=1
        end 
        mUserExpedition.info.grade=grade
    end
    local grade =mUserExpedition.info.grade
    if type(mUserExpedition.binfo)~='table' then mUserExpedition.binfo={}  end
    local binfo = mUserExpedition.binfo
    if not next (binfo) then 
        local ret=mUserExpedition.getInFo(grade,mUserExpedition.eid)
        if not ret  then
            return response
        end
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
        mUserExpedition.binfo=nil
        response.data.expedition=mUserExpedition.toArray(true) 
    end 

    return response
end
