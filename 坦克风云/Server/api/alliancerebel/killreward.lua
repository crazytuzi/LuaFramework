--  击杀奖励

function api_alliancerebel_killreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            userarena={},
        },
    }

    -- 军团叛军没有开启
    if moduleIsEnabled('acerebel')  == 0 then
        response.ret = -17000
        return response
    end
    local members =request.params.members
    local reward  =request.params.reward
    local lvl     =request.params.lvl
    local overdue =tonumber(request.params.overdue)
    local count   =request.params.count
    local ts      =tonumber(request.params.ts)
    local redis = getRedis()
    local rebelCfg=getConfig('rebelCfg')
    if type(members)=='table' and next(members) then
        local title=50
        for k,v in pairs (members) do
            if tonumber(v.join_at)<=ts then
                local key = "z"..getZoneId()..".killrebelforces."..v.uid..'weets'..getWeeTs()
                local count=redis:incr(key)
                redis:expire(key,24*3600)
                local add=reward
                if count>rebelCfg.rewardLimit then
                    add=rebelCfg.overReward
                end
                sendToRewardCenter(v.uid,'rf',title,ts,overdue,{type=50,lvl=lvl,count=count},add)
            end
        end
    end
    response.ret = 0
    response.msg = 'Success'
    return response
end