-- 一键领取军团关卡奖励，
-- 需要扣除相应的军团贡献
function api_achallenge_getrewardall(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local needConsume = request.params.expend or 0
    local bcount =tonumber(request.params.bcount or 0)

    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end

    if moduleIsEnabled('achallengeall') == 0 then
        response.ret = -7000
        return response        
    end

    local uobjs = getUserObjs(uid) 
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useractive"})   
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance <=0 then
        response.ret=-102
        return response
    end
    
    local function reward_append(t1, t2)

        if not t1 then t1 = {} end

        for k, v in pairs(t2 or {}) do
            --print(k, v)
            if type(v) == 'table' and (not t1[k] or type(t1[k]) == 'table')   then
                t1[k] = t1[k] or {}
                table.append(t1[k], v)
            elseif type(v) == 'number' then
                t1[k] = (t1[k] or 0) + tonumber(v)
            elseif type(v) == 'string' then
                t1[k] = (t1[k] or "") .. tostring(v)
            end

        end

        return t1
    end

    local reward = {}

    require "model.achallenge"
    local mChallenge = model_achallenge(uid)

    local bossRaisingConsume=0
    local bossKillcount=0
    if  bcount >0 then
        local bossCfg = getConfig('alliancebossCfg')
        if mUserinfo.level < bossCfg.levelLimite then
            response.ret = -17000
            return response
        end

        bossKillcount=mChallenge.getBossCount(mUserinfo.alliance)
        if bossKillcount<bcount then
            response.ret=-102
            return response
        end
        bossRaisingConsume=bossCfg.raisingConsume*bcount
        for i=1,bcount do
            for k,v in pairs (bossCfg.serverreward) do
                reward [k] = (reward[k] or 0) + v
            end
        end
    end

    local allianceChallengeCfg = getConfig("allianceChallengeCfg")
    local raisingConsume = {}
    for k, v in pairs( allianceChallengeCfg ) do
        raisingConsume[k] = v.raisingConsume
    end

    local ret,code = M_alliance.setChallenge{
        uid=uid, 
        rewardall=1,
        useraisall=json.encode(raisingConsume), 
        needConsume=needConsume, 
        level=mUserinfo.level,
        bcount=bcount,
        killcount=bossKillcount,
        bossRaisingConsume=bossRaisingConsume,
    }

    if not ret then
        response.ret = code 
        return response
    end

    local acReward = {}
    local raisingConsumeCnt = 0

    for k, sid in pairs(ret.data.bids) do
        sid = tonumber(sid)
        local tmp_reward = mChallenge.getChallengeRandReward(sid)
        local tmp_acReward = activity_setopt(uid,'fbReward',{sid=sid},true)
        reward_append(reward, tmp_reward)
        reward_append(reward, tmp_acReward)

        if raisingConsume[sid] > 0 then
            raisingConsumeCnt = raisingConsumeCnt + 1
        end


    end

    reward = mChallenge.takeReward(reward)
    if not reward then
        return response
    end
    -- 设置钢铁之心 之军团副本领取的宝箱
    activity_setopt(uid,'heartOfIron',{acrd = #ret.data.bids})
     --日常任务
    local mDailyTask = uobjs.getModel('dailytask')
    if raisingConsumeCnt >0 then
        mDailyTask.changeNewTaskNum('s302', raisingConsumeCnt)
    end

    if uobjs.save() then
        response.data.reward = reward
        response.data.bids = ret.data.bids
        response.data.use_rais = ret.data.use_rais.level_point
        response.ret = 0
        response.msg = 'Success'
    end 

    return response
end
