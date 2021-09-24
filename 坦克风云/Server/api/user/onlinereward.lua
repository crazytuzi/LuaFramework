function api_user_onlinereward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    
    local uid = request.uid
    local cd  = tonumber(request.params.cd) or 60
    if uid == nil  then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')

  
    local flags = mUserinfo.flags
    --领取标记修改为2，让老玩家能领取
    if type(flags.ol)~='table'  and flags.ol==2 then
        response.ret = -1976
        return response
    end
    if type(mUserinfo.flags.ol) ~='table' then mUserinfo.flags.ol={}  end

    

    ts = getClientTs()

    local num = (mUserinfo.flags.ol[1] or 0) + 1
    local r_at = (mUserinfo.flags.ol[2] ) or 0
    local onlinepackageCD = getConfig('player.onlinepackageCD')
    cd = onlinepackageCD[num] or cd
    if (ts-r_at) < cd then
        response.ret = -102
        return response
    end
    local reward = {}
    local onlinepackage = getConfig('player.onlinepackage')
    reward=onlinepackage[num]
    if type (reward)~='table' then
         response.ret=-1988  
        return response

    end

    local function Log(logInfo,filename)
        local log = ""
        log = log .."uid=".. (logInfo.uid or ' ') .. "|"
        log = log .. "reward="..json.encode(logInfo.reward)

        filename = filename or 'online'
        writeLog(log,filename)
    end 

    processEventsBeforeSave()
    local ret = takeReward(uid,reward)
    mUserinfo.flags.ol[1] =num
    mUserinfo.flags.ol[2]=ts
    mUserinfo.flags.ol[3] = 0
    if type (onlinepackage[num+1]) ~='table' then  

        mUserinfo.flags.ol=2
    end

    
    regEventBeforeSave(uid,'e1')
    if ret and uobjs.save() then        
        processEventsAfterSave()
        Log({uid=uid,reward=reward})
        response.ret = 0
        response.msg = 'Success'

    end

    return response
end
