--购买世界boss buff

function api_boss_buybuff(request)
    local response = {
        ret=-1,
        msg='error',
        data = {worldboss={}},
    }
    
    local uid = request.uid
    local bid = request.params.bid
    if uid == nil or  bid==nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('boss') == 0 then
        response.ret = -15000
        return response
    end
    local bossCfg = getConfig('bossCfg')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","worldboss"})
    local mUserinfo = uobjs.getModel('userinfo')
    local weet = getWeeTs()
    local ts = getClientTs()
    local gemCost=0
    local mWorldboss = uobjs.getModel('worldboss')
    local time=bossCfg.opentime[2][1]*3600+bossCfg.opentime[2][2]*60
    if ts >= weet+time then
        response.ret=-15002
        return response
    end

    if type(bossCfg.buffSkill[bid])~='table' then
        response.ret=-15003
        return response
    end 

    if type(mWorldboss.info.b)~='table' then  mWorldboss.info.b={}  end

    local upLevel = (tonumber(mWorldboss.info.b[bid]) or 0) + 1
    if upLevel > bossCfg.buffSkill[bid].maxLv then
        response.ret = -4007
        return response
    end
    local buff =bossCfg.buffSkill[bid]

    -- 获取当前提升等级的成功率
    local success = buff.probability[upLevel]
    if not success then
        response.ret = -102
        return response
    end
    if type (buff.serverCost)~='table' or not next(buff.serverCost) then
        response.ret = -102
        return response
    end

    if buff.serverCost.gems~=nil then
        gemCost=buff.serverCost.gems
        local mDailyTask = uobjs.getModel('dailytask')
        mDailyTask.changeTaskNum(7)
            -- 活动
        activity_setopt(uid,'wheelFortune',{value=gemCost},true)
        activity_setopt(uid,'wheelFortune2',{value=gemCost},true)

    end
    if not mUserinfo.useResource(buff.serverCost) then

        response.ret =-107
        return response
    end
    setRandSeed()
    local randnum = rand(1,100)
    if randnum <= success then
        mWorldboss.info.b[bid]=upLevel
    end
    mWorldboss.buy_at=weet
    regActionLogs(uid,1,{action=61,item="",value=gemCost,params={reward=buff.serverCost}})

    if uobjs.save() then
        response.data.worldboss.info = mWorldboss.info
        response.ret = 0       
        response.msg = 'Success'
    end

    return response
end
