function api_notice_list(request)
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
    local appid = tonumber(request.appid) or 0
    local uobjs = getUserObjs(uid)
    local sys   = request.system
    local mUserinfo = uobjs.getModel('userinfo')

    local sysNotice = require "model.notice"
    local notices = sysNotice:getUserNewNotice(mUserinfo, nil, appid,sys)

    local ts = getClientTs()
    mUserinfo.flags.notice = ts
    uobjs.save()

    if type(notices) == 'table' then
        for k,v in pairs(notices) do 
            notices[k].content = nil
            notices[k].user_from= nil
            notices[k].user_to= nil
            notices[k].enabled= nil
            notices[k].appid= nil
        end
    end

    response.data.notices = notices
    response.ret = 0
    response.msg = 'Success'
    return response
end
