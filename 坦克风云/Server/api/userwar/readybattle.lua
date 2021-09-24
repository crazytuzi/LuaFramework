-- 行为 准备战斗

function api_userwar_readybattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end
     
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end
    
    local cobjs = getCacheObjs(uid,1,'ready')
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
    local cost = userWarCfg.battle.cost
    local flag,code = mUserwar.cost(cost,mUserinfo)
    local event = {}
    if flag then
        local userwarlogLib = require "lib.userwarlog"
        if not boom then
            local userwarlogLib = require "lib.userwarlog"
            local sucess = userwarnew.action_readyFight(warId,lid,uid,mUserwar.status,round)
            if not sucess then
                -- 操作失败，请重试
                response.ret = -23304
                return response
            end

            event = userwarlogLib:setEvent(uid,warId,3,mUserwar.status,1,(cost.energy or 0),0,1,0,{0,lid,(cost.gems or 0),mUserwar.status},round)
            local battleType = mUserwar.status >= 1 and 2 or 1
            local rtype,stype,params = userwarnew.randEvent(warId,lid,uid,mUserwar.status,'battle'..battleType,round)
            event = userwarlogLib:setRandEvent(uid,warId,round,rtype,stype,mUserwar.status,params)
        else
            writeLog(uid..','..round..'readybattle','boomroundoper')
        end
        
        local tmpevent={}
        if next(event) then
            tmpevent.round=event.round
            tmpevent.content=event.content
        end
        response.data.event =tmpevent
        userwarnew.setLandUser(warId,lid,uid,round)
        mUserwar.setCount(warId,'b')
        userwarlogLib:Commint(round)
    end

    if cobjs.save(true) and uobjs.save() then 
        -- 异元战场选择战斗次数最多的玩家 每日捷报
        setNewsUidRankingScore(uid,"d18")
        response.ret = 0        
        response.msg = 'Success'
        response.data.userwar = mUserwar.toArray(true)
        response.data.userwar.pointlog=nil
    end

    return response
end