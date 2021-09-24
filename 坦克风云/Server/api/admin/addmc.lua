-- 添加月卡
function api_admin_addmc(request)
   local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    

    local uid = tonumber(request.uid)
    local et = tonumber(request.params.et)

    if uid == nil or et<0 then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')    


    local ts =getWeeTs()
    
    if et<ts then
        response.ret=-102
        return  response
    end


    local player = getConfig("player")
    local addgems =player.buymonthcard
    local addGemRet = mUserinfo.addResource({gems=addgems}) 
    if not addGemRet then
        response.ret=-403
        return response
    end

    if type (mUserinfo.mc)~='table' then mUserinfo.mc={}  end
    local weeTs = getWeeTs()
    local mend = mUserinfo.mc[1] or 0
    if mend >weeTs then
        mUserinfo.mc[1]=mend+30*86400
    else
        mUserinfo.mc[1]=weeTs+30*86400
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end