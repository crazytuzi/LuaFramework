--
-- 查看某个军团的信息
-- chenyunhe
--

function api_alliance_getdetails(request)
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
    local mBuilding = uobjs.getModel('buildings')

    -- 军团未解锁
    if not mBuilding.allianceIsUnlock() then
        response.ret = -113 
        return response
    end


    local setRet,code=M_alliance.getDetails{aid=aid}

    if type(setRet.data)~='table' or not next(setRet.data) then
        response.ret = -8017
        return response
    end
    setRet.data.rank = getMyARanking(aid)
    
    response.data.info = setRet.data
    response.ret = 0
    response.msg = 'Success'
    return response
end	