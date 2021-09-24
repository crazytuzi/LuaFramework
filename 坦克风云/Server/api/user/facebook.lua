--
-- facebook用户登录获取一次奖励
--
-- User: luoning
-- Date: 14-7-21
-- Time: 下午1:43
--

function api_user_facebook(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    --用户id
    local uid = request.uid
    --奖励类型
    local action = request.params.action
    --category 1-7
    local category = request.params.category
    --默认数据
    local facebook = {
        us = 0,
        nt = { 0, 0, 0, 0, 0, 0, 0},
        dy = 0,
    }
    local defaultFacebook = facebook
    --faceId
    local facebookId = request.params.facebookid

    local getFacebookUserinfo = function(facebookId, defaultConfig)
        local db = getDbo()
        local result = db:getRow("select facebookid,rewardinfo from facebookuserinfo where facebookid = :id",{id=facebookId})
        if not result then
            return defaultConfig, result
        end
        return json.decode(result['rewardinfo']), result
    end

    local updateFacebookUserinfo = function(facebookId, info, updateFlag)
        local db = getDbo()
        if not updateFlag then
            db:insert("facebookuserinfo", {facebookid = facebookId, rewardinfo = json.encode(info), updated_at = os.time()})
        else
            db:update("facebookuserinfo", {rewardinfo = json.encode(info), updated_at = os.time()}, "facebookid = '" ..facebookId.. "'")
        end
    end

    --getFacebookUserconfig
    if action == 'facebookUserinfo' then
        local facebookResult = getFacebookUserinfo(facebookId, defaultFacebook)
        response.data = facebookResult
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --是否可以领取奖励
    local rewardFlag = false
    --奖励类型
    local rewardCfg = {}

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    -- 需要验证fbid
    if (action == "facebookUserinfo" or action == "invitation") and facebookId == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.flags.fb and type(mUserinfo.flags.fb) == 'table' then
        facebook = mUserinfo.flags.fb
    end

    --检查facebook用户领取
    local checkUser = function(userFlag)

        if userFlag == 1 then
            return false
        end
        return true
    end

    --检查邀请好友
    local checkInvitation = function(inviteFlag, category)

        if category < 1 or category > 7 then
            return false
        end
        if inviteFlag[category] == 0 then
            return true
        end

        return false
    end

    --每日首次邀请
    local checkDailyInvitation = function(oldTime, dailyTime)
        if oldTime >= dailyTime then
            return false
        end
        return true
    end

    local weeTs = getWeeTs()
    if action == 'user' then

        rewardFlag = checkUser(facebook.us)
        local rewardTmpCfg = getConfig('facebook.loginReward')
        rewardCfg = rewardTmpCfg.serverreward
    elseif action == 'invitation' then

        if category == nil then category = 1 end
        rewardFlag = checkInvitation(facebook.nt, category)
        if rewardFlag then
            local tmpConfig = getConfig('facebook.totalReward')
            rewardCfg = tmpConfig[category]['serverreward']
        end
    elseif action == 'dailyFirst' then

        --if facebook.dy == 0 then facebook.dy = os.time() end
        rewardFlag = checkDailyInvitation(facebook.dy, weeTs)
        local rewardTmpCfg = getConfig('facebook.inviteReward')
        rewardCfg = rewardTmpCfg.serverreward
    end

    --是否可领取
    if not rewardFlag then
        response.ret = -1976
        return response
    end

    --验证facebook账号
    local facebookResult, updateFlag = getFacebookUserinfo(facebookId, defaultFacebook)
    if action == 'user' then
        rewardFlag = facebookResult.us
    elseif action == 'invitation' then
        rewardFlag = facebookResult.nt[category]
    end

    --是否可领取
    if rewardFlag == 1 then
        response.ret = -1976
        return response
    end

    if action == 'user' then
        facebookResult.us = 1
        updateFacebookUserinfo(facebookId, facebookResult, updateFlag)
    elseif action == 'invitation' then
        facebookResult.nt[category] = 1
        updateFacebookUserinfo(facebookId, facebookResult, updateFlag)
    end

    --增加
    if not takeReward(uid, rewardCfg) then
        return response
    end

    if action == 'user' then
        facebook.us = 1
    elseif action == 'invitation' then
        facebook.nt[category] = 1
    elseif action == 'dailyFirst' then
        facebook.dy = weeTs
    end

    mUserinfo.flags.fb = facebook

    local mTask = uobjs.getModel('task')
    mTask.check()

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
