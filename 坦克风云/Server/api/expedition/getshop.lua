-- 获取远征军的商店

function api_expedition_getshop(request)
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
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo       = uobjs.getModel('userinfo')
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local weets= getWeeTs()
    local ts   = getClientTs()
    local shopCfg=getConfig("expeditionShopCfg")
    local sysref_time = weets+shopCfg.RefreshTime[1]*3600+shopCfg.RefreshTime[2]*60
    --如果刷新时间小于当前的时间 那就是下一天的这个点刷新
    if sysref_time < ts then  sysref_time=sysref_time+24*3600  end
    local ref_at =mUserExpedition.info.rt or  0

    --下一次刷新时间大于自己身上的下一次刷新时间就刷新商店
    
    if sysref_time>ref_at then
        local ret =mUserExpedition.refreshShop(shopCfg,mUserinfo.level)
        if not ret then
            response.ret = -13008
            return response
        end
        mUserExpedition.info.rt=sysref_time
        mUserExpedition.info.buy=nil
        mUserExpedition.info.rft=weets
        mUserExpedition.info.rfc=0
    end

    if uobjs.save() then  
        response.data.buy=mUserExpedition.info.buy 
        response.data.expeditionshop = mUserExpedition.info.shop
        response.data.rft=mUserExpedition.info.rft
        response.data.rfc=mUserExpedition.info.rfc
        response.data.rt=mUserExpedition.info.rt
        response.ret = 0
        response.msg = 'Success'

    end

    
    return response 




end