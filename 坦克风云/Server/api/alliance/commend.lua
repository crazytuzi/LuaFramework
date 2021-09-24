--
-- 推荐军团
-- yunhe
--
function api_alliance_commend(request)
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

    -- 如果已经加入军团，则给出军团排行列表，自己的军团放在第一位（100以后不显示）
    -- 否则给出推荐列表    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","buildings"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuilding = uobjs.getModel('buildings')

    -- 军团未解锁
    if not mBuilding.allianceIsUnlock() then
        response.ret = -113 
        return response
    end

    local execRet = M_alliance.commendList{uid=uid,aid=mUserinfo.alliance} 
    if not execRet then
        return response
    end

    response.data.list = execRet.data or {}
    response.ret = 0
    response.msg = 'Success'    
    return response
end 