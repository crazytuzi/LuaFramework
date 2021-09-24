-- 军功商店的获取

function api_user_creditshopget(request)
    local response = {
        ret=-1,
        msg='error',
        data ={},
    }
    
    local uid = request.uid

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
    local mUserinfo = uobjs.getModel('userinfo')
    local version  =getVersionCfg()
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
    local cachekey ="zid."..getZoneId().."creditShop.ts."..time.."id."

    local ac =version.unlockTankShopIdStr[2]
    local pc =version.unlockTankShopIdStr[1]
    local shop={}
    local redis = getRedis()
    for i=1,ac do
        --local getkey = 
        local id="a"..i
        local c =redis:get(cachekey..id)
        if c==nil then
            c=0
        end
        shop[id]=c
    end
    for i=1,pc do
        local id="i"..i
        local c =redis:get(cachekey..id)
        if c==nil then
            c=0
        end
        shop[id]=c
    end
   

    response.data.creditshop=shop
    response.ret=0
    response.msg="Success"

    return response

end