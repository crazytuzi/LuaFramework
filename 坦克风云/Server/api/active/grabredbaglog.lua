-- 抢红包日志
function api_active_grabredbaglog(request)
    
    local response = {    
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local redid = tonumber(request.params.redid) or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，抢红包
    local acname = 'grabRed'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    local activStatus = mUseractive.getActiveStatus(acname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local grablog = mUseractive.getlog(getZoneId(),acname..redid.."grablog."..mUseractive.info[acname].st)
    local redinfo = mUseractive.getlog(getZoneId(),acname)
    if type(redinfo) =='table' then

        if type(redinfo[redid]) ~='table' then
            for k,v in pairs(redinfo) do
                if v[1]==redid then
                    redinfo=v
                    break
                end 
            end
        else
            redinfo=redinfo[redid]
        end
    else
        redinfo={}
    end
    response.data.grablog=grablog
    response.data.useredbag=redinfo
    response.ret = 0        
    response.msg = 'Success'
    return  response


end