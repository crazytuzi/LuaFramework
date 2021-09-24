-- 获取玩家当前头像、头像框、挂件、聊天气泡库 以及在道具cd队列中的数据
function api_user_getpic(request)
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

    local uobjs = getUserObjs(uid,true)
    local mPicstore= uobjs.getModel('picstore')
    local mProp= uobjs.getModel('props')

    response.data.picstore2=mProp.getAllp()--这里是有时效的
    response.data.picstore=mPicstore.toArray(true)--这里都是永久的
    response.ret=0
    response.msg ='Success'
    return response

end