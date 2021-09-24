function api_bookmark_mark(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local recordType = request.params.type
    local recordName = request.params.name or ""
    local mapx = request.params.mapx
    local mapy = request.params.mapy
 
    if uid == nil or recordType == nil or mapx == nil or mapy == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    if utfstrlen(recordName) > 50 then
        response.ret = -7003
        return response
    end

    local mapId = getMidByPos(mapx,mapy)
    if not mapId then
        response.ret = -1990
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","bookmark","task"})
    local mMark = uobjs.getModel('bookmark') 
    
    -- 标签数量超出了
    if not mMark.isMark() then
        response.ret = -7002
        return response
    end

    local ret = mMark.mark(recordType,recordName,mapId,mapx,mapy)

    local mTask = uobjs.getModel('task')
    mTask.check()

    if uobjs.save() then        
        response.data.bookmark = mMark.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end

    return response
end
