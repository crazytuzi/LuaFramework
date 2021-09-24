-- 开启跨服区域战 

function api_admin_setareateambattle(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    require "model.serverbattle"
    local battleinfo = request.params
    local mServerbattle = model_serverbattle()
    local sevCfg={}
    
    sevCfg=getConfig("serverAreaWarCfg")
    local ret = false

    
    -- type =1  是个人的 
    -- type =2  是军团跨服战
    -- type =3  是世界大战
    --      =4  是跨平台大战
    --      =5  是跨服区域站
    -- 检测这个服有没有开启跨服战
    local info =mServerbattle.getserverbattlecfg(battleinfo.type,1)

     if type(info)=='table'  and  next(info) then
            --正在有跨服战
        response.data.error="have server battle"
        return response
    end


    battleinfo.st= getWeeTs(battleinfo.st)
    local st=battleinfo.st
    local gap=  tonumber(battleinfo.gap)
    local durationtime=sevCfg.durationtime   

    local ts = getClientTs()
    et =st+durationtime*24*3600
    battleinfo.et = tonumber(et)

    ret = mServerbattle.createserverbattlecfg(battleinfo)    
    if ret then         
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end

