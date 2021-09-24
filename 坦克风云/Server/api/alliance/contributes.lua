-- 捐献列表
function api_alliance_contributes(request)
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

    local mAlliance = getAlliance()

    local list = mAlliance.getContributeList()

    response.data.alliance = {contributelist = list}

    response.ret = 0
    response.msg = 'Success'    
    return response
end 