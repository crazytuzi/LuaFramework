function api_user_newuseraward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local day = tonumber(request.params.day) or -1

    if uid == nil or (day < 1 or day > 7)  then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    
    if not mUserinfo.flags.newuser_7d_award or mUserinfo.flags.newuser_7d_award[day] ~= 0 then
        response.ret = -102
        return response
    end

    local regDays =  ((getWeeTs() - getWeeTs(mUserinfo.regdate)) / 86400) + 1
    if regDays < day then
        response.ret = -102
        return response
    end 
    
    local awardCfg = getConfig('newuser.awardBy7Day')    

    if not takeReward(uid,awardCfg[day]) then
        return response
    end

    mUserinfo.flags.newuser_7d_award[day] = 1
    local isDel = true
    for _,v in pairs(mUserinfo.flags.newuser_7d_award) do
        if v == 0 then 
            isDel = false
            break
        end
    end

    if isDel then
        --战地通讯活动
        activity_setopt(uid,'calls',{})
        mUserinfo.flags.newuser_7d_award = nil
    end
    
    if uobjs.save() then
        local mBag = uobjs.getModel('bag')
        local mTroops = uobjs.getModel('troops')

        response.ret = 0        
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.troops = mTroops.toArray(true)
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = uobjs.msg
    end
    
    return response
end
