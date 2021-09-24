-- 远征军商店刷新

function api_expedition_refshop(request)
	local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid ==nil then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","userexpedition","hero","troops"})
    local mUserExpedition = uobjs.getModel('userexpedition')
    local mUserinfo       = uobjs.getModel('userinfo')
    if mUserExpedition.info.grade==nil then
        response.ret=-102
        return response
    end

    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end
    local weets= getWeeTs()
    local ts   = getClientTs()
    local rfc =mUserExpedition.info.rfc  or 0 
    local rft =mUserExpedition.info.rft  or 0
    if rft~=weets then
    	rfc=0
    end
    local vip =mUserinfo.vip
    local shopCfg=getConfig("expeditionShopCfg")
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
        regActionLogs(uid,1,{action=96,item="",value=gemCost,params={buyNum=rfc+1}})
    end
    

    local ret =mUserExpedition.refreshShop(shopCfg,mUserinfo.level)
    if not ret then
        response.ret = -13008
        return response
    end
    mUserExpedition.info.buy=nil 
    
    mUserExpedition.info.rfc=rfc+1
    mUserExpedition.info.rft=weets
    if uobjs.save() then  
        response.data.buy=mUserExpedition.info.buy 
        response.data.expeditionshop = mUserExpedition.info.shop
        response.data.rft=mUserExpedition.info.rft
        response.data.rfc=mUserExpedition.info.rfc
        response.ret = 0
        response.msg = 'Success'

    end

    
    return response
end