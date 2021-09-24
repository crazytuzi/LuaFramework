--
-- 获取实名认证引导奖励realnameguide
-- User: chenyunhe
-- Date: 17-6-7
--
function api_user_rngreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid) or 0
    if uid == 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","props"})
    local mUserinfo = uobjs.getModel('userinfo')

    local rnRegister =getConfig('player.rnRegister')
    if rnRegister.level>mUserinfo.level then
    	response.ret = -301
        return response
    end

    if mUserinfo.flags.rng2 then
        response.ret = -1976
        return response
    end

    local reward =rnRegister.backReward.serverReward
    if not takeReward(uid, reward) then
        return response
    end

    mUserinfo.flags.rng2 = 1
    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
        response.data.reward=rnRegister.backReward.reward
    end

    return response
end

