
-- 配件商店

function api_accessory_buy(request)
    local response = {
        ret=-1,
            msg='error',
            data = {},
    }

    local uid = request.uid

    local pid = request.params.id
    local num= request.params.num or 1
       
    if (uid ==nil ) then
        response.ret=-102
        return response
    end
        
    if moduleIsEnabled('ec') == 0 then
        response.ret = -9000
        return response
    end
    if moduleIsEnabled('ecshop') == 0 then
        response.ret = -9030
        return response
    end

    local shopItems = getConfig("accessory.shopItems")
    if type(shopItems[pid])~='table' or not next(shopItems[pid]) then
        response.ret = -9031
        return response
    end
    local items =shopItems[pid] 
    local version  =getVersionCfg()
    -- ckeck version AccParts open pos
    if items.type>version.unlockAccParts then
        response.ret = -9032
        return response
    end

    local useProps=items.price

    if type(useProps)~='table' or not next(useProps) then
        response.ret=-102
        return response
    end

    local uesGems =items.gems*num
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "props","bag","dailytask","task","accessory"})
    local mAccessory = uobjs.getModel('accessory')
    local mUserinfo  = uobjs.getModel('userinfo')
    local mBag       = uobjs.getModel("bag")

    if uesGems>0 then

        if not mUserinfo.useGem(uesGems) then
            response.ret = -109 
            return response
        end
        regActionLogs(uid,1,{action=57,item=pid,value=uesGems,params={pid=1}})
    end

    for i=1,num do
        local ret =mAccessory.useProps(useProps)
        if not ret then
            response.ret = -9033
            return response
        end

        local reward =items.serverReward
        if not takeReward(uid,reward) then        
            response.ret = -403 
            return response
        end        
    end

    if uobjs.save() then 
        response.data.accessory =mAccessory.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response

   
end