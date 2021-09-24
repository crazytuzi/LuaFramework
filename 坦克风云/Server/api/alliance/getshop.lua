function api_alliance_getshop(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            alliancegetshop = {}
        },
    }
    
    local uid = request.uid     
    local action = tonumber(request.params.type)    -- 参数：type，为1的时候是获取个人商店的数据，为2的时候是获取全军团共享的商店中的数据

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end
    
    -- 军团商店已关闭
    if moduleIsEnabled('allianceshop') == 0 then
        response.ret = -4016 
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')    

    -- 获取全军团共享的商店中的数据
    if action == 2 then
        local allianceShops = {}
        local ts = getClientTs()
        local userRefreshFlag = false
        local allianceShopCfg = getConfig('allianceShopCfg')   
        local lastRefreshTs = M_alliance.getShopLastRefreshTs(allianceShopCfg.aShopRefreshTime,ts)
        local shops,boughtInfo = M_alliance.getShop(lastRefreshTs)
        
        if not boughtInfo then
            local ret = M_alliance.alliancestoreinfo{aid=mUserinfo.alliance,rftime = lastRefreshTs}
            if ret and type(ret.data) == 'table' then
                boughtInfo = {}
                for k,v in pairs(ret.data) do
                    local slotinfo = string.split(k,'_')
                    if type(slotinfo) == 'table' then
                        boughtInfo[tonumber(slotinfo[2])] = {slotinfo[1],tonumber(v)}
                    end                    
                end
            end
        end
        
        for k,v in pairs(shops or {}) do
            allianceShops[k] = {v,0,0,k}
        end

        if type(boughtInfo) == 'table' then
            for k,v in pairs(boughtInfo) do
                if allianceShops[k] and allianceShops[k][1] == v[1] then 
                    allianceShops[k][2] = v[2]
                end
            end
        end

        if ( mProp.allianceinfo.a.refreshAt or 0 ) < lastRefreshTs then
            mProp.allianceinfo.a = {}
            mProp.allianceinfo.a.refreshAt = ts
            userRefreshFlag = true
        else
            local buyKey
            for k,v in pairs(shops) do
                buyKey = v.. '_' .. k                        
                if mProp.allianceinfo.a[buyKey] then
                    allianceShops[k][3] = mProp.allianceinfo.a[buyKey]
                end
            end
        end
        
        response.data.alliancegetshop = allianceShops

        if userRefreshFlag and uobjs.save() then            
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    if action == 1 then
        local userRefreshFlag = false
        local lastRefreshTs = getWeeTs()
        local ts = getClientTs()

        if ( mProp.allianceinfo.p.refreshAt or 0 ) < lastRefreshTs then
            mProp.allianceinfo.p = {}
            mProp.allianceinfo.p.refreshAt = ts
            userRefreshFlag = true
        end

        if userRefreshFlag and uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = 0
            response.msg = 'Success'
        end

        response.data.alliancegetshop = mProp.allianceinfo.p

        return response        
    end
    -- 军团领地商店
    if action == 3 then
        local userRefreshFlag = false
        local lastRefreshTs = getWeeTs()
        local ts = getClientTs()
        if type(mProp.allianceinfo.s)~='table' then
            mProp.allianceinfo.s = {}
        end

        if ( mProp.allianceinfo.s.refreshAt or 0 ) < lastRefreshTs then
            mProp.allianceinfo.s = {}
            mProp.allianceinfo.s.refreshAt = ts
            userRefreshFlag = true
        end

        if userRefreshFlag and uobjs.save() then
            response.ret = 0
            response.msg = 'Success'
        else
            response.ret = 0
            response.msg = 'Success'
        end

        response.data.alliancegetshop = mProp.allianceinfo.s

        return response        
    end    
    
end 