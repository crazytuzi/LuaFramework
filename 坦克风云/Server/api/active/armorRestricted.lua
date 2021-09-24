function api_active_armorRestricted(request)
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

    -- 活动名称 矩阵限购
    local activeName = 'armorRestricted'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local activeCfg = getActiveCfg(uid, activeName)
    local self = {}

    function self.getReward(idx)
        if type(mUseractive.info[activeName].rw)~='table' then
            mUseractive.info[activeName].rw = {}
            for k, v in pairs(activeCfg.reward) do
                table.insert(mUseractive.info[activeName].rw, 0)
            end            
        end

        if not mUseractive.info[activeName].rw[idx] or tonumber(mUseractive.info[activeName].rw[idx]) > activeCfg.reward[idx].count then
            return false, -13002
        end 

        -- 单价*数量*折扣
        local useGems = math.floor(activeCfg.reward[idx].rebate * activeCfg.price.armor_exp * activeCfg.reward[idx].r.armor_exp)
        if not mUserinfo.useGem(useGems) then
            return false, -109 
        end        

        local reward = activeCfg.reward[idx].r
        if not takeReward(uid, reward) then
            return false, -403
        end

        mUseractive.info[activeName].rw[idx] = mUseractive.info[activeName].rw[idx] + 1
        
        regActionLogs(uid,1,{action=161,item=0,value=useGems,params={reward=reward}})

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
        response.data.userinfo = mUserinfo.toArray(true) 
        response.data.reward = formatReward(code)
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
