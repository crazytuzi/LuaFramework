function api_alliance_memberlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local aid = tonumber(request.params.aid) or 0    
    local uid = request.uid   

    if uid == nil or aid == 0 then
        response.ret = -102
        return response
    end

    local mAlliance = getUserAlliance(uid)

    local list = mAlliance.getMemberList()
    
    response.data.alliance = {memberlist = list}
    
    return response
end	