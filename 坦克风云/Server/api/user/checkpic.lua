-- 检测玩家当前头像、头像框、挂件、聊天气泡
function api_user_checkpic(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }   

    local uid = request.params.uid
    if uid == nil  then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid,true)
    local mUserinfo = uobjs.getModel('userinfo')
    mUserinfo.pic=mUserinfo.getcurpic('p'..mUserinfo.pic)
    mUserinfo.bpic=mUserinfo.getcurpic(mUserinfo.bpic)
    mUserinfo.apic=mUserinfo.getcurpic(mUserinfo.apic)

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'save failed'
    end
    
    return response
end