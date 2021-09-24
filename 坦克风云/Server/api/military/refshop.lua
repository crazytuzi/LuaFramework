-- 远征商店的刷新

function api_military_refshop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    if uid ==nil  then
        response.ret=-102
        return response
    end


    if moduleIsEnabled('he') == 0  then
        response.ret = -10000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userarena","hero","troops"})
    local mUserarena = uobjs.getModel('userarena')
    local mUserinfo       = uobjs.getModel('userinfo')
    
    local weets= getWeeTs()
    local ts   = getClientTs()
    local rfc =mUserarena.info.rfc  or 0 
    local rft =mUserarena.info.rft  or 0
    if rft~=weets then
        rfc=0
    end
    local vip =mUserinfo.vip
    local shopCfg=getConfig("arenaShopCfg")
    local gemCost=0
    if shopCfg.refreshCost[rfc+1]~=nil  then
       gemCost=shopCfg.refreshCost[rfc+1]
    else
        gemCost=shopCfg.refreshCost[#shopCfg.refreshCost]
    end

    if gemCost >0 then
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=95,item="",value=gemCost,params={buyNum=rfc+1}})
    end
    local ret =mUserarena.refreshShop(shopCfg,mUserinfo.level)
    if not ret then
        response.ret = -13008
        return response
    end
    mUserarena.info.buy=nil 
    
    mUserarena.info.rfc=rfc+1
    mUserarena.info.rft=weets
    if uobjs.save() then  
        response.data.buy=mUserarena.info.buy 
        response.data.arenashop = mUserarena.info.shop
        response.data.rft=mUserarena.info.rft
        response.data.rfc=mUserarena.info.rfc
        response.ret = 0
        response.msg = 'Success'

    end

    
    return response




end