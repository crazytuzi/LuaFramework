function api_admin_getserverbattle(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }
    
    
    
    require "model.serverbattle"
    local battleinfo = request.params
    local mServerbattle = model_serverbattle()

    local data =mServerbattle.getValidserverbattlecfgs()
    response.data=data
    return response
end