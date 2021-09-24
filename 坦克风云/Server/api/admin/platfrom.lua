-- 平台需求 获取一些平台内容

function api_admin_platfrom(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uids=request.params.uids
    local filed=request.params.filed
    local filed = table.concat(filed,",")
    local db = getDbo()
    local result = db:getAllRows("select "..filed.."  from userinfo where platid !='' and uid in("..uids..")")    
    response.data.info = result
    response.ret = 0
    response.msg = 'Success'
    
    return response
end