-- 飞机相关接口
local function api_plane_plane()
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid = { "required" }
            },
            ["action_unlock"] = {
                pid = { "required", "string" }
            },
        }
    end
    
    function self.before(request) 
        
    end

    -- 信息
    function self.action_get(request)
        local response = self.response
        local uid = request.uid
        if uid == nil then
            response.ret = -102
            return response
        end

        if moduleIsEnabled('plane') == 0 then
            response.ret = -17000
            return response
        end
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"plane"})
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')
        local ret=mPlane.checkAttackStats()
        if ret then
            if not uobjs.save() then
                return response
            end
        end
        response.data.plane = mPlane.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
        
        return response
    end
    
    -- 解锁
    function self.action_unlock(request)
        local response = self.response
        local uid = request.uid
        local planeId = request.params.pid
        local planeCfg = getConfig('planeCfg')
        if moduleIsEnabled('plane') == 0 then
            response.ret = -17000
            return response
        end
        if uid==nil or planeId==nil then
            response.ret = -102
            return response
        end
        if (planeCfg.plane and planeCfg.plane[planeId]==nil) then
            response.ret = -102
            return response
        end
        
        local uobjs = getUserObjs(uid)
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBuildings = uobjs.getModel('buildings')
        if mPlane.plane==nil then
            mPlane.plane={}
        end

        local index=#mPlane.plane+1
        if (planeCfg.openLevel and planeCfg.openLevel[index]==nil) then
            response.ret = -102
            return response
        end
        --需要根据配置判断等级是否能解锁
        local reqLv=tonumber(planeCfg.openLevel[index])
        local curlv = tonumber(mBuildings.b52[2]) or 0
        if curlv<reqLv then
            response.ret = -12100
            return response
        end

        for k,v in pairs(mPlane.plane) do
            if v and v[1] then
                local pId=v[1]
                if pId==planeId then
                    response.ret = -12101
                    return response
                end
            end
        end

        table.insert(mPlane.plane,{planeId,{},{}})

        regEventBeforeSave(uid, 'e1')
        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            response.data.plane = mPlane.toArray(true)
            response.ret = 0
            response.msg = 'Success'
        end
        
        return response
    end

    function self.after(response)  

    end

    return self
end

return api_plane_plane