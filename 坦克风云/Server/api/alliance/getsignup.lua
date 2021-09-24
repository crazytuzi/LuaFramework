--获取军团战自己军团的报名信息
function api_alliance_getsignup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    if uid == nil then
        response.ret = -102
        return response
    end
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end
    local allianceWarCfg = getConfig('allianceWarCfg')
    response.ret = 0
    response.data.signUpTime=allianceWarCfg.signUpTime
    response.msg = 'Success'
    
    return response
   
end