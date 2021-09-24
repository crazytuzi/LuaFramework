-- 关闭战资比拼活动
function api_admin_closezzbp(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local weeTs = getWeeTs()
    local db = getDbo()
    local ret = db:query("update zzbp set `st`=0,`et`=0")

    response.ret = 0
    response.msg = 'success'

    return response

end