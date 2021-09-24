function api_user_sync(request)
    local response = {
        data={},
    }

    local uid = request.uid
    local appid = tonumber(request.appid) or 0
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')
    local mTroop = uobjs.getModel('troops')
    local mTech = uobjs.getModel('techs')
    local mBuilding = uobjs.getModel('buildings')
    local mBag = uobjs.getModel('bag')
    local mHero= uobjs.getModel('hero')
    local mBoom = uobjs.getModel('boom')

    mProp.update()
    mProp.updateUsePropCd()
    mTroop.update()
    mTech.update()
    mBuilding.update()
    mBoom.update()
    
    -- 用户是否被禁言
    local playerconfig = getConfig("player")
    if playerconfig.blacklist then
        local mBlackList = uobjs.getModel('blacklist')
        local limitTime = mBlackList.getBlackTime()
        if limitTime then
            response.data.nst = limitTime
        end
    end

    ---------------------------------system  mail start ---------------------------------
    local ts  = getClientTs()
    local login_ts = mUserinfo.logindate
    -- 刚登录第一次同步一下邮件  过100秒以后是5分钟同步一次
    if ts-login_ts<100  or  (math.floor((ts-login_ts)/60)%5==0) then
        local info= MAIL:SysMailInFo()
        if type(mUserinfo.flags.sm)~='table' then mUserinfo.flags.sm={}  end
        local newinfo = info
        local delfalg = false
        if next(info) then
            for k,v in pairs(info) do
                --过期的邮件删除
                if (v[3]<=ts) then
                    MAIL:delSysMailInFo(v[1])
                end
                -- 不过期的插入玩家的邮件中
                if (v[2]<ts  and v[3]>ts ) then
                    local flag=table.contains(mUserinfo.flags.sm, v[1])
                    if not flag then
                        local ret=MAIL:SysMailSentUser(uid,v[1], appid, mUserinfo)
                        if(ret) then
                            table.insert(mUserinfo.flags.sm,v[1])
                            delfalg=true
                        end
                    end
                end
            end
        end

        --删除用户身上过期邮件的标识
        if not delfalg then

            local sm = mUserinfo.flags.sm
            for dk,dv in pairs(mUserinfo.flags.sm) do
                local dflag = true
                for mk,mv in pairs(info) do
                    if(dv==mv[1] and mv[3]>ts) then
                        dflag=false
                        break
                    end
                end
                if dflag then
                    sm[dk]=nil
                end
            end

            mUserinfo.flags.sm={}
            if next(sm) then
                for sk,sv in pairs(sm) do
                    table.insert(mUserinfo.flags.sm, sv)
                end
            end
        end
    end

    ---------------------------------system  mail end -----------------------------------

    ---------------------------------- gameconfig -------------------------------
    local gameconfig = getModuleIs()
    if type(gameconfig) == 'table' and gameconfig['chatlevel'] then
        response.data.config = { chatlevel = gameconfig['chatlevel'] }
    end    
    if type(gameconfig) == 'table' and gameconfig['emailLimit'] then
        response.data.config = response.data.config or {}
        response.data.config['emailLimit'] = gameconfig['emailLimit'] 
    end
    
    mUserinfo.setAuditData{action="online"}

    local mTask = uobjs.getModel('task')
    mTask.check()

    -- 领海战期间,同步地图状态列表
    if request.params.adwFlag == 1 then
        response.data.adw = {
            statusList = loadModel("lib.seawar").getAllGroundStatus()
        }
    end

    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.props = mProp.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.data.techs = mTech.toArray(true)
        response.data.buildings = mBuilding.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.hero = mHero.toArray(true)
        response.data.boom = mBoom.toArray(true)

        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end

    --3k 登入登出统计
    local clientPlat = getClientPlat()
    if clientPlat == "ship_3kwan" or clientPlat == "ship_3kwanios" or clientPlat == "ship_android" then
        updateOnline(uid)
    end    

    return response
end
