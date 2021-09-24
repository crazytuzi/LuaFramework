function api_admin_setgameconfig(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local gameconfig = request.params
    if type(gameconfig) ~= 'table' or not gameconfig.name then
        response.ret = -102 
        return response
    end
  
    require "model.gameconfig"

    local mgameconfig = model_gameconfig()

    local ret = false
    if gameconfig.name == 'thirdpay' and type(gameconfig.thirdpaylimit) == 'table' then
        local thirdpaylimit = copyTab( gameconfig.thirdpaylimit )
        gameconfig.thirdpaylimit = nil
        ret = mgameconfig.creategameconfig(gameconfig)
        if not ret then
            ret = mgameconfig.setgameconfigname(gameconfig.name,gameconfig)
        end
        if ret then
            ret = mgameconfig.setgameconfigpay(thirdpaylimit)    
        end
    elseif gameconfig.appid and gameconfig.name and gameconfig.flag then
        ret = mgameconfig.setgameconfigbyappid(gameconfig.name, gameconfig.appid, gameconfig.flag)
    elseif gameconfig.id then
        ret = mgameconfig.setgameconfig(gameconfig.id,gameconfig)
    else
        ret = mgameconfig.creategameconfig(gameconfig)

        if not ret then
           ret= mgameconfig.setgameconfigname(gameconfig.name,gameconfig)
        end
    end

    if ret then    
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end