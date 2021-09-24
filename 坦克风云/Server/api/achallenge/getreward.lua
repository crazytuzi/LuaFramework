-- 领取军团关卡奖励，
-- 需要扣除相应的军功
function api_achallenge_getreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local sid = request.params.sid

    if uid == nil or sid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end

    local allianceChallengeCfg = getConfig("allianceChallengeCfg")
    local raisingConsume = allianceChallengeCfg[sid].raisingConsume

    local ret,code = M_alliance.setChallenge{uid=uid,bid=sid,reward=1,userais=raisingConsume}

    if not ret then
        response.ret = code 
        return response
    end

    local uobjs = getUserObjs(uid) 
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useractive"})   
    local mUserinfo = uobjs.getModel('userinfo')

    require "model.achallenge"
    local mChallenge = model_achallenge(uid)

    local reward = mChallenge.getChallengeRandReward(sid)
    local acReward = activity_setopt(uid,'fbReward',{sid=sid},true)
    
    if type(acReward) == 'table' and next(acReward) then
        for k,v in pairs(acReward) do
            reward [k] = (reward[k] or 0) + v
        end
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
