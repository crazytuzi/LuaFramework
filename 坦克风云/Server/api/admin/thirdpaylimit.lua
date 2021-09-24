-- 第三方支付条件
function api_admin_thirdpaylimit(request)
   local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local info = request.params.info

    require 'model.gameconfig'
    local mGameconfig = model_gameconfig() 
    if type(info) == 'table' then
        mGameconfig.setgameconfigpay(info)
    end
    local thirdpay = mGameconfig.getgameconfigpay()
    thirdpay.thirdpay = moduleIsEnabled('thirdpay')
    
    response.data.thirdpay=thirdpay
    response.ret = 0
    response.msg = 'Success'

    return response

end