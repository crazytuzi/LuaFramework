--  获取新的每日任务
function api_dailytask_get(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mDailytask = uobjs.getModel('dailytask')
      
    response.data.dailytask = mDailytask.toArray(true) 
    response.ret = 0
    response.msg = 'Success'
   

    return response
end
