-- 异星武器升级
function api_alienweapon_levelup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local wid = request.params.wid
    local addlvl = tonumber(request.params.addlvl) or 0
    if uid == nil or not wid or addlvl <= 0 then
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
    local mUserinfo = uobjs.getModel("userinfo")
    -- 升1级 | N级 N<=5

    local needexp = 0 

    local curLevel = mAweapon.info[wid][1]
    if (curLevel+addlvl) > mUserinfo.level then -- 不能超过人物等级
        response.ret = -12011
        return response
    end

    local expCfg = cfg.levelupexp[cfg.weaponList[wid].color]
    for i=curLevel, (curLevel+addlvl-1) do
        needexp = needexp + expCfg[i+1]
    end

    -- 消耗
    if not mAweapon.changeExp(-needexp) then
        response.msg = {needexp=needexp, currexp = mAweapon.exp }
        response.ret = -12031
        return response
    end

    -- 升级
    if not mAweapon.levelupWeapon(wid, addlvl) then
        response.ret = -12002
        return response
    end

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
