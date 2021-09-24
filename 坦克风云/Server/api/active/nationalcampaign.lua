--
-- 国庆活动2
-- User: luoning
-- Date: 14-9-23
-- Time: 下午7:32
--

function api_active_nationalcampaign(request)

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

    -- 活动名称
    local aname = 'nationalCampaign'

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local res = activity_setopt(uid,aname,{action='getlist'})
    response.ret=0
    response.msg = 'Success'
    response.index = res[2]
    response.refreshTime = res[3]
    response.data=res[1]
    return response
end

