function api_user_nextdayreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    if uid == nil  then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getWeeTs()
    local regdate =getWeeTs(mUserinfo.regdate)
    if ts ==regdate then
        response.ret = -102
        return response
    end
  
    local flags = mUserinfo.flags
    if flags.nextday==1 then
        response.ret = -102
        return response
    end

    local nextdayfightreward = getConfig('player.nextdayfightreward')
    if type(nextdayfightreward)=='table' then

        if not takeReward(uid,nextdayfightreward) then
            return response
        end
        local oldfc = mUserinfo.fc
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        mUserinfo.flags.nextday=1
        if uobjs.save() then
            processEventsAfterSave()
            local mTroops = uobjs.getModel('troops')
            response.ret = 0        
            response.data.userinfo = mUserinfo.toArray(true)
            response.data.troops = mTroops.toArray(true)
            response.msg = 'Success'
            response.data.oldfc =oldfc
            response.data.newfc=mUserinfo.fc
        else
            response.ret = -1
            response.msg = uobjs.msg
         end
    end

    return response

end
