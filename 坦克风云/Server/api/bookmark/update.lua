function api_bookmark_update(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local markinfo = request.params.mark
    
     if uid == nil or type(markinfo) ~= 'table' then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    local mMark = uobjs.getModel('bookmark')

    local ret = mMark.update(markinfo)
    if not ret then
        response.ret = -1989
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.data.bookmark = mMark.toArray(true)
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end
