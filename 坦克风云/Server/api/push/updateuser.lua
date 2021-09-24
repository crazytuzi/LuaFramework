function api_push_updateuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }



    local uid = request.uid
    local binid = request.push.binid
    local buyNums = tonumber(request.params.num) or 1

    if binid == nil or uid == nil then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end
    if moduleIsEnabled('push') == 0 then
        response.ret = -4012
        return response
    end

    local ts = getClientTs()
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local d= 0
    if type (request.push)=='table'  then
        if request.push.tb[1]~=nil and request.push.tb[1]==1 then
            d=1
        end

    end           
    local mUserinfo = uobjs.getModel('userinfo')
    local execRet, code=M_push.updateUserInFo({bindid=binid,ts=ts,c=0,regdate=mUserinfo.regdate,d=d,lag=request.lang,p=request.system})


    response = execRet            
    return response
end
