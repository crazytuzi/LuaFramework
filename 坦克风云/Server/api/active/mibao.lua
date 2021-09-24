--
-- 秘宝探寻
-- User: luoning
-- Date: 14-8-7
-- Time: 下午2:45
--

function api_active_mibao(request)

    local aname = 'miBao'

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local defaultData = {}

    local uid = request.uid
    --领取奖励类型 login,gems,goods,updateTime
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    if mUseractive.info[aname].ls then
        defaultData = mUseractive.info[aname].ls
    end
    -- 配置文件
    local activeAllCfg =  getConfig("active." .. aname )

    if action == 'getBags' then

        response.ret = 0
        response.data = defaultData
        response.msg = 'Success'
    elseif action == 'getOldMap' then

        local checkNeed = function(defaultData, needConfig)
            for type, number in pairs(needConfig) do
                if not defaultData[type] then
                    return false
                end
                if defaultData[type] < number then
                    return false
                end
            end
            return true
        end

        local desSpice = function(defaultData, needConfig)
            for type, number in pairs(needConfig) do
                defaultData[type] = defaultData[type] - number
            end
            return defaultData
        end

        local needConfig = activeAllCfg.pc
        local rewardName = activeAllCfg.pid
        local rewardNum = 1

        local flag = checkNeed(defaultData, needConfig)
        if not flag then
            response.ret = 403
            return response
        end
        --减去需要的物品
        defaultData = desSpice(defaultData, needConfig)

        while flag do
            flag = checkNeed(defaultData, needConfig)
            if flag then
                defaultData = desSpice(defaultData, needConfig)
                rewardNum = rewardNum + 1
            end
        end

        mUseractive.info[aname].ls = defaultData

        --增加坦克
        if not takeReward(uid, {['props_' .. rewardName] = rewardNum}) then
            return response
        end

        if uobjs.save() then
            response.data = defaultData
            response.reward = rewardNum
            response.ret = 0
            response.msg = 'Success'
        end
    elseif action == "push" then
        local level = request.params.level
        if not level then
            level = 30
        end
        -- 资金招募活动
        local award = getActiveRewardFormatMail(uid,'miBao',{level=level})
        print(json.encode(award))
        uobjs.save()
    end
    return response
end
