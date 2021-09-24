-- 获取异星武器
function api_admin_alienweapon(request)
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
    local mAweapon= uobjs.getModel('alienweapon')

    local wlist = request.params.wlist 
    -- 武器
    if type(wlist) == 'table' and next(wlist) then
        for k, v in pairs( wlist) do
            local flag = false
            if type(v) == 'table' and mAweapon.addWeapon(k, v) then
                flag = true
            elseif tonumber(v) and tonumber(v)<=0 and mAweapon.resolveWeapon(k) then
                flag = true
            end

            if not flag then
                response.ret = -403
                return response
            end
        end
    end     

    -- 碎片
    local flist = request.params.flist
    if type(flist) == 'table' and next(flist) then
        for k, v in pairs(flist) do
            local  flag = false
            -- 传过来的是总量
            v = v - (mAweapon.fragment[k] or 0)
            if tonumber(v) > 0 and  mAweapon.addFragment(k, v) then
                flag = true
            elseif tonumber(v) < 0 and mAweapon.useFragment(k, math.abs(v)) then
                flag = true
            else
                flag = true
            end

            if not flag then
                response.ret = -403
                return response
            end            
        end
    end

    -- 材料
    local plist = request.params.plist
    if type(plist) == 'table' and next(plist) then
        for k, v in pairs(plist) do
            local flag = false
            v = v - (mAweapon.props[k] or 0)
            if tonumber(v) > 0 and mAweapon.addProp(k, v) then
                flag = true
            elseif tonumber(v) < 0 and mAweapon.useProp(k, math.abs(v)) then
                flag = true
            else
                flag = true
            end

            if not flag then
                response.ret = -403
                return response
            end             
        end
    end 

    -- 经验
    local exp = tonumber(request.params.exp)
    if exp then
        mAweapon.changeExp(exp)
    end

    local y1 = tonumber(request.params.y1)
    if y1 then
        mAweapon.changey1(y1)
    end
    
    local unlock = tonumber(request.params.unlock)
    if unlock then
        local cfg = getConfig('alienWeaponSecretSeaCfg')
        if unlock > (cfg.maxChapter * 3) then
            unlock = cfg.maxChapter * 3
        end
        mAweapon.sinfo.unlock = unlock
    end

    if uobjs.save() then
        response.data.alienweapon = mAweapon.toArray()
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end
