-- 异星武器分解
function api_alienweapon_reslove(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local wid = request.params.wid
    if uid == nil or wid == nil then
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


    --卸下装备上的宝石
    mAweapon.easydeJewel(wid) 

    -- 装配的武器不能分解
    if table.contains(mAweapon.used, wid) then
        response.ret = -12021
        return response
    end

    -- 分解武器
    local ret = mAweapon.resolveWeapon(wid)
    if not ret then
        response.ret = -12007
        return response
    end

    if uobjs.save() then
        response.data.alienweapon = mAweapon.toArray(true)

        if moduleIsEnabled("jewelsys") == 1 then
            response.data.alienjewel = mAweapon.formjeweldata()
        end 
        response.data.reward = ret
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
