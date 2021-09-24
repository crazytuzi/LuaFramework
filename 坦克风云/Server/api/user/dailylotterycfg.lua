function api_user_dailylotterycfg(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local lotteryType = request.params.type or 1

    if uid == nil  then
        response.ret = -102
        return response
    end
    if moduleIsEnabled('signupcfg')== 0 then
      response.ret = -303
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    local cfg = getConfig('lottery')
    local self = {}
    --升级
    function self.levelup( sType)
        -- body
        if not mUserinfo.flags.daily_lottery[sType].cfg then
            mUserinfo.flags.daily_lottery[sType].cfg = 1
        end

        if mUserinfo.level < cfg[sType][mUserinfo.flags.daily_lottery[sType].cfg].userlevel then
            return false
        end 

        if mUserinfo.flags.daily_lottery[sType].cfg >= #cfg[sType] then
            return false
        end

        mUserinfo.flags.daily_lottery[sType].cfg = mUserinfo.flags.daily_lottery[sType].cfg + 1

        return true
    end

    local sType = 'd' .. request.params.type
    local ret = self.levelup(sType)
    if not ret then
        return response
    end

    processEventsBeforeSave()
    if uobjs.save() then    
        processEventsAfterSave()        
            
        response.data.userinfo=mUserinfo.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end
    
    return response
end
