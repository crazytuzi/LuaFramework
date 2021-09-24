-- 军团关卡列表
-- 兵力详情
-- 领奖详情
function api_achallenge_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local minSid = request.params.minsid or 1 
    local maxSid = request.params.maxsid or 3
    
    if uid == nil or minSid <1 or maxSid < minSid then
        response.ret = -102
        response.msg = 'params invalid'
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

    require "model.achallenge"
    local mChallenge = model_achallenge(uid)
    local challengeCfg = getConfig('allianceChallengeCfg')

    local troopsData = {}
    local sid = ''
    for i=minSid,maxSid do
        sid = 'b' .. i 
        troopsData[sid] = mChallenge.getCurrentChallengeTroops(challengeCfg[i].tank,challengeData.barrier[sid]) or {}
    end
    
    response.data.achallenge = {tank=troopsData}
    response.ret = 0
    response.msg = 'Success'    

    return response
end
