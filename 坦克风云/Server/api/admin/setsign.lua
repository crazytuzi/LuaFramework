--设置签到
function api_admin_setsign(request)
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

   local sign =  request.params.sign
    if moduleIsEnabled('sign') == 0 then
      response.ret = -303
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    -- 连续签道的天数, 
    -- 最后一天签到的时间,
    -- 当前领到的奖励（0-3档）
    -- 全部签到累积的天数
    -- 当前配置(1-3档)
    if type(mUserinfo.flags.sign) ~= 'table' then
        mUserinfo.flags.sign = {0,0,0,0,1}
    end
    --{}
    mUserinfo.flags.sign = sign

    if uobjs.save() then        
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
