-- 获取繁荣度
-- action=1 时间获取； action=2 钻石获取

function api_boom_get(request)

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
            response.ret = -1000
            return false, response
        end
        if idx > 0 then
            add = math.floor( cfg.gemsGetBoom[idx] * mBoom.boom_max )
            if cfg.gemsGetBoom[idx] >= 0.99 then
                add = mBoom.boom_max - mBoom.boom
            end
            needGems =  math.ceil( add / mBoom.boom_max^0.25)
        end

        if not mUserinfo.useGem(needGems) then
            response.ret = -109
            return false, response
        end
        if add > 0 then
           add = mBoom.addBoom(3, {add=add})
        end

        -- actionlog 使用金币购买繁荣度
        regActionLogs(uid,1,{action=85,item="boom",value=needGems,params={oldBoom=oldBoom, newBoom=mBoom.boom}})

        return add, response
    end

    --时间同步
    function self.addByTime()
        -- body
        mBoom.addBoom(1)
        return true
    end

    ---------------main----------------------
    local action = request.params.action
    local idx = request.params.index
    local gems = request.params.gems

    if not getConfig("gameconfig").boom or getConfig("gameconfig").boom.enable ~= 1 then
        response.ret = -108
        return response
    end
    local ret, resp
    mBoom.update()
    if action==1 then
       ret = self.addByTime()
    elseif action==2 then 
      ret, resp = self.addByGems(idx)
    end

    if not ret then
        return resp
    end
    
    if uobjs.save() then
        response.msg = 'Success'
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.boom = mBoom.toArray(true)
        response.data.boom_add = tonumber(ret) or 0
        response.ret = 0
    end

    return response
end
