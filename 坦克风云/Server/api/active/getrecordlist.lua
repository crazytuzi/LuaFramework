--
-- 获取各种记录
-- User: luoning
-- Date: 15-1-19
-- Time: 上午11:45
--
function api_active_getrecordlist(request)

    local uid = request.uid
    local aname = request.params.activeName
    --是个人的还是整个活动的记录
    local dtype = request.params.dtype

    if uid == nil or aname == nil then
        response.ret = -102
        return response
    end

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local recordName = aname
    if dtype == 1 then
        recordName = aname.."-"..uid
    end
    require "lib.rewardrecord"
    response.data[aname].recordlist = getSrewardRecord(recordName, mUseractive.info[aname].et)
    response.ret = 0
    response.msg = "Success"
    return response

end

