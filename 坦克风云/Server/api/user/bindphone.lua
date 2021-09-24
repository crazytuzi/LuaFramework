--
-- 绑定手机奖励
-- User: chenyunhe
-- Date: 17-12-18
--
function api_user_bindphone(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled("bindphone") == 0 then
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

    local phoneget =getConfig('player.phoneget')
    if phoneget.level>mUserinfo.level then
    	response.ret = -301
        return response
    end

    if mUserinfo.flags.phone then
        response.ret = -1976
        return response
    end


    local reward =phoneget.backReward.serverReward
    if not takeReward(uid, reward) then
        return response
    end

    mUserinfo.flags.phone = 1
    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
        response.data.reward=phoneget.backReward.reward
    end

    return response
end

