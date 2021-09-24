--
-- vip礼包购买
-- User: luoning
-- Date: 15-3-16
-- Time: 下午3:36
--
function api_user_vipgiftreward(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local num = tonumber(request.params.num) or 0

    if request.params.config then
        local rewardCfg = getConfig("vipRewardCfg")
        response.data.vipRewardCfg=rewardCfg
        response.ret = 0
        response.msg = "Success"
        return response
    end

    if uid == nil or num < 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')

    --已经购买的vip礼包
    if not mUserinfo.flags.vf then
        mUserinfo.flags.vf = {}
    end

    if table.contains(mUserinfo.flags.vf, num) then
        response.ret = -401
        return response
    end

    local rewardCfg = getConfig("vipRewardCfg")

    if not rewardCfg[num] then
        return response
    end

    local reward = rewardCfg[num].serverReward
    local gemCost = rewardCfg[num].price
    local condition = rewardCfg[num].vip
    if condition > tonumber(mUserinfo.vip) then
        response.ret = -1981
        return response
    end

    if gemCost > 0 and not mUserinfo.useGem(gemCost) then
        response.ret = -109
        return response
    end

    if not takeReward(uid, reward) then
        return response
    end

    table.insert(mUserinfo.flags.vf, num)

    regActionLogs(uid,1,{action=68,item="",value=gemCost,params={reward=reward}})

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

