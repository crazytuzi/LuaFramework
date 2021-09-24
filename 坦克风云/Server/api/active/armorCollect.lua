function api_active_armorCollect(request)
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

    -- 活动名称 矩阵收集
    local activeName = 'armorCollect'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local activeCfg = getActiveCfg(uid, activeName)
    local self = {}

    function self.getReward(idx)
        if type(mUseractive.info[activeName].rw)~='table' or not mUseractive.info[activeName].rw[idx] then
            return false, -13001
        end      

        if mUseractive.info[activeName].rw[idx][2] ~= 1 then
            return false, -13001
        end 

        local reward = activeCfg.serverreward[idx].r
        if not takeReward(uid, reward) then
            return false, -403
        end

        mUseractive.info[activeName].rw[idx][2] = 2 

        return true, reward
    end

    ----------------------main-----------------------------
    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(activeName)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
        
    local index = tonumber(request.params.index)   
    local ret, code 

    ret, code = self.getReward(index)

    if not ret then
        response.ret = code
        return response 
    end

    processEventsBeforeSave()
    if  uobjs.save() then        
        processEventsAfterSave()
        response.data.reward = formatReward(code)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
