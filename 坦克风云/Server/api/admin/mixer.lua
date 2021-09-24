-- 极品融合器
local function api_admin_mixer(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.before(request) 
        -- 开关未开启
        if not switchIsEnabled('btMix') then
            self.response.ret = -180
            return self.response
        end
    end

    function self.action_user(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end

        response.data.umixer = {
            crystal = getUserObjs(request.uid,true).getModel('umixer').getCrystal()
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_setCrystal(request)
        local response = self.response
        local uid = request.uid
        if not uid then
            response.ret = -102
            return response
        end

        local num = math.floor(request.params.num)
        if num >= 0 then
            local uobjs = getUserObjs(request.uid)
            uobjs.getModel('umixer').setCrystal(num)
            if uobjs.save() then
                response.ret = 0
                response.msg = 'Success'
            end
        end

        return response
    end

    -- 珍品数据
    function self.action_items(request)
        local response = self.response
        local aid = request.params.aid
        if not aid then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",aid,true)
        local items = mAmixer.getItems()
        local itime = mAmixer.getItime()

        for k,v in pairs(items) do
            v[2] = itime[v[2]]
        end

        response.data.amixer = {items = items}
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 原料
    function self.action_getMaterial(request)
        local response = self.response
        local aid = request.params.aid
        if not aid then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",aid,true)
        response.data.amixer = mAmixer.toArray()

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 设置原材料
    function self.action_setMaterial(request)
        local response = self.response
        local aid = request.params.aid
        local material = request.params.material
        if not aid or type(material) ~= "table" then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",aid)
        local mixerCfg = getConfig("bestMixer")
        for k,v in pairs(material) do
            if v >= 0 then
                mAmixer.setMaterial(k,v)
            end
        end

        if mAmixer.save() then
            response.data.amixer = mAmixer.toArray()
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 删除珍品
    function self.action_delItem(request)
        local response = self.response
        local aid = request.params.aid
        local idx = request.params.idx
        if not aid or type(idx) ~= "table" then
            response.ret = -102
            return response
        end

        table.sort(idx,function (a,b) return a > b end)
        local mAmixer = getModelObjs("amixer",aid)
        for _,v in pairs(idx) do
            mAmixer.delItem(v)
        end

        if mAmixer.save() then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- function self.after() end

    return self
end

return api_admin_mixer