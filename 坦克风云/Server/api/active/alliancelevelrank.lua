function api_active_alliancelevelrank(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
}


 local uid = request.uid
 local aid = tonumber(request.params.aid) or 0
 local uobjs = getUserObjs(uid)
  uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

 local mUserinfo = uobjs.getModel('userinfo')
 local mUseractive = uobjs.getModel('useractive')

 --ptb:e(mUserinfo)
    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

 


    --ptb:p(mUseractive)
    local acst =mUseractive.info.allianceLevel.st
    local acet = mUseractive.getAcet("allianceLevel",true)   

    local execRet,code = M_alliance.getalliance{uid=uid,aid=aid,acallianceLevel=1,acst=acst,acet=acet}
    -- ptb:p(execRet)
    if not execRet then
        response.ret = code
        return response
    end
    --print(execRet.data.ranklist)

    response.ret = 0        
    response.msg = 'Success'
    response.ranklist=execRet.data.ranklist
    return response
end