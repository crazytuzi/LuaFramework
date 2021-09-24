-- 合成异星武器
function api_alienweapon_addweapon(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local fid = request.params.fid
    if uid == nil or fid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('alienweapon') == 0 then
        response.ret = -11000
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "alienweapon"})
    local mAweapon = uobjs.getModel('alienweapon')

    local cfg = getConfig("alienWeaponCfg")

    -- 合成武器 消耗碎片
    local wid = cfg.fragmentList[fid].weaponId
    if mAweapon.isGetWeapon(wid) then --已经获得该武器
        response.ret = -12005
        return response
    end
    if not mAweapon.useFragment(fid, cfg.fragmentList[fid].cost) then --消耗碎片不够
        response.ret = -12006
        return response
    end

    -- 新加武器
    if not mAweapon.addWeapon(wid) then
        response.ret = -12007
        return response
    end

    if uobjs.save() then
        response.data.alienweapon = mAweapon.toArray()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
