-- 行为 设置陷阱

function api_userwar_settrap(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    local action = request.params.action or 1

    if uid == nil then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end
    
    local cobjs = getCacheObjs(uid,1,'settrap')
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
        response.ret = -4002
        return response
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
    if not next(mUserwar.binfo) or tonumber(mUserwar.status) >= 2 then
        response = userwarnew.ifOver(response,mUserwar)
        return response
    end
   
    local boom = userwarnew.ifBoom(warId,lid,round)
    local cost = userWarCfg['trap'..action].cost
    local flag,code = mUserwar.cost(cost,mUserinfo)
    local event = {}
    if flag then
        local userwarlogLib = require "lib.userwarlog"
        if not boom then
            userwarnew.action_setTrap(warId,lid,round,uid,mUserwar.name,mUserwar.status)
            
            local die = userwarnew.checkEnergy(warId,round,uid,mUserwar.status,mUserwar.energy,mUserwar)
            
            if action == 2 then
                event = userwarlogLib:setEvent(uid,warId,6,mUserwar.status,1,(cost['energy'] or 0),0,1,0,{lid,die,(cost.gems or 0)},round)
            else
                event = userwarlogLib:setEvent(uid,warId,4,mUserwar.status,1,(cost['energy'] or 0),0,1,0,{die,(cost.gems or 0)},round)
            end

            if die == 0 then
                local rtype,stype,params = userwarnew.randEvent(warId,lid,uid,mUserwar.status,'settrap'..action,round)
                event = userwarlogLib:setRandEvent(uid,warId,round,rtype,stype,mUserwar.status,params)
            end
        else
            writeLog(uid..','..round..'settrap','boomroundoper')
        end
        local tmpevent={}
        if next(event) then
            tmpevent.round=event.round
            tmpevent.content=event.content
        end
        response.data.event =tmpevent
        userwarnew.setLandUser(warId,lid,uid,round)
        mUserwar.setCount(warId,'t'..action)
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