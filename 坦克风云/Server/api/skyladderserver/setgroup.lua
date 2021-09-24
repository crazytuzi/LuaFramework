-- 记录分组信息
function api_skyladderserver_setgroup(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local cubid = request.params.cubid or 0
    local gtype = request.params.type -- 组类别 个人跨服战、军团跨服战、世界争霸等 id数字
    local ginfo = request.params.ginfo or {}

    require "model.skyladderserver"
    local across = model_skyladderserver()
    across.setautocommit(false)
    local base = across.getStatus()
    local ret,err = across.setgroup(base.cubid,gtype,ginfo)
    if not ret or ret < 0 then
        if ret then
            response.ret = ret
        else
            response.ret = -1
        end
        response.msg = err
        return response
    end
    
    if across:commit() then
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end