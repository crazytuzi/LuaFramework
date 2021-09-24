--  领取排行榜的奖励

function api_military_getreward(request)
    -- body
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uid = request.uid
   
    if uid <= 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    
    require "model.achallenge"
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local muserarena = uobjs.getModel('userarena')
    local ts = getClientTs()
    local rewardtime=muserarena.getRewardTime(ts)

    --检测一下排名奖励是否领取了
    if muserarena.reward_at >rewardtime[1] then
        response.ret=-10007
        return response
    end

    local arenaCfg = getConfig('arenaCfg')

    local reward   ={} 

    local itemid = arenaCfg.rankRewardId

    local min    = arenaCfg.rankMinReward
    local count = min

    local rmin=arenaCfg.getrewardcount(muserarena.ranked)

    if  rmin>min then
        count=rmin
    end

    reward={[itemid]=count}
    local ret = takeReward(uid,reward)
    if not ret then
        response.ret=-403
        return response
    end

    local uptime =rewardtime[1]

    local upkey = "z"..getZoneId()..".userarena.Luck.Rank"..uptime

    local redis = getRedis()


    local myluckrank = 0



    local luckdate =redis:get(upkey)

    local luckrank=json.decode(luckdate)
    if next(luckrank) then

        for k,v  in pairs(luckrank) do
               local muid = tonumber(v[2]) 
               if muid==uid then
                    myluckrank=k
               end

        end

    end 
    
    local luckreward = nil
    if  myluckrank ~=0 then
        if myluckrank <=arenaCfg.bigRewardNum  then
            luckreward=arenaCfg.bigLuckReward

        else

            luckreward=arenaCfg.smallLuckReward
        end

        local ret = takeReward(uid,luckreward)
        if not ret then
            response.ret=-403
            return response
        end

    end
    

    muserarena.reward_at =ts
    muserarena,ranked=muserarena.ranking

    
    if uobjs.save() then   
        response.ret = 0
        response.msg = 'Success'
        if luckreward~=nil then
            response.data.luckreward=formatReward(luckreward)
        end
        response.data.reward=formatReward(reward)
    end
    
    return response





end