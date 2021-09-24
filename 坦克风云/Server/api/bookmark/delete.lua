function api_bookmark_delete(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local mapId = request.params.mid

    if uid == nil or mapId == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","bookmark","task"})

    local mMark = uobjs.getModel('bookmark')
    local ret = mMark.delete(mapId)

    if not ret then
        response.ret = -1989
        return response
    end

    local mTask = uobjs.getModel('task')
    mTask.check()

    if uobjs.save() then
        response.ret = 0
        response.data.bookmark = mMark.toArray()
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end

    return response
end
