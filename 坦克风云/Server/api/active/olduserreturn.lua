function api_active_olduserreturn(request)
    local response = {
        ret=-1,
        msg='error',
        data={},

    }

    local uid = request.uid
    if uid==nil then
        response.ret=-102    
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local aname    ="oldUserReturn"
    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")
    local activeCfg = getConfig("active")
    
    local activStatus = mUseractive.getActiveStatus(aname)

    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
 
	if  not mUseractive.info.oldUserReturn.n then
		response.ret = -1981
        return response
	end
    if uobjs.save() then
		response.data.oldUserReturn 	= mUseractive.info.oldUserReturn
		local hnum						= mUseractive.info.oldUserReturn.v or 0
		local tnum  					= mUseractive.getoldUserReturnTnum()
		response.data.oldUserReturn.tnum  = tnum
        response.ret = 0        
        response.msg = 'Success'
        return response
    end

    return response
    
end