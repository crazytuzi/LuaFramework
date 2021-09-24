-- 领取军团关卡奖励，
-- 需要扣除相应的军功
function api_echallenge_reset(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 开关检测
    if moduleIsEnabled('ec')== 0 then
        response.ret = -6004
        return response
    end

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","echallenge","useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mChallenge = uobjs.getModel("echallenge")
    local mUserinfo = uobjs.getModel('userinfo')
    
    local weeTs = getWeeTs()
    if (mChallenge.reset_at or 0) < weeTs then
        mChallenge.reset(weeTs)
    end

    -- 配置
    local challengeCfg = getConfig('eliteChallengeCfg')
    local maxResetNum = challengeCfg.resetNum[(mUserinfo.vip or 0)+1]
    
    if not maxResetNum then
        return response
    end

    -- 本日重置次数达到上限
    if mChallenge.resetnum >= maxResetNum then
        response.ret = -6007
        return response
    end

    local resetGems =  challengeCfg.resetGems[mChallenge.resetnum+1]
    --活动检测重置的时候减去百分比的金币
    local acname = "accessoryFight";
    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    if activStatus == 1 then
        local activeCfg = getConfig("active.accessoryFight")
        resetGems =resetGems-(resetGems*(activeCfg.serverreward.reducePrice or 0))
    end
    if not resetGems or not mUserinfo.useGem(resetGems) then
        response.ret = -109
        return response
    end    

    mChallenge.reset(weeTs,true)

     -- stats ---------------------------------------
      -- 强化次数
      regStats('accessory_daily',{item= 'echallengeResetNum',num=1})
      --强化人数
      if mChallenge.resetnum == 1 then
          regStats('accessory_daily',{item= 'echallengeResetUser',num=1})
      end
      -- stats ---------------------------------------
    -- 春节攀升
    activity_setopt(uid, 'chunjiepansheng', {action='cz'})

    regActionLogs(uid,1,{action=26,item="",value=resetGems,params={resetNum=mChallenge.resetnum}})

    if uobjs.save() then
        processEventsAfterSave()
        
        response.ret = 0
        response.msg = 'Success'   
    end 

    return response
end
