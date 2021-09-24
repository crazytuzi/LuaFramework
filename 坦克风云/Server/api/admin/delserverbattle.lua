--删除跨服战
function api_admin_delserverbattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local id =request.params.id or 1
    local btype =request.params.type  or 1
    require "model.serverbattle"
    local battleinfo = request.params
    local mServerbattle = model_serverbattle()
    local db = getDbo()

    local ret= mServerbattle.delserverbattle(id,btype)
    if ret then 
        require "model.matches"
        local mMatches = model_matches()
        mMatches.clearCache()
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end