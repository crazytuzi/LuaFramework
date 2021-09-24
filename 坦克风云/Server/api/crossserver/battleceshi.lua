-- status 1是胜，2是败，3是淘汰
function api_crossserver_battleceshi(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local ts = getClientTs()
    
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local base = skyladderserver.getStatus()

        local params = json.decode('{"z1":"3","win":"6000001","z2":"6","id2":"6000001","s":1,"pic2":"2","fc2":"764","t":1562244301,"pic1":"1","n1":"player4","fc1":"1000000","n2":"ssook","id1":"4"}') or {}
        skyladderserver.saveBattleData(base.cubid,'person',1,1,params)

    response.ret = 0
    response.msg = 'Success'
    return response     
end
