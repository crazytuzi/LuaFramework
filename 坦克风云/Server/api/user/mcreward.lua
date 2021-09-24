-- 月卡领取奖励

function api_user_mcreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid

     if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')

    local weeTs = getWeeTs()

    if type (mUserinfo.mc)~='table' then mUserinfo.mc={}  end

    --ptb:p(mUserinfo.mc)
    local mend = mUserinfo.mc[1] or 0

    local mrd = mUserinfo.mc[2] or 0
    local ts =getClientTs()
    if ts > mend then
        response.ret = -2013 
        return response
    end
    if mrd >weeTs then
        response.ret = -1976 
        return response
    end

    local player = getConfig("player")
    local addgems = 0
    addgems  =player.monthcardaddgems or 0
    local addGemRet = mUserinfo.addResource({gems=addgems})
    if not addGemRet then
        response.ret = -403
        return response
    end
    mUserinfo.mc[2]=ts
    if uobjs.save() then
        response.ret = 0        
        response.data.userinfo = mUserinfo.toArray(true)
        response.msg = 'Success'
    end
    
    return response


end