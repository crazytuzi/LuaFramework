-- 军功商店的购买

function api_user_creditshopbuy(request)
    local response = {
        ret=-1,
        msg='error',
        data ={},
    }
    
    local uid = request.uid
    local id  =request.params.id 
     if uid == nil then
        response.ret = -102
        return response
    end
    -- 商店未开启
    if  moduleIsEnabled('rpshop') == 0  then
        response.ret=-14000
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))
    local shopCfg = getConfig("creditShopCfg")
    local opentime = shopCfg.opentime
    local startday =opentime[1] or 6
    local endday   =opentime[2] or 0
    if weekday~=startday and weekday~=endday then
        response.ret=-14001
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mProps = uobjs.getModel('props')
    local mUserinfo = uobjs.getModel('userinfo')
    local version  =getVersionCfg()
    local pShopItems=shopCfg.pShopItems
    local aShopItems=shopCfg.aShopItems
    local ac =version.unlockTankShopIdStr[2]
    local pc =version.unlockTankShopIdStr[1]
    if type(aShopItems[id])~='table' and type(pShopItems[id])~='table' then
        response.ret=-14002
        return response
    end

    local aret =string.find(id,'a')
    -- 真品
    local item =nil
    local  buyc =0
    if aret ~=nil then
        local ids =id:split('a')
        if tonumber(ids[2])> ac then
            response.ret=-14003
            return response
        end
        
        item=aShopItems[id]
        buyc =math.floor(mUserinfo.rank*0.225-0.5)

    else--普通
        local ids =id:split('i')
        if tonumber(ids[2])> pc then
            response.ret=-14003
            return response
        end
        item=pShopItems[id]
        buyc =math.floor(mUserinfo.rank*0.5-1)
    end
    local ids =id:split('a')

    local reftime = shopCfg.reftime

    local time =0
    
    if weekday==startday then
        -- 默认刷新
        time=weeTs
        if ts >= weeTs+reftime[1]*3600 then
            time=weeTs+reftime[1]*3600
        end
        if ts >weeTs+reftime[2]*3600 then
            time=weeTs+reftime[2]*3600
        end
    else
        time=weeTs-86400+reftime[2]*3600
        if ts >= weeTs+reftime[1]*3600 then
            time=weeTs+reftime[1]*3600
        end

        if ts >= weeTs+reftime[2]*3600 then
            time=weeTs+reftime[2]*3600
        end
    end 

    local lastts =mProps.shop.ts or 0
    if type(mProps.shop.b)~='table' then mProps.shop.b={}   end 
    if time >lastts then
       mProps.shop.b={} 
    end
    local ubuyc =mProps.shop.b[id] or 0
    if ubuyc>= buyc then
        response.ret=-14004
        return response
    end

    local userpb =item.price
    if mUserinfo.rpb <userpb then
        response.ret=-14005
        return response
    end

    if mUserinfo.rank< item.rank then
        response.ret=-14007
        return response
    end
    
    local cachekey ="zid."..getZoneId().."creditShop.ts."..time.."id."..id
    local redis = getRedis()
    local c =tonumber(redis:get(cachekey)) or 0
    
    if c==nil then
        c=0
    end

    if c >item.buynum then
        response.ret=-14006
        return response
    end
    local  maxcount= tonumber(redis:incr(cachekey)) or 0

    if maxcount>item.buynum then
        response.ret=-14006
        return response
    end
    redis:expire(cachekey,86400*2)    
    mProps.shop.b[id]=(mProps.shop.b[id] or 0) +1
    mProps.shop.ts=ts
    mUserinfo.rpb =mUserinfo.rpb -userpb
    local reward=item.serverReward
    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end
    if uobjs.save() then
        response.ret = 0        
        response.msg = 'Success'
        response.data[id]=maxcount
    end
    return response
end