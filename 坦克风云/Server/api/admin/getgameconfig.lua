function api_admin_getgameconfig(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local action = request.params.action or 0
    if action==1 then
        require "model.gameconfig"
        local mgameconfig = model_gameconfig()

        response.data.gameconfigbyappid = mgameconfig.getgameconfigbyappid()
    else
        local db = getDbo()
        local result = db:getAllRows("select * from gameconfig")

        response.data.gameconfig = result
    end
    
    response.ret = 0
    response.msg = 'Success'
        
    return response

end