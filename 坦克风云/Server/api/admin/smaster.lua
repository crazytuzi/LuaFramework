-- 超级装备大师 gm
-- chenyunhe

local function api_admin_master(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.before()
        if moduleIsEnabled('smaster') == 0 then
            response.ret = -180
            response.msg = 'not open'
            return response
        end
    end

    -- 添加装备大师
    function self.action_add(request)
        local response = self.response
        local uid =  request.uid
        local eid = request.params.eid
        local num = request.params.num or 1
        if not uid or not eid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mSequip = uobjs.getModel('sequip') 

        local mcount = table.length(mSequip.smaster)
        local max = getConfig('sequipMaster.main.ownLimit')
        -- 上限需要取配置
        if mcount+num>max then
            response.ret = -100
            response.msg = 'max'
            return response
        end
    
        
        if not mSequip.addMater(eid,num) then
            response.ret = -106
            response.msg = 'save fail'
            return response
        end

        if uobjs.save() then
            response.data.smaster = mSequip.smaster
            response.data.sequip = mSequip.sequip
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 查询
    function self.action_get(request)
        local response = self.response
        local uid =  request.uid
      
        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mUserinfo = uobjs.getModel('userinfo') 
        local mSequip = uobjs.getModel('sequip') 
 
        response.data.smaster = mSequip.smaster
        response.data.sequip = mSequip.sequip
        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 保存装备大师的属性
    function self.action_upatt(request)
        local response = self.response
        local uid = request.uid
        local eid = request.params.eid
        local att = request.params.att

        if not uid or type(att)~='table' then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mSequip = uobjs.getModel('sequip') 

        if not mSequip.smaster[eid] then
            response.ret = -102
            return response
        end

        local xCfg = getConfig('sequipMaster.refine.x1')-- 取x1 x2 x3哪个都行
        local maxAtt = xCfg.maxAtt 

        for k,v in pairs(att) do    
            mSequip.smaster[eid][3][k] = tonumber(v)
            if mSequip.smaster[eid][3][k] > maxAtt[k] then
                mSequip.smaster[eid][3][k] = maxAtt[k]
            end
        end
    
        if uobjs.save() then
            response.data.smaster = mSequip.smaster
            response.data.sequip = mSequip.sequip
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 设置装备大师上面装配的超级装备 
    function self.action_setsequip(request)
        local response = self.response
        local uid = request.uid
        local eid = request.params.eid
        local sequip = request.params.sequip

        if not uid or type(sequip)~='table' then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mSequip = uobjs.getModel('sequip') 

        if not mSequip.smaster[eid] then
            response.ret = -102
            return response
        end

        for k,v in pairs(sequip) do
            local p = tonumber(string.sub(k,2))
            if v and v~=0 then
                if not mSequip.sequip[v] then
                    response.ret = -102
                    return response
                end
                mSequip.smaster[eid][2][p] = v
            else
                mSequip.smaster[eid][2][p] = 0
            end
        end
    
        if uobjs.save() then
            response.data.smaster = mSequip.smaster
            response.data.sequip = mSequip.sequip
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response
    end

    -- 删除装备大师
    function self.action_delsmaster(request)
        local response = self.response
        local uid = request.uid
        local eid = request.params.eid

        if not uid then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","sequip"})
        local mSequip = uobjs.getModel('sequip') 

        if not mSequip.smaster[eid] then
            response.ret = -102
            return response
        end

        mSequip.smaster[eid] = nil
        if uobjs.save() then
            response.data.smaster = mSequip.smaster
            response.data.sequip = mSequip.sequip
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end

        return response

    end

    return self
end

return api_admin_master
