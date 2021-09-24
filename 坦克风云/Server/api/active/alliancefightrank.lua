function api_active_alliancefightrank(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
}


 local uid = request.uid
 local aid = tonumber(request.params.aid) or 0
 local uobjs = getUserObjs(uid)
   uobjs.load({"userinfo","useractive"})
 local mUserinfo = uobjs.getModel('userinfo')
 local mUseractive = uobjs.getModel('useractive')
    if mUserinfo.alliance ~= aid then
        response.ret = -8023
        return response
    end

 -- 状态检测
    local status = mUseractive.getActiveStatus('allianceFight')


    --ptb:p(mUseractive)
    local acst =mUseractive.info.allianceFight.st
    local acet = mUseractive.getAcet("allianceFight",true)

    local ts =getClientTs()
    local execRet,code
    if ts<acet then
       
        execRet,code = M_alliance.getalliance{uid=uid,aid=aid,acalliancfight=1,acst=acst,acet=acet}
    else
       
        execRet,code = M_alliance.getalliance{uid=uid,aid=aid,acalliancfight=1,acst=acst,acet=acet,members=1}
    end
    --ptb:e(execRet)
    if not execRet then
        response.ret = code
        return response
    end
    --print(execRet.data.ranklist)
    local rank = 0
    local myrank = 0
    local members = execRet.data.members

    --ptb:p(members)
    if type(members)=='table' then
        for k,v in pairs(members) do
            rank=tonumber(k)
            for key,val in pairs(v) do
                if tonumber(val.uid) ==uid then
                    myrank=rank

                end
                
            end
            
        end
    end
    if myrank>0 then
        response.myrank=myrank
    end
    response.ret = 0        
    response.msg = 'Success'
    response.ranklist=execRet.data.ranklist
    return response
end