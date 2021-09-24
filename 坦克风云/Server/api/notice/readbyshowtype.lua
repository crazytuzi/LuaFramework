-- 登陆公告
function api_notice_readbyshowtype(request)
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
    -- showtype =1 登陆公告； showtype =2 LED走马灯 
    local showtype = tonumber(request.showtype) or 1
    local appid = tonumber(request.appid) or 0
    local uobjs = getUserObjs(uid)
    local sys   = request.system
    local mUserinfo = uobjs.getModel('userinfo')

    local sysNotice = require "model.notice"
    local notices = sysNotice:getUserNewNotice(mUserinfo, nil, appid,sys)

    -- local ts = getClientTs()
    -- mUserinfo.flags.notice = ts
    -- uobjs.save()
    local time_st = 0
    local ret_k = 0
    local time_st2 = 0
    local ret_k2 = 0
    if type(notices) == 'table' then
        for k,v in pairs(notices) do  
            if tonumber(notices[k].showtype) == 1 and tonumber(notices[k].time_st) >= time_st  then
                ret_k = k
                time_st = tonumber(notices[k].time_st)
            end

            if tonumber(notices[k].showtype) == 2 and tonumber(notices[k].time_st) >= time_st2  then
                ret_k2 = k
                time_st2 = tonumber(notices[k].time_st)
            end

        end
    end

    response.data.notices = notices[ret_k] 
    response.data.notices2 = notices[ret_k2] 
    response.ret = 0
    response.msg = 'Success'
    return response
end
