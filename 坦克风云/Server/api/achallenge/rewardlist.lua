-- 一键领取

function api_achallenge_rewardlist(request)
    
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local sids = request.params.sids
    local bcount =tonumber(request.params.bcount or 0)
    if uid == nil  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})    
    local mUserinfo = uobjs.getModel('userinfo')
    local bossCfg = getConfig('alliancebossCfg')
    require "model.achallenge"
    local mChallenge = model_achallenge(uid)
    if mUserinfo.alliance <=0 then
        response.ret=-102
        return response
    end
    local raisingConsume=0
    local reward={}
    local killcount=0
    if  bcount >0 then
        if mUserinfo.level < bossCfg.levelLimite then
            response.ret = -17000
            return response
        end
        killcount=mChallenge.getBossCount(mUserinfo.alliance)
        if killcount<bcount then
            response.ret=-102
            return response
        end
        raisingConsume=bossCfg.raisingConsume*bcount
        for i=1,bcount do
            for k,v in pairs (bossCfg.serverreward) do
                  reward [k] = (reward[k] or 0) + v
            end
        end
    end
    if type(sids)=='table' and next(sids) then
        local allianceChallengeCfg = getConfig("allianceChallengeCfg")
        for k,sid in pairs(sids) do
            raisingConsume =raisingConsume+allianceChallengeCfg[sid].raisingConsume
            local areward = mChallenge.getChallengeRandReward(sid)
            for ak,av in pairs (areward) do
                reward [ak] = (reward[ak] or 0) + av
            end
            local acReward = activity_setopt(uid,'fbReward',{sid=sid},true)
            
            if type(acReward) == 'table' and next(acReward) then
                for k,v in pairs(acReward) do
                    reward [k] = (reward[k] or 0) + v
                end
            end
        end
    end

    local ret,code = M_alliance.setBoss{uid=uid,bid=json.encode(sids),reward=1,userais=raisingConsume,bcount=bcount,killcount=killcount}

    if not ret then
        response.ret = code 
        return response
    end
    
    
    
    reward = mChallenge.takeReward(reward)
    if not reward then
        return response
    end
    -- 设置钢铁之心 之军团副本领取的宝箱
    activity_setopt(uid,'heartOfIron',{acrd=1})
     --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    if raisingConsume~=nil and raisingConsume >0 then
        mDailyTask.changeNewTaskNum('s302',1)
    end
    if uobjs.save() then
        response.data.reward = reward
        response.ret = 0
        response.msg = 'Success'   
    end 

    return response
    
end