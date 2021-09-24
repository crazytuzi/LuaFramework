-- 获取自己军事演习信息
function api_military_get(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uid = request.uid
   
    if uid <= 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    

    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local muserarena = uobjs.getModel('userarena')
    local weeTs = getWeeTs()
    local atweeTs = getWeeTs(muserarena.attack_at)
    local ts = getClientTs()
    local oldrank = muserarena.ranking
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

    if uobjs.save() then  
        response.ret = 0
        response.msg = 'Success'
        response.data.userarena=muserarena.toArray(true)
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