--区域战定时脚本发送邮件
function api_areawar_sendbattlemsg(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    
    local date  = getWeeTs()
    local ts = getClientTs()
    local weekday=tonumber(getDateByTimeZone(ts,"%w"))
    local areaWarCfg =getConfig('areaWarCfg')
     local day=areaWarCfg.prepareTime
    if weekday>day then 
        date=date-(weekday-day)*86400
    elseif  weekday<day then
    
       date=date+(day-weekday)*86400
    end
    local execRet, code = M_alliance.sendareabattlemsg{date=date,count=areaWarCfg.signupBattleNum}
    if not execRet then
        response.ret = code
        return response
    end

    if execRet.data~=nil then
        if type(execRet.data)=='table' then
            for k,v in pairs(execRet.data) do
                if v.members~=nil and type(v.members)=='table' then
                    for key,val in pairs(v.members) do
                        local memuid = tonumber(val.uid)
                        local mtype=27
                        local content = {type=mtype,rank=v.rank}
                        content = json.encode(content)
                        MAIL:mailSent(memuid,1,memuid,'',val.name,mtype,content,1,0)
                    end
                end
            end

        end
 

    end


    response.ret = 0
    response.msg = 'Success'
    
    return response

    

end
