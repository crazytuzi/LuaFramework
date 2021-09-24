-- 装备商店购买

function api_equip_buy(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local tId = request.params.tId
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'equip',"hero","userarena","userexpedition"})
    local mBag = uobjs.getModel('bag')

    local equipShopCfg = getConfig('equipShopCfg.pShopItems')

    local buyitem = getConfig('equipShopCfg.buyitem')
    if equipShopCfg[tId]==nil then
        response.ret=-102
        return response
    end
     
    if not mBag.use(buyitem,equipShopCfg[tId].price) then
        response.ret=-1996
        return response
    end
    response.data.bag = mBag.toArray(true)
     

    if not takeReward(uid,equipShopCfg[tId].serverReward) then
        return response
    end

    if uobjs.save() then        
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
    
end