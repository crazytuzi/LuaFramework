-- 取抽卡记录

function api_userwar_getcards(request)
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
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userwar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserwar = uobjs.getModel('userwar')
    local ts = getClientTs()
    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    local round = userwarnew.getRound(warId)

    if not userwarnew.isEnable() then
        -- response.ret = -4002
        -- return response
    end
    
    if not mUserwar.getApply() then
        response.ret = -23307
        return response
    end
    
    -- 检查是否已死亡
    if not next(mUserwar.binfo) then
        response.ret = 0
        response.msg = 'over'
        response.data.over = {count=mUserwar.bcount,round1=mUserwar.round1,round2=mUserwar.round2}
        return response
    end

    local cards = userwarnew.randActionCards(warId,uid,round)
    if not cards or not next(cards) then
        -- 随机失败
        return response
    end
    
    if uobjs.save() then 
        response.ret = 0        
        response.msg = 'Success'
        response.data.actioncards = {warId,round,cards}
    end


    return response
end