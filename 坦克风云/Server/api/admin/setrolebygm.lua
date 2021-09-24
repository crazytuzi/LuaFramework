-- desc : 设置军团职位
-- user : chenyunhe
-- attention:设置的玩家必须在军团成员列表中

function api_admin_setrolebygm(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local aid = tonumber(request.params.aid) or 0
    local uid = tonumber(request.uid)
    local role = tonumber(request.params.role) -- 0 成员 1副团长 2 团长

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
    if aid<=0 or not table.contains({0,1,2},role) or mUserinfo.alliance~=aid then
        response.ret = -102
        return response
    end

    local execRet, code = M_alliance.setRoleBygm{uid=uid,aid=aid,role=role}
    if not execRet then
        response.ret = code
        return response
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
