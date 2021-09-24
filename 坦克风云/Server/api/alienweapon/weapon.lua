-- 获取异星武器
function api_alienweapon_weapon(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    writeLog({getClientIP(),request},"alienweapon_weapon")

    response.ret = 0
    response.msg = 'Success'

    return response

end
