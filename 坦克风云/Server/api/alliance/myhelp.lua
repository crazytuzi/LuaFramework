-- 获取
function api_alliance_myhelp(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if moduleIsEnabled('alliancehelp') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
    local mtype=request.params.type or 1
    ALLIANCEHELP = require "lib.alliancehelp"
    local ts=getClientTs() 

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    if mtype==1 then
        local alist=ALLIANCEHELP:getmylist(uid,ts, mUserinfo.alliance)
        if type(alist)=='table' and next(alist) then
            for k,v in pairs(alist) do
                alist[k].info=json.decode(v.info)
            end
            response.data.mylist=alist
        end
        
    else
        local alist=ALLIANCEHELP:gethelplist(uid)
        if type(alist)=='table' and next(alist) then
            for k,v in pairs(alist) do
                alist[k].info=json.decode(v.info)
            end
            response.data.myhelplog=alist
        end
    end   
    
    response.ret = 0
    response.msg = 'Success'
    return response
end

