--领取军团战活动奖励
function api_active_harvestdayreward(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
}

    
    local uid = request.uid
    local rank = tonumber(request.params.rank) or 0
    local join = tonumber(request.params.join) or 0
    local win = tonumber(request.params.win) or 0
    if(uid ==nil ) then
        response.ret=-102
        return response
    end


    local flag  = false;

    if  rank ==1 then
        flag=1;
    end

    if  join ==1 then
        flag=true
    end

    if win ==1 then
        flag=true
    end

    if join ==1 then
        flag=true
    end

    if not flag then
        response.ret=-102
        return response
    end

    -- 活动名称，收获日 t 是存储排行前十的次数 v 
    local aname = 'harvestDay'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active")
    local rankCount = activeCfg.harvestDay.serverreward.rankCount
    local joinCount = activeCfg.harvestDay.serverreward.joinCount
    local winCount = activeCfg.harvestDay.serverreward.winCount
   
    
    -- v 是存储参战次数
    -- t 存储排名前十的次数
    -- c 是存储胜利次数 

    if type(mUseractive.info.harvestDay.r) ~="table" then mUseractive.info.harvestDay.r={} end
    --领取排行的奖励
    local stats = {}
    local rankt = 0
    if rank==1 then 

        local rt  = (mUseractive.info.harvestDay.r.t) or 0 
        if mUseractive.info.harvestDay.t < rt+1  or rt+1 >rankCount  then
            response.ret = -1981
            return response
        end
        local execRet,code = M_alliance.addacpoint{uid=uid,aid=mUserinfo.alliance,point=activeCfg.harvestDay.serverreward.rank.point}
        if not execRet then
            response.ret = code
            return response
        end
        response.data.allince={}
        response.data.allince.point =execRet.data.point
        response.data.allince.addpoint =activeCfg.harvestDay.serverreward.rank.point
        mUseractive.info.harvestDay.r.t=rt+1
        rankt=mUseractive.info.harvestDay.r.t
        stats.point=mUserinfo.alliance
    end
    -- 领取参战奖励
    if join==1 then 
        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        local mTroops = uobjs.getModel('troops')
        local vt  = (mUseractive.info.harvestDay.r.v) or 0 
        if mUseractive.info.harvestDay.v < vt+1  or vt+1 >joinCount  then
            response.ret = -1981
            return response
        end

        local reward = activeCfg.harvestDay.serverreward.joinbattle
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        mUseractive.info.harvestDay.r.v=vt+1
        response.data.reward = formatReward(reward)
        stats.join=uid
    end


    --领取胜利的奖励
    if win==1 then
        local mAccessory = uobjs.getModel('accessory')
        local ct  = (mUseractive.info.harvestDay.r.c) or 0 
        if mUseractive.info.harvestDay.c < ct+1  or ct>=winCount  then
            response.ret = -1981
            return response
        end

        local reward = activeCfg.harvestDay.serverreward.winbattle

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        mUseractive.info.harvestDay.r.c=ct+1
        response.data.accessory={}
        response.data.accessory.props= mAccessory.props
        response.data.reward = formatReward(reward)
        stats.win=uid
    end

    if uobjs.save() then
        processEventsAfterSave()
        mUseractive.setStats('harvestDay',stats)
        if rank==1 then
            mUseractive.setActiveInFo('harvestDay',rankt,mUserinfo.alliance)
        end
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response

end