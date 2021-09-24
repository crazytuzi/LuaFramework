function api_user_feedsaward(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    local ftype = tonumber(request.params.type) or 1

    -- 如果涉及到活动，需要传上活动名称
    local activeName = request.params.activeName

     if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    
    local mUserinfo = uobjs.getModel('userinfo')
    local weeTs = getWeeTs()

    if not mUserinfo.flags.feeds_award then
        mUserinfo.flags.feeds_award = {ts=0,num=0,t1=0,ts1=0}
    else
        if mUserinfo.flags.feeds_award.ts < weeTs then
            mUserinfo.flags.feeds_award.num = 0
        end

        if (mUserinfo.flags.feeds_award.ts1 or 0) < weeTs then
            mUserinfo.flags.feeds_award.t1 = 0
        end
    end    

    if ftype == 1 then        
        if mUserinfo.flags.feeds_award.num >= 1 then return response end

        local award = {gems=10}
        if not mUserinfo.addResource(award) then        
            return response
        end

        mUserinfo.flags.feeds_award.ts = weeTs
        mUserinfo.flags.feeds_award.num = (mUserinfo.flags.feeds_award.num or 0) + 1

    elseif ftype == 2 then
        if (mUserinfo.flags.feeds_award.t1 or 0) >= 1 then return response end 

        local award = {gems=5}
        if not mUserinfo.addResource(award) then        
            return response
        end
        
        mUserinfo.flags.feeds_award.ts1 = weeTs
        mUserinfo.flags.feeds_award.t1 = (mUserinfo.flags.feeds_award.t1 or 0) + 1

    end

    if activeName then
        activity_setopt(uid,activeName,{feed=true})
    end

    local mTask = uobjs.getModel('task')
    mTask.check()

    if uobjs.save() then            
        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0    
        response.msg = 'Success'
    end
    
    return response
end	