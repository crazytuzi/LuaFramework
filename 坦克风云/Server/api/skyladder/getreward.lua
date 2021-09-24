function api_skyladder_getreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = tonumber(request.uid)
    require "model.skyladder"
    local skyladder = model_skyladder()
    local base = skyladder.getBase() -- 阶段状态
    local cfg = getConfig("skyladderCfg")
    local plat = getClientPlat()
    
    local myrank = 0
    local person = skyladder.fetchInfo('skyladderserver.getmyrank', {action=1,zid=getZoneId(),id=uid})
    local status = false
    if person then
        if person.data.myrank then
            myrank = tonumber(person.data.myrank) or 0
            if myrank > 0 then
                local rversion = cfg.personRewardMapping[plat] and cfg.personRewardMapping[plat] or cfg.personRewardMapping.default
                local rewardList = cfg.personRankReward[rversion]

                for i,v in pairs(rewardList) do
                    if myrank >= v.range[1] and myrank <= v.range[2] then
                        status = sendToRewardCenter(uid,'gm','天梯榜第2赛季','skyb160819',nil,{desc='天梯榜第2赛季结算'},v.serverreward)
                        break
                    end
                end
            end
        else
            myrank = -1
        end
    else
        myrank = -1
    end
    --print('uid',v.uid,myrank,status)
    
    response.ret = 0
    response.data.uid = uid
    response.data.myrank = myrank
    response.data.status = status
    return response
end