-- 
--为了解决拉取列表(expedition.getlog)数据过多  不能打开战报的优化
--desc  获取远征军中某一条战报 
--user  chenyunhe
--

function api_expedition_readlog(request)

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
    local id = request.params.id 
    
    if uid <= 0 or id <= 0 then
        response.ret = -102
        return response
    end


    local battlelogLib=require "lib.battlelog"

    local log =battlelogLib:logExpeditionByid(uid,id)
    if log then
        response.data.expeditionlog = log
    end
    response.ret=0
    response.msg = 'Success' 
    return response
end