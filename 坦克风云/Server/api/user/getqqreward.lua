--
-- 获取qq空间奖励
-- User: luoning
-- Date: 15-2-5
-- Time: 上午10:51
--
function api_user_getqqreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled('qq') == 0 then
        response.ret = -9000
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

    if mUserinfo.flags.qq then
        response.ret = -401
        return response
    end

    local reward = {props_p20=6, props_p292=5, props_p17=2,props_p12=1 }
    if not takeReward(uid, reward) then
        return response
    end
    mUserinfo.flags.qq = 1

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

