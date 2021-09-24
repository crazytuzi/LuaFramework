-- 获取军演商店

function api_military_getshop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local id  = tonumber(request.params.id) or 1
    if uid ==nil or id==nil then
        response.ret=-102
        return response
    end


    if moduleIsEnabled('military') == 0  then
        response.ret = -10000
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops","userarena"})
    local mUserarena = uobjs.getModel('userarena')
    local mUserinfo       = uobjs.getModel('userinfo')
    
    local weets= getWeeTs()
    local ts   = getClientTs()
    local shopCfg=getConfig("arenaShopCfg")
    local sysref_time = weets+shopCfg.RefreshTime[1]*3600+shopCfg.RefreshTime[2]*60
    if type(mUserarena.info)~='table' then  mUserarena.info={} end
    --如果刷新时间小于当前的时间 那就是下一天的这个点刷新
    if sysref_time < ts then  sysref_time=sysref_time+24*3600  end
    local ref_at =mUserarena.info.rt or  0

    --下一次刷新时间大于自己身上的下一次刷新时间就刷新商店
    if sysref_time>ref_at then
        local ret =mUserarena.refreshShop(shopCfg,mUserinfo.level)
        if not ret then
            response.ret = -13008
            return response
        end
        mUserarena.info.rt=sysref_time
        mUserarena.info.buy=nil
        mUserarena.info.rft=weets
        mUserarena.info.rfc=0
    end

    if uobjs.save() then  
        response.data.buy=mUserarena.info.buy 
        response.data.arenashop = mUserarena.info.shop
        response.data.rft=mUserarena.info.rft
        response.data.rfc=mUserarena.info.rfc
        response.data.rt=mUserarena.info.rt
        response.ret = 0
        response.msg = 'Success'

    end

    
    return response 
end