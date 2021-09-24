-- 装备分解
function api_sequip_resolve(request)
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

    if moduleIsEnabled('sequip') == 0 then
        response.ret = -11000
        return response
    end

    local equipcfg = getConfig('superEquipListCfg.equipListCfg')

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "sequip"})
    local mSequip = uobjs.getModel('sequip')
    local mUserinfo = uobjs.getModel('userinfo')

    local self = {}
    --一键分解
    local cnt = 0
    function self.resolveAll( clist )
        local retaward = {}
        for eid, v in pairs( mSequip.sequip ) do --所有的装备
            local color = equipcfg[eid].color
            if arrayIndex(clist, color) then --要分解的颜色
                local validnum = mSequip.getValidEquip(eid)
                if validnum > 0 then -- 有效个数>0
                    cnt = cnt + validnum
                    local ret, code = mSequip.resolveEquip(eid, validnum)
                    if not ret then
                        return false, code
                    end

                    for m, n in pairs( code ) do
                        retaward[m] = (retaward[m] or 0) + n
                    end
                end
            end
        end

        return true, retaward
    end

    -----------main
    local eid = request.params.eid
    local clist = request.params.clist
    local ret, code = nil, nil

    if eid then -- 分解一个
        cnt = cnt + 1
        ret, code = mSequip.resolveEquip(eid, cnt)
    elseif clist then -- 一键分解
        ret, code = self.resolveAll(clist)
    end

    if not ret then
        response.ret = code or -1
        return response
    end

    --分解道具格式化
    local award = {}
    for k, v in pairs( code ) do
        award["props_" .. k] = v
    end
    
    -- 全线突围活动埋点
    activity_setopt(uid, 'qxtw', {action=3,num=cnt})

    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then 
        processEventsAfterSave()
        response.data.reward = formatReward( award )
        response.data.sequip = mSequip.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end

    return response

end
