-- 行为 探索

function api_userwar_discovery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local action = request.params.action or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('userwar') == 0 then
        -- response.ret = -4012
        -- return response
    end
    
    local cobjs = getCacheObjs(uid,false,'discovery')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local round = userwarnew.getRound(warId)
    local lid = mUserwar.mapx..'-'..mUserwar.mapy or '0-0'
    
    if lid == '0-0' then
        response.ret = -4002
        return response
    end
 
    if not userwarnew.isEnable() then
        -- response.ret = -4002
        -- return response
    end
    
    if not mUserwar.getApply() then
        response.ret = -23307
        return response
    end

    if not userwarnew.ifCanOper(warId,lid,round,uid) then
        response.ret = -23308
        return response
    end

    -- 检查是否已死亡
    if not next(mUserwar.binfo) or mUserwar.status >= 2 then
        response = userwarnew.ifOver(response,mUserwar)
        return response
    end

    local boom = userwarnew.ifBoom(warId,lid,round)
    local cost = userWarCfg['discovery'..action].cost
    local flag,code = mUserwar.cost(cost,mUserinfo)
    local event = {}
    if flag then
        local userwarlogLib = require "lib.userwarlog"
        if not boom then
            local freward
            local reward = userwarnew.action_discovery(action)

            if reward == 'point' then
                local addPointConfig = userWarCfg['discovery'..action].addPoint or {1,1}
                setRandSeed()
                local addPoint = rand(addPointConfig[1],addPointConfig[2])
                mUserwar.addPointDirect(mUserwar.status,addPoint,4,round)
                freward = {point=addPoint}
                response.data.reward = freward
            else
                freward = formatReward(reward)
                if not reward then
                    -- 不需要提示没有探索到东西，不算报错，直接返回空table即可
                elseif not takeReward(uid,reward) then
                    response.ret = -403 
                    return response
                else
                    response.data.reward = freward
                end
            end

            local die = userwarnew.checkEnergy(warId,round,uid,mUserwar.status,mUserwar.energy,mUserwar)
            
            event = userwarlogLib:setEvent(uid,warId,2,mUserwar.status,1,(cost['energy'] or 0),0,1,(action == 2 and 1 or 0),{freward,die,(cost.gems or 0),mUserwar.status},round)

            if die == 0 then
                local rtype,stype,params = userwarnew.randEvent(warId,lid,uid,mUserwar.status,'discovery'..action,round)
                event = userwarlogLib:setRandEvent(uid,warId,round,rtype,stype,mUserwar.status,params)
            end
        else
            writeLog(uid..','..round..'discovery','boomroundoper')
        end
        
        local tmpevent={}
        if next(event) then
            tmpevent.round=event.round
            tmpevent.content=event.content
        end
        response.data.event =tmpevent
        userwarnew.setLandUser(warId,lid,uid,round)
        mUserwar.setCount(warId,'d')
        userwarlogLib:Commint(round)
    else
        -- 行动条件不满足
        response.ret = -23303
        response.msg = code..' not enough'
        return response
    end
    
    if cobjs.save(true) and uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
        
        response.data.userwar = mUserwar.toArray(true)
        response.data.userwar.pointlog=nil
    end


    return response
end