-- 战争之路领奖
-- action 1为领奖
-- index 领奖位置
-- 凌晨刷新
function api_active_battleRoadreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {battleRoad={}},
    }

    local uid = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive', 'bag' })
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动名称
    local aname = 'battleRoad'
    cfg = getActiveCfg(uid, aname)

    local self = {}
    -------------------local func--------------------------
    --发奖
    function self.getReward(idx)
        -- body
        --参数有误
        if idx > #cfg.serverreward then
            response.ret = -102
            return false, response
        end

        --已经领奖
        if not mUseractive.info[aname].get then
            mUseractive.info[aname].get ={}
        end
        for k, v in pairs( mUseractive.info[aname].get ) do
            if v == idx then
                response.ret = -2000
                return false, response
            end
        end

        table.insert(mUseractive.info[aname].get, idx)

        --发奖
        if not takeReward(uid, cfg.serverreward[idx].reward) then
            response.ret = -801
            return false, response
        end

        return true, formatReward(cfg.serverreward[idx].reward)
    end

    --零点刷新
    function self.init()
        -- body
        local ts = getWeeTs()
        if not mUseractive.info[aname].t or mUseractive.info[aname].t ~= ts then
            mUseractive.info[aname].t = ts
            mUseractive.info[aname].c = 0
            mUseractive.info[aname].get = {}
        end

    end

    --------------------------main-----------------------------
    local activStatus
    activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    
    local index = request.params.index
    local action = request.params.action
    local ret, resp
    --逻辑处理
    self.init()
    if action == 1 then
       ret, resp = self.getReward(index)
    end

    --异常处理
    if not ret then
        return resp
    end 

    processEventsBeforeSave()
    if uobjs.save() then        
        processEventsAfterSave()

        response.data.reward = resp
        response.data[aname] = mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end
