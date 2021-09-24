--   获取军事演习的战报

function api_expedition_getlog(request)

    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    
    if moduleIsEnabled('expedition') == 0 or moduleIsEnabled('hero') == 0  then
      response.ret = -13000
      return response
    end


    local uid = request.uid
    
    if uid <= 0 then
        response.ret = -102
        return response
    end


    local battlelogLib=require "lib.battlelog"

    local list =battlelogLib:logExpeditionList(uid)

    if list then
        response.data.expeditionlog = list
    end
    response.ret=0
    response.msg = 'Success' 
    return response
end