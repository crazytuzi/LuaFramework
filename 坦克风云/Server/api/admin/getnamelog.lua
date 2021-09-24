--liming
--获取改名记录
function api_admin_getnamelog(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local sql = ""
    sql = "select * from namelog order by update_at desc"
    local uid=request.params.uid
    local name=request.params.name
    if uid ~= nil then
        sql = "select * from namelog where uid="..uid
    end
    if name ~= nil then
        sql = "select * from namelog where oldname like '%"..name.."%' or newname like '%"..name.."%'"
    end
    local name=request.params.name
    local db = getDbo()
    local result = db:getAllRows(sql)
    response.data.getnamelog = result
    response.ret = 0
    response.msg = 'Success'
    
    return response
end