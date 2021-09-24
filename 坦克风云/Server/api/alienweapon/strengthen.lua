-- 异星武器强化
function api_alienweapon_strengthen(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local wid = request.params.wid
    if uid == nil or not wid then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('alienweapon') == 0 then
        response.ret = -11000
        return response
    end

    local cfg = getConfig("alienWeaponCfg")

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "alienweapon"})
    local mAweapon= uobjs.getModel('alienweapon')

    -- 武器等级限制
    local weaponLvl = mAweapon.info[wid][1] -- 武器等级
    local uplevel = mAweapon.info[wid][2] + 1 -- 强化1级
    if cfg.strengWeaponLimit[uplevel] > weaponLvl then
        response.ret = -12025
        return response
    end

    -- 消耗
    local consumes = cfg.levelStreng[cfg.weaponList[wid].color][uplevel]
    local fid = cfg.weaponList[wid].fragment
    if not mAweapon.useFragment(fid, consumes.af) then -- 消耗碎片
        response.ret = -12026
        return response
    end

    local props = {}
    for k, pid in pairs(cfg.weaponList[wid].stuff) do --简化配置，消耗材料道具组装
        props[pid] = consumes.stuff[k]
    end    
    if not mAweapon.useProps(props) then
        response.ret = -12026
        return response
    end

    -- 强化
    if not mAweapon.strengthenWeapon(wid, 1) then
        response.ret = -12027
        return response
    end

    -- 节日花朵
    activity_setopt(uid,'jrhd',{act="tk",color=cfg.weaponList[wid].color,id="yj",num=1})

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()  
    if uobjs.save() then
        processEventsAfterSave()
        response.data.alienweapon = mAweapon.toArray()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
