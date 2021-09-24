--
-- 德国玩家绑定邮箱奖励
-- User: chenyunhe
-- Date: 17-8-29
--
function api_user_bindmail(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled("bindmail") == 0 then
    	response.ret = -180
    	return response
    end

    local uid = tonumber(request.uid) or 0
    if uid == 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","props"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.flags.bmr==1 then
        response.ret = -1976
        return response
    end

    local bindmailCfg =getConfig('player.emailget')
    -- 策划说不用等级限制
    -- if bindmailCfg.level>mUserinfo.level then
    -- 	response.ret = -301
    --     return response
    -- end

    local reward =bindmailCfg.backReward.serverReward
    if not takeReward(uid, reward) then
        return response
    end

    mUserinfo.flags.bmr = 1
    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
        response.data.reward=bindmailCfg.backReward.reward
    end

    return response
end

