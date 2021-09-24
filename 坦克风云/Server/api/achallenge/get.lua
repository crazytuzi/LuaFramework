-- 点击军团关卡标签时获取相应数据
-- 今日个人攻击次数
-- 今日领奖数据
-- 军团已解锁的最大关卡id
-- 军团今日击杀次数
-- 上次领奖时间 （以此为标识，当日数据会清空）
-- 上次攻击时间 （以此为标识，当日数据会清空）
function api_achallenge_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('allianceachallenge') == 0 then
        response.ret = -8041
        return response
    end

    local challengeData,code = M_alliance.getChallenge{uid=uid}

    if type(challengeData) ~= 'table' then
        response.ret = code 
        return response
    end
    challengeData.maxbid = challengeData.barrier.maxbid or 0
    challengeData.refresh_at = challengeData.barrier.refresh_at
    challengeData.barrier = nil

    response.data.achallenge = challengeData
    response.ret = 0
    response.msg = 'Success'    

    return response
end
