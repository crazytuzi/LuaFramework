--
-- 领取奖励列表
-- User: luoning
-- Date: 14-9-15
-- Time: 下午4:21
--
function api_challenge_rewardlist(request)

    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    if not uid then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","challenge"})
    local challenge = uobjs.getModel('challenge')
    local creward = type(challenge.reward) == 'table' and challenge.reward or {}

    -- ******注 response.data 不要直接用creward 或challenge.reward赋值
    -- 会导致 response.data指向challenge.reward这个table
    -- 只要response.data变化 并且执行save  就会将数据库中challenge表下 字段reward改变
    --*******
    -- 首次通关奖励
    response.data = copyTable(creward)  
    if moduleIsEnabled('chyh') == 1 and challenge.frpass==0 then
        challenge.frpass=1
        local reward={}
        if next(challenge.info) then
            for k,v in pairs(challenge.info) do
                local cid=tonumber(string.sub(k,2))
                local challengeCfg = getConfig('challenge.'..cid)
                if type(challengeCfg.extraserverreward)=='table'then
                    if challenge.frpass<cid then
                        challenge.frpass=cid
                    end
                    reward[challengeCfg.extraserverreward[1]]=(reward[challengeCfg.extraserverreward[1]] or 0)+challengeCfg.extraserverreward[2]
                end
            end
        end

        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end
            response.data.passreward={}
            response.data.passreward.show=formatReward(reward)
        
            local mAccessory = uobjs.getModel('accessory')
            response.data.passreward.accessory =mAccessory.toArray(true)
            local mArmor = uobjs.getModel('armor')
            response.data.passreward.armor =mArmor.info
        end

        if not uobjs.save() then
            response.ret=-106
        end
    end

    return response
end

