--
-- 军团聊天接口发 招募信息次数  每日有限制 放在客户端怕玩家刷屏
-- chenyunhe
--

function api_alliance_recruit(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid = tonumber(request.params.aid) or 0
   
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","buildings"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance==0 then
        response.ret = -4005
        return response
    end

    --返回值role 2是军团长，1是副团长，0是普通成员
    local ret,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
    if tonumber(ret.data.role)~=2 then
        response.ret = -102
        return response
    end

    local data,flag = mUserinfo.recruit(2,mUserinfo.alliance)
    if flag~=0 then
        response.ret = flag
        return response
    end
    
    response.data.recruit = data
    response.ret = 0
    response.msg = 'Success'
    return response
end	