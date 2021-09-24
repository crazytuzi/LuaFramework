function api_alliance_memberdetails(request)
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

    local mAlliance = getAlliance(uid)

    -- 军团不存在
    if not mAlliance then
        response.ret = -8017
        return response
    end

    if not mAlliance.isAllianceMember(uid) then
        response.ret = -8018
        return response
    end

    local memberDetails = mAlliance.getMemberDetails()
    if not memberDetails then
        return response
    end

    response.data.alliance = allianceDetails
    response.ret = 0
    response.msg = 'Success'
    
    return response
end 