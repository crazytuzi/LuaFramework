-- 一元战场商店购买


function api_userwar_buy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local tId = request.params.tId
    if uid == nil  or tId==nil   then
        response.ret = -102
        return response
    end
    
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end

    local cobjs = getCacheObjs(uid,false,'battle')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops"})
    local mHero     = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 
    local sCfg = getConfig('userWarCfg.ShopItems')
    local userwarnew = require "model.userwarnew"
    local shopItem = sCfg[tId]
    local limitNum = shopItem.buynum
    local reward = shopItem.serverReward
    local cost = shopItem.price

    --验证积分是否够用
    local ret,errorCode=mUserwar.usePoint(cost, tId, limitNum, type, 50) 
    if not ret then
        response.ret = errorCode
        return response
    end
    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end
    
    if cobjs.save(true) and uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response


end