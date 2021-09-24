-- 修改军团数据

function api_admin_setalliance(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local aid = tonumber(request.params.aid)
    local addpoint = tonumber(request.params.addpoint)
    local peoplepoint = tonumber(request.params.peoplepoint)
    local join_at = tonumber(request.params.join_at)
    local apoint = tonumber(request.params.apoint)
    local uid = tonumber(request.params.uid)
    local lvpoint = tonumber(request.params.lvpoint) --军团经验
    local execRet,code = M_alliance.addacpoint{uid=uid,aid=aid,point=addpoint,peoplepoint=peoplepoint,apoint=apoint,join_at=join_at,lvpoint=lvpoint}
       
    if not execRet then
        response.ret = code
        return response
    end
    response.ret = 0
    response.msg = 'Success'

    return response
end