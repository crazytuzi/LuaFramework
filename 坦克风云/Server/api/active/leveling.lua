--
-- 冲级三重奏
-- User: luoning
-- Date: 14-8-18
-- Time: 下午3:03
--
function api_active_leveling(request)

    -- 活动名称，莫斯科赌局
    local aname = 'leveling'

    local response = {
        ret=-1,
        msg='error',
        data = {['useractive'] = {[aname]={}}},
    }
    local defaultData = {0,0}
    local uid = request.uid
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuildings = uobjs.getModel('buildings')

    -- 刷新队列
    mBuildings.update()

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local cfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg )
    local level = tonumber(mBuildings['b1'][2])

    if type(mUseractive.info[aname].v) == 'table' then
        defaultData = mUseractive.info[aname].v
    end
    --60
    if action == 'l60' then

        if defaultData[1] == 1 then
            response.ret = -401
            return response
        end

        if level < 60 then
            return response
        end

        if not takeReward(uid, cfg.serverreward.l60) then
            return response
        end
        defaultData[1] = 1
    --70
    elseif action == 'l70' then

        if defaultData[2] == 1 then
            response.ret = -401
            return response
        end

        if level < 70 then
            return response
        end

        if not takeReward(uid, cfg.serverreward.l70) then
            return response
        end
        defaultData[2] = 1
    end

    mUseractive.info[aname].v = defaultData
    response.data.useractive[aname] = mUseractive.info[aname]

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end

