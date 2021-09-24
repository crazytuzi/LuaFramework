-- 购买繁荣度


function api_boom_buy(request)

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
    if moduleIsEnabled('boom') == 0 then
        response.ret = -17000
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","boom"})
    local mBoom = uobjs.getModel('boom')
    local mUserinfo = uobjs.getModel('userinfo')

    local cfg = getConfig('boom')
    local self = {}
    --钻石购买
    function self.addByGems( idx )
        -- body
        local needGems = 0
        local add = 0
        local oldBoom = mBoom.boom

        if mBoom.boom_max <= mBoom.boom then
            response.ret = -2037
            return false, response
        end
        if idx > 0 then
            add = mBoom.boom_max - mBoom.boom
            if idx > add then
                add = idx
            end
            local gemFix = tonumber(mBoom.bmd) == 1 and 1 + cfg.destoryGlory.gemFix or 1
            needGems =  math.ceil( add * 0.01 * gemFix )
        end

        if not mUserinfo.useGem(needGems) then
            response.ret = -109
            return false, response
        end
        if add > 0 then
           add = mBoom.addBoom(3, {add=add})
        end

        -- actionlog 使用金币购买繁荣度
        regActionLogs(uid,1,{action=124,item="boom",value=needGems,params={oldBoom=oldBoom, newBoom=mBoom.boom}})

        return add, response
    end



    ---------------main----------------------
    local idx = request.params.index
    local gems = request.params.gems

    
    local ret, resp
    mBoom.update()

    ret, resp = self.addByGems(idx)


    if not ret then
        return resp
    end
    regEventAfterSave(uid,'e8',{})

    if uobjs.save() then
        processEventsAfterSave()  
        response.msg = 'Success'
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.boom = mBoom.toArray(true)
        response.data.boom_add = tonumber(ret) or 0
        response.ret = 0
    end

    return response
end
