-- 功能整合刷新
function api_funmerge_refresh(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    if moduleIsEnabled('funmerge') == 0 then
        response.ret = -180
        return response
    end
   
    if moduleIsEnabled('ec') == 0 then
        response.ret = -6004
        return response
    end
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end
    if moduleIsEnabled('armor') == 0 then
        response.ret = -11000
        return response
    end
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local uid = request.uid
    if uid <= 0 then
        response.ret = -102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena","userexpedition",'useractive',"hero","armor","accessory","echallenge","challenge","hchallenge","sequip"})    
    local mHero = uobjs.getModel('hero')
    local hchallenge = uobjs.getModel('hchallenge')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local muserarena = uobjs.getModel('userarena')
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mAccessory = uobjs.getModel('accessory')
    local mChallenge = uobjs.getModel("echallenge")
    local challenge = uobjs.getModel('challenge')
    local mBadge = uobjs.getModel('badge')
    local weeTs = getWeeTs()
    local atweeTs = getWeeTs(muserarena.attack_at)
    local ts = getClientTs()
    local oldrank = muserarena.ranking
    local fc = mUserinfo.fc
    if mUserinfo.level <50 then
        response.ret = -301
        return response
    end
    if (mChallenge.reset_at or 0) < weeTs then
        mChallenge.reset(weeTs)
    end
    if type(muserarena.info)~='table' then muserarena.info={}  end
    if muserarena.ranking ==0 then 
        muserarena.ranking=muserarena.getArenaRank()
        setArenaRanking(uid,muserarena.ranking)
    end
    local rflflag=false
    if atweeTs~=weeTs then
        local arenaCfg = getConfig('arenaCfg')
        muserarena.attack_num=arenaCfg.startChallengingTimes
        muserarena.attack_count=0
        muserarena.attack_at=ts
        muserarena.score=0
        muserarena.info.dr={} -- 每天领取奖励
        muserarena.ref_num=0
        muserarena.buy_num=0
        rflflag=true
    end
    local arenaNpcCfg = {}
    if muserarena.ranking==451 and oldrank==0 and muserarena.updated_at==0 then
        arenaNpcCfg = getConfig('arenaNpcCfg')
        local start =0
        for k,v in pairs(arenaNpcCfg) do
            start=start+1
            setArenaRanking(start,start)  
        end
    end

    local rewardtime=muserarena.getRewardTime(ts)
    
    --上一次领奖时间
    local uptime =rewardtime[1]
    if  muserarena.ranked_at < uptime then
        muserarena.ranked=muserarena.ranking
        muserarena.ranked_at =ts
    end
    --获取可以攻击的任务
    local myrank = muserarena.ranking

    local list=muserarena.getlist(myrank,rflflag)
    --远征
    local expeditionCfg=getConfig("expeditionCfg")
    if mUserExpedition.reset_at ~=weeTs then
        mUserExpedition.reset=0
        mUserExpedition.reset_at =weeTs
    end
    if mUserExpedition.info.grade==nil then
        local grade =getExpeditionGrade(fc) 
        if grade<=0 then
            grade=1
        end 
        mUserExpedition.info.grade=grade
    end

    local grade =mUserExpedition.info.grade
    if type(mUserExpedition.binfo)~='table' then mUserExpedition.binfo={}  end
    local binfo = mUserExpedition.binfo
    if not next (binfo) then 
        local ret=mUserExpedition.getInFo(grade,mUserExpedition.eid)
        if not ret  then
            return response
        end
    end
    --配件
    local mArmor = uobjs.getModel('armor')
    local armorCfg=getConfig('armorCfg')
    mArmor.reffreecount(armorCfg)
    local hchallengeCfg = getConfig('hChallengeCfg')
    local minhid = 1
    local maxhid = #hchallengeCfg.list
    --装备
    if moduleIsEnabled("sequip") == 1 then
        local mSequip = uobjs.getModel('sequip')
        local olvl = mSequip.update( true )
        mSequip.checkAttackStats()
        response.data.sequip = mSequip.toArray(true)
        response.data.sequip.info['olvl'] = olvl --后端传开放等级
    end

    -- 指挥官徽章副本数据
    if moduleIsEnabled('badge') == 1 then
       response.data.badgechallenge = mBadge.challenge
    end
    if uobjs.save() then  
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
        response.data.hero =mHero.toArray(true)
        response.data.hchallenge = hchallenge.getChallengeDataBySid(minhid,maxhid)
        response.data.challenge2 = hchallenge.getChallenge2AllData()
        response.data.challenge = challenge.getChallengeAllData()
        response.data.echallenge = {}
        response.data.echallenge.echallenge = mChallenge.toArray(true)
        response.data.echallenge.space = {mAccessory.getAandFCount()}
        response.data.accessory = mAccessory.toArray(true)
        response.data.armor =mArmor.toArray(true)
        response.data.userarena=muserarena.toArray(true)
        mUserExpedition.binfo=nil
        response.data.expedition=mUserExpedition.toArray(true)
        response.data.userarena.dr=muserarena.info.dr
        response.data.userarena.info=nil
        response.data.userarena.rewardtime=rewardtime
        response.data.userarena.attacklist=list
        response.data.weets=weeTs
        local battlelogLib=require "lib.battlelog"
        response.data.userarena.maxrows=tonumber(battlelogLib:logCount(uid))
        response.data.userarena.unread=tonumber(battlelogLib:logHasUnread(uid))
    end
    return response
end