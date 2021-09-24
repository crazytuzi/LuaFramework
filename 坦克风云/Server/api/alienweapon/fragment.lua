-- 异星武器碎片
function api_alienweapon_fragment(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    if uid == nil then
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
    local mUserinfo = uobjs.getModel('userinfo')

    local cfg = getConfig("alienWeaponCfg")

    local self = {}
    -- 碎片分解
    function self.resolvefrag(fid, num)
        num = math.floor(num)
        if num <= 0 then
            return false, -102
        end
        local weaponId = cfg.fragmentList[fid].weaponId
        local color = cfg.weaponList[weaponId].color
        local y1 = math.floor( cfg.resolveAlienWeaponFragment[color].y1 * num)

        -- 扣碎片
        if not mAweapon.useFragment(fid, num) then
            return false, -12017
        end

        --给资源
        if not mAweapon.changey1(y1) then
            return false, -12016
        end

        return true
    end

    -- 碎片兑换
    function self.exchangefrag(idx)
        local shopcfg = cfg.alienWeaponShop[idx]

        -- 扣掉资源
        if not mAweapon.changey1( -shopcfg.price.y1 ) then
            return false, -12017
        end

        if shopcfg.gems > 0 and not mUserinfo.useGems(shopcfg.gems) then
            return false, -109
        end

        -- 发碎片
        if not takeReward(uid, shopcfg.serverReward) then
            return false, -403
        end

        if shopcfg.gems > 0 then
            regActionLogs(uid,1,{action=160,item="fragmentchange",value=gemCost,params={reward=serverReward}})
        end

        return true, shopcfg.serverReward
    end

    local action = request.params.action
    local fid = request.params.fid -- 碎片分解id
    local num = request.params.num -- 碎片数量

    local idx = request.params.idx -- 碎片兑换索引
    local ret, code = nil, nil
    if action == 1 then
        ret, code = self.resolvefrag(fid, num) -- 碎片分解
    elseif action == 2 then
        ret, code = self.exchangefrag(idx) -- 碎片兑换
    end

    if not ret then
        response.ret = code
        return response
    end

    if uobjs.save() then
        response.data.alienweapon = mAweapon.toArray()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
