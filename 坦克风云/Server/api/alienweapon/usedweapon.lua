-- 装配异星武器
function api_alienweapon_usedweapon(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local wlist = request.params.wlist
    if uid == nil or type(wlist) ~= 'table' then
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

    for k, v in pairs(wlist) do
        if v ~= 0 and not mAweapon.isGetWeapon(v) then
            response.ret = -12009
            return response
        end
    end
    -- 已经装备的武器
    local oldwlist = copyTable(mAweapon.used)
    if not mAweapon.usedWeapon(wlist) then
        response.ret =-12010
        return response
    end

    -- 找出被卸下的武器 把上面的宝石卸掉 
    for k,v in pairs(oldwlist) do
        local pre = string.sub(v,1,2)
        if pre=='aw' and not table.contains(wlist,v) and v~=0 then
            mAweapon.easydeJewel(v)
        end
    end


    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()    
    if uobjs.save() then
        processEventsAfterSave()
        response.data.alienweapon = mAweapon.toArray(true)

        if moduleIsEnabled("jewelsys") == 1 then
            response.data.alienjewel = mAweapon.formjeweldata()
        end 
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
