function api_user_signawardcfg(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('sign')== 0 then
      response.ret = -303
        return response
    end
    if moduleIsEnabled('signupcfg')== 0 then
      response.ret = -303
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local signCfg = getConfig("signcfg")

    local self = {}

    --init
    function self.init()
        -- body
        if type(mUserinfo.flags.sign) ~= 'table' then
            mUserinfo.flags.sign = {0,0,0,0,1}
        end
        if not mUserinfo.flags.sign[5] then
            mUserinfo.flags.sign[5] = 1
        end
    end

    --升级
    function self.levelup()
        -- body
        if not signCfg[mUserinfo.flags.sign[5] + 1] then
            return false
        end

        mUserinfo.flags.sign[5] = mUserinfo.flags.sign[5] +1
        if mUserinfo.level < signCfg[mUserinfo.flags.sign[5]].level then
            return false
        end

        return true
    end

    self.init()
    local ret = self.levelup()

    if not ret then
       return response
    end
    
    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
