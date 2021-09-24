-- 补给 购买体力

function api_userwar_buyenergy(request)
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
        --response.ret = -4012
        --return response
    end
    
    local cobjs = getCacheObjs(uid,false,'buyenergy')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local round = userwarnew.getRound(warId)

    if not userwarnew.isEnable() then
        response.ret = -4002
        return response
    end
    
    if not mUserwar.getApply() then
        response.ret = -23307
        return response
    end

    -- if not userwarnew.ifCanOper(warId,mUserwar.mapx..'-'..mUserwar.mapy,round,uid) then
        -- response.ret = -23308
        -- return response
    -- end
    
    -- 检查是否已死亡
    if not next(mUserwar.binfo) or tonumber(mUserwar.status) >= 2 then
        response = userwarnew.ifOver(response,mUserwar)
        return response
    end

    local config = userWarCfg.support.energy
    local cost = userWarCfg.support.energy.cost
    local addEnergy = userWarCfg.support.energy.addEnergy
    local limit = userWarCfg.support.energy.limit or 0
    if tonumber(mUserwar.support1) >= limit then
        response.ret = -23305
        response.msg = 'support1 max limit'
    end
    local flag,code = mUserwar.cost(cost,mUserinfo)
    if flag then
        local energyMax = userWarCfg.energyMax or 30
        if tonumber(mUserwar.energy) >= energyMax then
            response.ret = -23309
            return response
        end
        
        mUserwar.support_energy(addEnergy)
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